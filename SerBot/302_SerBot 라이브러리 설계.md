# SerBot 라이브러리 설계
SerBot의 옴니휠과 IMU 센서 및 라이다, 오디오를 제어하는 라이브러리를 직접 구현해 봅니다.   

## I2C Device
리눅스에서 I2C 버스에 연결된 장치를 검색할 때는 i2cdetect 명령을 사용합니다.

```sh
sudo i2cdetect -y -r 0
```

### SMBUS2 for python 
smbus2는 I2C와 이를 확장한 smbus를 제어하는 파이썬 라이브러입니다. 

다음과 같이 smbus2 모듈을 설치합니다.  
```sh
sudo -H pip3 install smbus2
```

smbus2 설명은 다음과 같습니다.  
- [smbus2 API](https://smbus2.readthedocs.io/en/latest/)


smbus2로 i2cdetect 처럼 해당 버스에서 장치를 찾아 봅니다.

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
PCA9685는 SerBot 옴니휠 메커니즘의 DC 모터 방향/속도 제어를 위한 16 채널, 12 비트 PWM 컨트롤러로 I2C 버스에 연결해 사용합니다.

SerBot에 포함된 PCA9685의 I2C 버스와 주소는 다음과 같습니다.  
- Bus = 0, Address = 0x40 사용

다음은 PCA9685 데이터시트입니다. 실제 코드 구현에 필요한 항목은  `7. Functional descripton` 부분입니다.
- [PCA9686 Datasheet](https://www.nxp.com/docs/en/data-sheet/PCA9685.pdf)

데이터시트를 참조해 제어 코드를 구현합니다.  
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

구현한 제어 코드를 테스트해 봅니다. 
**Workspace/pca9685_test.py**
```python
import sys
import signal
from serbot.pca9685 import PWM
import time

pwm = None

def setup():
    global pwm
    
    pwm = PWM()

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
MPU6050는 Serbot의 자세 제어를 위한 6축 관성 센서로 I2C 버스에 연결해 사용합니다.  

SerBot에 포함된 MPU6050는의 I2C 버스와 주소는 다음과 같습니다.  
- Bus = 1, Address = 0x68

다음은 MPU6050 데이터시트와 실제 구현에필요한 `레지스터 맵`입니다.
- [MPU6050 Datasheet](https://product.tdk.com/system/files/dam/doc/product/sensor/mortion-inertial/imu/data_sheet/mpu-6000-datasheet1.pdf)
- [MPU6050 Register Map](https://invensense.tdk.com/wp-content/uploads/2015/02/MPU-6000-Register-Map1.pdf)

레지스터 맵을 참조해 제어 코드를 구현합니다.
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

구현한 제어 코드를 테스트해 봅니다.   
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

### Pilot
앞서 구현한 PCA9685와 MPU6050를 이용해 SerBot의 움직임 제어에 필요한 driving 기능을 구현합니다.

**Workspace/serbot/driving.py**
```python
__version__='0.2.0'

import time
import math

from .pca9685 import PWM
from .mpu6050 import IMU

class Driver:
    GPIO_WHL_1_FORWARD    = 0
    GPIO_WHL_1_BACKWARD   = 1
    GPIO_WHL_2_FORWARD    = 2
    GPIO_WHL_2_BACKWARD   = 3
    GPIO_WHL_3_FORWARD    = 4
    GPIO_WHL_3_BACKWARD   = 5

    MIN_SPEED = 20
    MAX_SPEED = 99

    STEER_LIMIT = 180

    STAT_STOP = 1
    STAT_MOVING = 2
    STAT_SETTING = 3
    STAT_DRIVING = 4

    stat=1

    def __init__(self):            
        self.stat = Driver.STAT_STOP
        self.speed = Driver.MIN_SPEED
        self.drct = 0
        self.steer = 0

        self.pwm = PWM()

    def __del__(self):
        self.stop()

    def whl(self, id, value):
        if id == 1 :
            if value < 0 :
                self.pwm.setDuty(0,abs(value))
                self.pwm.setDuty(1,0)
            elif value > 0 :
                self.pwm.setDuty(0,0)
                self.pwm.setDuty(1,abs(value))
            else :
                self.pwm.setDuty(0,0)
                self.pwm.setDuty(1,0)
        elif id == 2 :
            if value < 0 :
                self.pwm.setDuty(2,abs(value))
                self.pwm.setDuty(3,0)
            elif value > 0 :
                self.pwm.setDuty(2,0)
                self.pwm.setDuty(3,abs(value))
            else :
                self.pwm.setDuty(2,0)
                self.pwm.setDuty(3,0)
        elif id == 3 :
            if value < 0 :
                self.pwm.setDuty(4,abs(value))
                self.pwm.setDuty(5,0)
            elif value > 0 :
                self.pwm.setDuty(4,0)
                self.pwm.setDuty(5,abs(value))
            else :
                self.pwm.setDuty(4,0)
                self.pwm.setDuty(5,0)

    def setSpeed(self, speed):
        if speed:
            if abs(speed) > Driver.MAX_SPEED:
                if speed > 0 :
                    speed = Driver.MAX_SPEED
                elif speed < 0 :
                    speed = -Driver.MAX_SPEED
            elif abs(speed) < Driver.MIN_SPEED:
                if speed > 0 :
                    speed = Driver.MIN_SPEED
                elif speed < 0 :
                    speed = -Driver.MIN_SPEED
            self.speed = speed

        if self.stat == Driver.STAT_MOVING:
            self.move(self.drct, self.speed)
        elif self.stat == Driver.STAT_DRIVING:
            self.drive(self.steer, self.speed)

    def getSpeed(self):
        return self.speed

    def stop(self):
        self.whl(1,0)
        self.whl(2,0)
        self.whl(3,0)

        self.stat = Driver.STAT_STOP

    def setDirection(self, degree):
        self.drct = degree % 360

        if self.stat == Driver.STAT_MOVING:
            self.move(self.drct, self.speed)

    def setSteer(self, degree):
        if abs(degree) > self.STEER_LIMIT :
            if degree > 0 :
                degree = self.STEER_LIMIT
            elif degree < 0 :
                degree = -self.STEER_LIMIT

        self.steer=degree

        if self.stat == Driver.STAT_DRIVING:
            self.drive(self.steer, self.speed)

    def move(self, degree=None, speed=None):
        self.stat = Driver.STAT_SETTING

        if degree is None :
            degree = self.drct
        else :
            self.setDirection(degree)

        if speed is None :
            speed = self.speed
        elif speed == 0 :
            self.stop()
        else :
            self.setSpeed(speed)
        
        w1=math.sin(math.radians(self.drct-300))
        w2=math.sin(math.radians(self.drct-60))
        w3=math.sin(math.radians(self.drct-180))
        
        rate = (1.0/max(abs(w1), abs(w2), abs(w3)))

        w1*=rate*self.speed
        w2*=rate*self.speed
        w3*=rate*self.speed

        self.whl(1,w1)
        self.whl(2,w2)
        self.whl(3,w3)

        self.stat = Driver.STAT_MOVING

    def drive(self, steer=None, speed=None):
        self.stat = Driver.STAT_SETTING

        if steer is None :
            steer = self.steer
        else :
            self.setSteer(steer)

        if speed is None :
            speed = self.speed
        elif speed == 0 :
            self.stop()
            return
        else :
            self.setSpeed(speed)
        
        if abs(steer) != 0 and abs(steer) != 180:
            theta = math.radians(90-steer)

            h = 500 #mm
            rad = {'x':h * math.tan(theta), 'y':0}
            m = 150 #mm

            W_1 = {'x':m * math.cos(math.radians(30)), 'y':m * math.sin(math.radians(30))}
            W_2 = {'x':m * math.cos(math.radians(150)), 'y':m * math.sin(math.radians(150))}
            W_3 = {'x':m * math.cos(math.radians(270)), 'y':m * math.sin(math.radians(270))}

            RW_1 = math.sqrt((W_1['x']-rad['x'])**2 + (W_1['y']-rad['y'])**2) * (steer/abs(steer))
            RW_2 = math.sqrt((W_2['x']-rad['x'])**2 + (W_2['y']-rad['y'])**2) * (steer/abs(steer))
            RW_3 = math.sqrt((W_3['x']-rad['x'])**2 + (W_3['y']-rad['y'])**2) * (steer/abs(steer))

            alpha_1 = math.acos( W_1['y'] / RW_1 ) + math.radians(30)
            alpha_2 = math.acos( W_2['y'] / RW_2 ) + math.radians(150)
            alpha_3 = math.acos( W_3['y'] / RW_3 ) + math.radians(270)

            w1=math.sin(alpha_1)
            w2=math.sin(alpha_2)
            w3=math.sin(alpha_3)

            rate = (1.0/max(abs(w1), abs(w2), abs(w3)))

            w1*=rate*self.speed
            w2*=rate*self.speed
            w3*=rate*self.speed

            self.whl(1,w1)
            self.whl(2,w2)
            self.whl(3,w3)
        elif abs(steer) == 180 :
            self.whl(1,self.speed)
            self.whl(2,-self.speed)
            self.whl(3,0)
        elif abs(steer) == 0 :
            self.whl(1,self.speed)
            self.whl(2,-self.speed)
            self.whl(3,0)

        self.stat = Driver.STAT_DRIVING

    def turnLeft(self):
        self.whl(1,-self.speed)
        self.whl(2,-self.speed)
        self.whl(3,-self.speed)

    def turnRight(self):
        self.whl(1,self.speed)
        self.whl(2,self.speed)
        self.whl(3,self.speed)


class Driving:
    steer_limit = 90
    max_speed=99
    min_speed=20

    def __init__(self):
        super().__init__()

        self.drv = Driver()
        self.speed = 0
        self.steering = 0.0

    @property
    def steering(self):
        return self._steering

    @steering.setter
    def steering(self, value):
        assert(not (-1.0 >= value <= 1.0))

        self._steering = value
        self.drv.setSteer(value * self.steer_limit)

    def turnLeft(self):
        self.drv.turnLeft()

    def turnRight(self):
        self.drv.turnRight()

    def setSpeed(self, speed):
        self.speed=speed
        self.drv.setSpeed(speed)

    def getSpeed(self):
        return self.drv.getSpeed()

    def stop(self):
        self.drv.stop()
    
    def forward(self, speed=None):
        if speed is not None:
            self.speed=speed

        self.drv.drive(self.drv.steer, self.speed)
    
    def backward(self, speed=None):
        if speed is not None:
            self.speed=speed

        self.drv.drive(self.drv.steer, -self.speed)

    def move(self, degree, speed):
        self.drv.move(degree,speed)
```

### Rplidar A2
대표적인 2D Lidar 중 하나인 Rplidar A2는 Serbot의 카메라와 함께 시각을 담당합니다. 
라이다는 레이더나 소나와 같은 원리로 작동합니다. 세 기술 모두 에너지 파동을 방출하여 물체를 감지하고 추적합니다. 
차이점은 레이더는 마이크로파를 사용하고 소나는 음파를 사용하는 반면, 라이다는 레이저 반사광을 사용하기 때문에 레이더나 소나보다 정밀하고 높은 해상도로 더 빠르게 거리를 측정할 수 있습니다.
2D 라이다는 레이저 광선이 1채널인 라이다로 송신기에서 발사된 레이저 광선이 물체에 반사되어 수신기로 들어오면 신호처리 장치가 삼각측량(triangulation)이나 ToF 방식으로 계산해 거리를 산출합니다.    
Rplidar A2는 대중적인 2D 라이다 중 하나로 시리얼 통신으로 제어하는데 최대 측정 거리는 모델에 따라 3 ~ 12m이고 1초에 360도(degree)를 10 frame 이상 측정할 수 있습니다. 
일반적으로 UART 출력을 USB로 변환하는 컨버터를 사용하므로 USB 포트에 연결해 사용합니다.

SerBot에 포함된 Rplidar A2의 가상 시리얼 포트는 다음과 같습니다.  
- /dev/ttyUSB0

다음은 Rplidar A2 데이터시트와 실제 구현에 필요한 `Rplidar 프로토콜`입니다.  
- [Rplidar A2 datasheet](http://bucket.download.slamtec.com/004eb70efdaba0d30a559d7efc60b4bc6bc257fc/LD204_SLAMTEC_rplidar_datasheet_A2M4_v1.0_en.pdf)
- [Rplidar Protocols](https://bucket-download.slamtec.com/6494fd238cf5e0d881f56d914c6d1f355c0f582a/LR001_SLAMTEC_rplidar_protocol_v2.4_en.pdf)

Slamtec은 Rplidar 프로토콜을 C++로 구현한 SDK를 Github에 공개하고 있으므로 이를 이용해 SWIG로 파이썬 바인더를 구현합니다.
1. github에서Rplidar sdk 최신 버전 복제  
```sh
git clone https://github.com/Slamtec/rplidar_sdk
```

2. 빌드
```
cd rplidar_sdk
make -j6
```

3. 파이썬 바인더 생성
- C++를 python으로 변환하는 swig 설치
  ```sh
  sudo apt install swig
  ```
- rplidar_sdk/sdk 폴더에서 진행하며, rplidar_sdk/output/Linux/Release/libsl_lidar_sdk.a를 rplidar_sdk/sdk로 복사
- app/simple-grabber/main.cpp와 app/ultra_simple/main.cpp 코드를 참조해 파이썬으로 변환할 C++ 클래스 헤더(lidar2d_h)와 소스(lidar2d.cpp) 정의
- C++ 헤더를 참조해 swig 인터페이스 정의 (lidar2d.i)
  - C++ STL 라이브러리 변환 구현을 제외하면 include로 포함하는 헤더를 추가하는 수준
- 셋업(setup.py) 및 빌드(make.py) 정의
- 빌드(make.py)를 실행하면 공유 라이브러리(_lidar2d.so)와 binding 파일(lidar2d.py)이 생성됨

결과는 다음 링크를 통해 다운받을 수 있습니다.
[Rplidar binding](https://1drv.ms/f/s!AtTAtBZJQ9JFpdR0lh0zdIrNiUMjYQ?e=2Q0GSB)

다음은 결과 생성에 필요한 소스 코드입니다.
**lidar2d.h**
```python
#include <stdio.h>
#include <stdlib.h>
#include <string>
#include <vector>

#include "include/sl_lidar.h"
#include "include/sl_lidar_driver.h"

#define DEFAULT_PORT_PATH "/dev/ttyUSB0"
#define DEFAULT_BAUD_RATE 115200

using namespace sl;

class Lidar2D {
        public:
                Lidar2D();
                ~Lidar2D();

                bool connect(const char * port=DEFAULT_PORT_PATH, int baud=DEFAULT_BAUD_RATE);
                void disconnect(void);
                void reset(void);

                const char * getSerialNumber(void);
                const char * getFirmwareVersion(void);
                const char * getHardwareVersion(void); 

                std::vector<std::vector<double>> getVectors();
                std::vector<std::vector<double>> getXY();

        private:
                sl_lidar_response_measurement_node_hq_t nodes[8192];
                size_t count;

                ILidarDriver * drv;
                char serial_number[64] = {0,};
                char firmware_version[64] = {0,};
                char hardware_version[64] = {0,};
                
        private:
                bool checkHealth(void);
};
```

**lidar2d.cpp**
```python
#include <unistd.h>
#include <cmath>

#include "lidar2d.h"

constexpr double deg2rad = M_PI/180.0;

static inline void delay(sl_word_size_t ms){
    while (ms>=1000){
        usleep(1000*1000);
        ms-=1000;
    };
    if (ms!=0)
        usleep(ms*1000);
}


Lidar2D::Lidar2D()
{
    drv = *createLidarDriver();
    if (!drv) { 
        fprintf(stderr, "insufficent memory exit\n");
        exit(-2);
    }

    count = sizeof(nodes)/sizeof(sl_lidar_response_measurement_node_hq_t);
}

Lidar2D::~Lidar2D()
{   
    disconnect();
    
    delete drv;
    drv = NULL;
}

bool Lidar2D::connect(const char * port, int baud)
{
    IChannel * _channel;
    sl_lidar_response_device_info_t _devinfo;
    LidarScanMode scanMode;

    _channel = (*createSerialPortChannel(port, baud));
    if (SL_IS_OK((drv)->connect(_channel))) {
        if (SL_IS_OK(drv->getDeviceInfo(_devinfo))) {
            for (int pos = 0; pos < 16 ;++pos) {
                sprintf(&serial_number[pos*2], "%02X", _devinfo.serialnum[pos]);
            }
            sprintf(firmware_version, "%d.%02d", _devinfo.firmware_version>>8, _devinfo.firmware_version & 0xFF);
            sprintf(hardware_version, "%d", (int)_devinfo.hardware_version);

            if (checkHealth()) {
                drv->setMotorSpeed();
                drv->startScan(false, true, 0, &scanMode);

                return true;
            }
            else {
                return false;
            }
        }
        else {
            delete drv;
            drv = NULL;
            
            return false;
        }
    }

    return false;
}

void Lidar2D::disconnect(void)
{
    if (drv) {
        drv->stop();
        delay(200);
        drv->setMotorSpeed(0);
    }
}

void Lidar2D::reset()
{
    drv->reset();
}

bool Lidar2D::checkHealth()
{
    sl_result op_result;
    sl_lidar_response_device_health_t healthinfo;

    op_result = drv->getHealth(healthinfo);
    if (SL_IS_OK(op_result)) {
        printf("Lidar health status : %d\n", healthinfo.status);
        if (healthinfo.status == SL_LIDAR_STATUS_ERROR) {
            fprintf(stderr, "Error, slamtec lidar internal error detected. Please reboot the device to retry.\n");
            return false;
        } else {
            return true;
        }

    } else {
        fprintf(stderr, "Error, cannot retrieve the lidar health code: %x\n", op_result);
        return false;
    }
}

const char * Lidar2D::getSerialNumber(void)
{
    return serial_number;
}

const char * Lidar2D::getFirmwareVersion(void)
{
    return firmware_version;
}

const char * Lidar2D::getHardwareVersion(void)
{
    return hardware_version;
}

std::vector<std::vector<double>> Lidar2D::getVectors()
{
    std::vector<double> sample(4);
    std::vector<std::vector<double>> output;

    if (SL_IS_OK(drv->grabScanDataHq(nodes, count, 0))) {
        drv->ascendScanData(nodes, count);
        for (int pos = 0; pos < (int)count ; ++pos) {
            sample.at(0) = (nodes[pos].angle_z_q14 * 90.f) / 16384.f;
            sample.at(1) = nodes[pos].dist_mm_q2/4.0f;
            sample.at(2) = nodes[pos].quality >> SL_LIDAR_RESP_MEASUREMENT_QUALITY_SHIFT;
            sample.at(3) = nodes[pos].flag & SL_LIDAR_RESP_HQ_FLAG_SYNCBIT ? 1.0 : 0.0;
            output.push_back(sample);
        }

        output.reserve(count);
    }
    
    return output;
}

std::vector<std::vector<double>> Lidar2D::getXY()
{
    std::vector<std::vector<double>> points = getVectors();
    std::vector<std::vector<double>> output(points.size(), std::vector<double>(2));

    for (unsigned int i = 0; i<points.size(); i++) {
        output.at(i).at(0) = std::cos(deg2rad*points.at(i).at(0)) * points.at(i).at(1);
        output.at(i).at(1) = std::sin(deg2rad*points.at(i).at(0)) * points.at(i).at(1);
    }

    return output;
}
```

**lidar2d.i**
```python
%module lidar2d
%{
#include <stdio.h>
#include <stdlib.h>
#include <vector>

#include "include/sl_lidar.h"
#include "include/sl_lidar_driver.h"
#include "lidar2d.h"
%}

%include <std_vector.i>
%include <std_string.i>
%include "include/sl_lidar.h"
%include "include/sl_lidar_driver.h"
%include "lidar2d.h"
%template(vector_double) std::vector<double>;
%template(vector_vector_double) std::vector<std::vector<double> >;

%typemap(out) std::vector<std::vector<double> >* %{
    $result = PyList_New($1->size()); 
    for(size_t i = 0; i < $1->size(); ++i)
    {
        auto t = PyList_New((*$1)[i].size()); 
        for(size_t j = 0; j < (*$1)[i].size(); ++j) {
            PyList_SET_ITEM(t,j,PyFloat_FromDouble((*$1)[i][j]));
        }
        PyList_SET_ITEM($result,i,t);
    }
%}
```

**setup.py**
```python
from distutils.core import setup, Extension

lidar2d_module = Extension('_lidar2d',
                            sources=['lidar2d_wrap.cxx', 'lidar2d.cpp'],
				extra_objects=["libsl_lidar_sdk.a"],
				extra_compile_args=['-lpthread', '-lstdc++'],
                           )

setup (name = 'lidar2d',
       version = '1.1',
       author = "PlanX-Labs",
       description = """lidar2d Python Binder""",
       ext_modules = [lidar2d_module],
       py_modules = ["lidar2d"],
       )
```

**make.py**
```python
#!/usr/bin/python3

import subprocess
import os

p = subprocess.Popen(['swig',
                      '-c++',
                      '-python',
                      'lidar2d.i'])
p.wait()

p = subprocess.Popen(['python3',
                      'setup.py',
                      'build_ext',
                      '--inplace'])
p.wait()

for file in os.listdir(os.getcwd()):
    if file.find('_lidar2d.cpython') >= 0:
        os.rename(os.path.join(os.getcwd(), file), os.path.join(os.getcwd(), '_lidar2d.so'))
        break
```




