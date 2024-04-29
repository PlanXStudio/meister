# Pilot 라이브러리 설계

## I2C Device (PCA9685, MPU6050)
```sh
sudo i2cdetect -y -r 0
sudo i2cdetect -y -r 1
```

- [PCA9686 Datasheet](https://www.nxp.com/docs/en/data-sheet/PCA9685.pdf)
- [MPU6050 Datasheet](https://product.tdk.com/system/files/dam/doc/product/sensor/mortion-inertial/imu/data_sheet/mpu-6000-datasheet1.pdf)

## Jetson Nano
```sh
sudo apt-cache show nvidia-jetpack | grep Version
```
 
## Python3.8
```sh
sudo rm -rf /usr/bin/python3.8 /usr/local/bin/python3.8

sudo apt update
sudo apt upgrade --fix-missing

sudo apt install python3.8
sudo python3.8 -m ensurepip --upgrade

sudo pip3 install numpy matplotlib
sudo pip3 install opencv-python pyqt5
sudo pip3 install ipkernel
sudo pip3 install pyaudio smbus2 pyusb
```

## Workspace
mkdir -p ~/Project/python/serbot/pop
vi ~/Project/python/serbot/pop/Pilot.py
```python
__version__='0.1.0'

import time
import math
import smbus2 as smbus


class PWM:
    """
    PCA9685
    """
    ADDR        = 0x40
    I2C_BUS     = 0
    CLOCK_SPEED = 25000000.0 # 25MHz
    FREQ        = 200
    
    MODE1       = 0x00
    MODE2       = 0x01          
    PRESCALE    = 0xFE
    
    BASE_LOW    = 0x08 
    BASE_HIGH   = 0x09

    def __init__(self):
        self.bus = smbus.SMBus(self.I2C_BUS)
        
        self.reset()
        self.setFreq(self.FREQ)
    
    def reset(self):
        self.bus.write_byte_data(self.ADDR, self.MODE1, 0x00)
    
    def setFreq(self, freq):
        '''
        PWM 주파수 설정
        @param freq: Hz 단위 주파수
        '''
                
        prescale = int(self.CLOCK_SPEED / 4096.0 / freq + 0.5) - 1
        if prescale < 3:
            raise ValueError("Cannot output at the given frequency")

        old_mode = self.bus.read_byte_data(self.ADDR, self.MODE1)
        self.bus.write_byte_data(self.ADDR, self.MODE1, (old_mode & 0x7F) | 0x10) # sleep
        self.bus.write_byte_data(self.ADDR, self.PRESCALE, prescale)
        self.bus.write_byte_data(self.ADDR, self.MODE1, old_mode)
        time.sleep(5/1000) #5ms
        self.bus.write_byte_data(self.ADDR, self.MODE1, old_mode | 0xA0) # autoincrement on
        
    def setDuty(self, channel, duty):
        '''
        PWM 채널의 듀티비 설정
        @param channel: 채널 번호 (0~15)
        @param duty: 튜티비 (0~100)
        '''
        
        data = int(duty * 4096 / 100) # 0..4096 (included)
        
        self.bus.write_byte_data(self.ADDR, self.BASE_LOW + 4 * channel, data & 0xFF)
        self.bus.write_byte_data(self.ADDR, self.BASE_HIGH + 4 * channel, data >> 8)

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


class SerBot:
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


class IMU:
    """
    MPU6050
    """
    
    ADDR            = 0x68
    I2C_BUS         = 1
    
    GRAVITIY_MS2    = 9.80665
    
    PW_MGMT_1       = 0x6b
    SMPLRT_DIV      = 0x19
    CONFIG          = 0x1A
    
    ACCEL_CONFIG    = 0x1C
    GYRO_CONFIG     = 0x1B

    ACCEL_RANGE_2G = 0x00
    ACCEL_RANGE_4G = 0x08
    ACCEL_RANGE_8G = 0x10
    ACCEL_RANGE_16G = 0x18

    GYRO_RANGE_250DEG = 0x00
    GYRO_RANGE_500DEG = 0x08
    GYRO_RANGE_1000DEG = 0x10
    GYRO_RANGE_2000DEG = 0x18

    ACCEL_SCALE_MODIFIER_2G = 16384.0
    ACCEL_SCALE_MODIFIER_4G = 8192.0
    ACCEL_SCALE_MODIFIER_8G = 4096.0
    ACCEL_SCALE_MODIFIER_16G = 2048.0

    GYRO_SCALE_MODIFIER_250DEG = 131.0
    GYRO_SCALE_MODIFIER_500DEG = 65.5
    GYRO_SCALE_MODIFIER_1000DEG = 32.8
    GYRO_SCALE_MODIFIER_2000DEG = 16.4
    
    ACCEL_X_H       = 0x3B
    ACCEL_Y_H       = 0x3D
    ACCEL_Z_H       = 0x3F
    TEMP            = 0x41
    GYRO_X_H        = 0x43
    GYRO_Y_H        = 0x45
    GYRO_Z_H        = 0x47
    
    def __init__(self):
        try:
            self.bus = smbus.SMBus(self.I2C_BUS)
            self.bus.write_byte_data(self.ADDR, self.PW_MGMT_1, 0x00)
        except: 
            print("Warning : Can't load imu.")

    def __del__(self):
        self.bus.close()

    def __read_word(self, reg):
        high = self.bus.read_byte_data(self.ADDR, reg)
        low = self.bus.read_byte_data(self.ADDR, reg + 1)
        
        value = ((high << 8) | low)
        
        return value if (value <= 32768) else value - 65536


    def read_accel_range(self):
        return self.bus.read_byte_data(self.ADDR, self.ACCEL_CONFIG)

    def set_accel_range(self, range):
        self.bus.write_byte_data(self.ADDR, self.ACCEL_CONFIG, 0)
        self.bus.write_byte_data(self.ADDR, self.ACCEL_CONFIG, range)
        
    def read_gyro_range(self):
        return self.bus.read_byte_data(self.ADDR, self.GYRO_CONFIG)

    def set_gyro_range(self, range):
        self.bus.write_byte_data(self.ADDR, self.GYRO_CONFIG, 0)
        self.bus.write_byte_data(self.ADDR, self.GYRO_CONFIG, range)

    def getTemp(self, cal=-10):
        raw_temp = self.__read_word(self.TEMP)
        
        return ((raw_temp / 340.0) + 36.53 + cal)

    def getAccel(self, gravity=False):
        accel_scale_modifier = self.ACCEL_SCALE_MODIFIER_2G
        
        accel_range = self.read_accel_range()
    
        if accel_range == self.ACCEL_RANGE_2G:
            accel_scale_modifier = self.ACCEL_SCALE_MODIFIER_2G
        elif accel_range == self.ACCEL_RANGE_4G:
            accel_scale_modifier = self.ACCEL_SCALE_MODIFIER_4G
        elif accel_range == self.ACCEL_RANGE_8G:
            accel_scale_modifier = self.ACCEL_SCALE_MODIFIER_8G
        elif accel_range == self.ACCEL_RANGE_16G:
            accel_scale_modifier = self.ACCEL_SCALE_MODIFIER_16G
        else:
            print("Unkown range")
            
        x = self.__read_word(self.ACCEL_X_H) / accel_scale_modifier
        y = self.__read_word(self.ACCEL_Y_H) / accel_scale_modifier
        z = self.__read_word(self.ACCEL_Z_H) / accel_scale_modifier

        if not gravity:
            x *= self.GRAVITIY_MS2
            y *= self.GRAVITIY_MS2
            z *= self.GRAVITIY_MS2

        return (x, y, z)

    def getGyro(self):
        gyro_scale_modifier = self.GYRO_SCALE_MODIFIER_250DEG        
        gyro_range = self.read_gyro_range()
        
        if gyro_range == self.GYRO_RANGE_250DEG:
            gyro_scale_modifier = self.GYRO_SCALE_MODIFIER_250DEG
        elif gyro_range == self.GYRO_RANGE_500DEG:
            gyro_scale_modifier = self.GYRO_SCALE_MODIFIER_500DEG
        elif gyro_range == self.GYRO_RANGE_1000DEG:
            gyro_scale_modifier = self.GYRO_SCALE_MODIFIER_1000DEG
        elif gyro_range == self.GYRO_RANGE_2000DEG:
            gyro_scale_modifier = self.GYRO_SCALE_MODIFIER_2000DEG
        else:
            print("Unkown range - gyro_scale_modifier set to self.GYRO_SCALE_MODIFIER_250DEG")        
        
        x = self.__read_word(self.GYRO_X_H) / gyro_scale_modifier
        y = self.__read_word(self.GYRO_Y_H) / gyro_scale_modifier
        z = self.__read_word(self.GYRO_Z_H) / gyro_scale_modifier
        
        return (x, y, z)
```
