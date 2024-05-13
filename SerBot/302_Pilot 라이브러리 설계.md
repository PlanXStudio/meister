# Pilot 라이브러리 설계
Serbot 이동체 제어 라이브러리

## I2C Device
```sh
sudo i2cdetect -y -r 0
```

### SMBUS2 for python 
[smbus2 API](https://smbus2.readthedocs.io/en/latest/)

```python
from smbus2 import SMBus

def scan(n, force=False):
    devices = []
    for addr in range(0x03, 0x77 + 1):
        read = SMBus.read_byte, (addr,), {'force':force}
        write = SMBus.write_byte, (addr, 0), {'force':force}

        for func, args, kwargs in (read, write):
            try:
                with SMBus(n) as bus:
                    _ = func(bus, *args, **kwargs)
                    devices.append(addr)
                    break
            except OSError as expt:
                if expt.errno == 16:
                    continue #just busy, maybe permanent by a kernel driver or just temporary by some user code"
                
    return tuple(devices)


for addr in scan(0, True):
    print(f"0X{addr:02X}")
```

### PCA9685  
옴니휠 메커니즘의 DC 모터 속도 제어를 위한 16 채널, 12 비트 PWM 컨트롤러  
- Bus = 0, Address = 0x40 사용
- [PCA9686 Datasheet](https://www.nxp.com/docs/en/data-sheet/PCA9685.pdf)
  - `7. Functional descripton 참조`

**Workspace/serbot/pca9685.py**
```python
import time
from smbus2 import SMBus

class PWM:
    """
    PCA9685
    address = 0x40
    bus = 0
    """
        
    MODE1       = 0x00     
    PRESCALE    = 0xFE
    
    BASE_LOW    = 0x08 #LED0_OFF_L 
    BASE_HIGH   = 0x09 #LED0_OFF_H

    CLOCK_SPEED = 25000000.0 # 25MHz
    FREQ        = 100 #200


    def __init__(self, addr=0x40, bus=0):
        self.__addr = addr
        self.__bus = SMBus(bus)
            
        self.reset()
        self.setFreq(self.FREQ) # p26. 7.3.5 PWM frequency 

    def __del__(self):
        self.__bus.close()
    
    def reset(self):
        self.__bus.write_byte_data(self.__addr, self.MODE1, 0x00)
    
    def setFreq(self, freq):
        assert(24 < freq or freq > 1526)
                        
        prescale = int(self.CLOCK_SPEED / (4096.0 * freq) - 1)

        old_mode = self.__bus.read_byte_data(self.__addr, self.MODE1)
        self.__bus.write_byte_data(self.__addr, self.MODE1, (old_mode & 0x7F) | 0x10) # sleep
        self.__bus.write_byte_data(self.__addr, self.PRESCALE, prescale)
        self.__bus.write_byte_data(self.__addr, self.MODE1, old_mode)
        time.sleep(500/(1000 * 1000)) # p16. Remark: The SLEEP bit must be logic 0 for at least 500 us, before a logic 1 is written into the RESTART bit
        self.__bus.write_byte_data(self.__addr, self.MODE1, old_mode | 0xA0) # restart enabled, internal clock, Auto-increment enabled, Normal mode(not sleep)
        
    def setDuty(self, channel, duty):        
        data = int(duty * 4096 / 100 + 0.5) - 1 # 0..4095 
        
        self.__bus.write_byte_data(self.__addr, self.BASE_LOW + 4 * channel, data & 0xFF)
        self.__bus.write_byte_data(self.__addr, self.BASE_HIGH + 4 * channel, data >> 8)
```

**Workspace/pca9685_test.py**
```python
import sys
import signal
from serbot.pca9685 import PWM
import time

pwm = None

def setup():
    global pwm
    
    imu = IMU()

    pwm.setDuty(0, 0)
    pwm.setDuty(1, 100) # CCW (forward)
    time.sleep(3)
    pwm.setDuty(0, 100) # CW (backward)
    pwm.setDuty(1, 0)
    time.sleep(3)
    pwm.setDuty(0, 0)

def loop():
    pass

def cleanup(*args, **kwargs):
    sys.exit()

if __name__ == "__main__":
    signal.signal(signal.SIGINT, cleanup)
    setup()
    while True:
        loop()
```

### MPU6050
Serbot 자세 제어를 위한 6축 관성 센서
- Bus = 1, Address = 0x68
- [MPU6050 Datasheet](https://product.tdk.com/system/files/dam/doc/product/sensor/mortion-inertial/imu/data_sheet/mpu-6000-datasheet1.pdf)

**Workspace/serbot/mpu6050.py**
```python
from smbus2 import SMBus

class IMU:
    """
    MPU6050
    address = 0x68
    bus = 1
    """
    
    MPU_CONFIG          = 0x1A
    GYRO_CONFIG         = 0x1B
    ACCEL_CONFIG        = 0x1C
                       
    ACCEL_X_H           = 0x3B
    ACCEL_Y_H           = 0x3D
    ACCEL_Z_H           = 0x3F
    TEMP                = 0x41
    GYRO_X_H            = 0x43
    GYRO_Y_H            = 0x45
    GYRO_Z_H            = 0x47

    PWR_MGMT_1          = 0x6B
    
    ACCEL_RANGE_2G      = 0x00
    ACCEL_RANGE_4G      = 0x08
    ACCEL_RANGE_8G      = 0x10
    ACCEL_RANGE_16G     = 0x18
   
    GYRO_RANGE_250DEG   = 0x00
    GYRO_RANGE_500DEG   = 0x08
    GYRO_RANGE_1000DEG  = 0x10
    GYRO_RANGE_2000DEG  = 0x18

    ACCEL_SCALE = {
        ACCEL_RANGE_2G:16384.0,
        ACCEL_RANGE_4G:8192.0,
        ACCEL_RANGE_8G:4096.0,
        ACCEL_RANGE_16G:2048.0
    }

    GYRO_SCALE = {
        GYRO_RANGE_250DEG:131.0,
        GYRO_RANGE_500DEG:65.5,
        GYRO_RANGE_1000DEG:32.8,
        GYRO_RANGE_2000DEG:16.4
    }
    
    GRAVITIY_MS2 = 9.80665 # m/s^2


    def __init__(self, addr=0x68, bus=1):
        self.__addr = addr
        self.__bus = SMBus(bus)
        
        self.__bus.write_byte_data(self.__addr, self.PWR_MGMT_1, 0x00)

    def __del__(self):
        self.__bus.close()

    def __read_word_data(self, reg):
        high = self.__bus.read_byte_data(self.__addr, reg)
        value = (high << 8) | self.__bus.read_byte_data(self.__addr, reg + 1)
        
        return value if (value <= 32768) else value - 65536

    def getAccelRange(self):
        return self.__bus.read_byte_data(self.__addr, self.ACCEL_CONFIG)

    def setAccelRange(self, range):
        self.__bus.write_byte_data(self.__addr, self.ACCEL_CONFIG, 0)
        self.__bus.write_byte_data(self.__addr, self.ACCEL_CONFIG, range)
        
    def getGyroRange(self):
        return self.__bus.read_byte_data(self.__addr, self.GYRO_CONFIG)

    def setGyroRange(self, range):
        self.__bus.write_byte_data(self.__addr, self.GYRO_CONFIG, 0)
        self.__bus.write_byte_data(self.__addr, self.GYRO_CONFIG, range)

    def setFilterRange(self, range=FILTER_BW_256):
        ext_sync_set = self.__bus.read_byte_data(self.__addr, self.MPU_CONFIG) & 0b00111000
        self.__bus.write_byte_data(self.__addr, self.MPU_CONFIG,  ext_sync_set | range)

    def getTemp(self, cal=-10):
        raw_temp = self.__read_word_data(self.TEMP)

        return ((raw_temp / 340.0) + 36.53 + cal)

    def getAccel(self, gravity=False):
        range = self.getAccelRange()
        scale = self.ACCEL_SCALE[range]

        x = self.__read_word_data(self.ACCEL_X_H) / scale
        y = self.__read_word_data(self.ACCEL_Y_H) / scale
        z = self.__read_word_data(self.ACCEL_Z_H) / scale

        if not gravity:
            x *= self.GRAVITIY_MS2
            y *= self.GRAVITIY_MS2
            z *= self.GRAVITIY_MS2

        return (x, y, z)

    def getGyro(self):
        range = self.getGyroRange()
        scale = self.GYRO_SCALE[range]
                
        x = self.__read_word_data(self.GYRO_X_H) / scale
        y = self.__read_word_data(self.GYRO_Y_H) / scale
        z = self.__read_word_data(self.GYRO_Z_H) / scale
        
        return (x, y, z)
```

**Workspace/mpu6050_test.py**
```python
import sys
import signal
from serbot.mpu6050 import IMU

imu = None

def setup():
    global imu
    
    imu = IMU()

def loop():
    print(imu.getAccel())

def cleanup(*args, **kwargs):
    sys.exit()

if __name__ == "__main__":
    signal.signal(signal.SIGINT, cleanup)
    setup()
    while True:
        loop()
```
