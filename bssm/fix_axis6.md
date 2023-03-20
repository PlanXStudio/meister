# Fix axis6 class
## Target
> Product: **SerBot PrimeX**
>> Position: `/usr/loca/lib/python3.6/dist-packages/pop/Pilot.py`

## Working
**Change Directory**
```sh
cd /usr/loca/lib/python3.6/dist-packages/pop/
```

**Run VIM***
```sh
sudo vi Pilot.py
```

**Remote lines 380-459**
```sh
:380
80dd
<i>
```

**Insert the code below**
```python
class axis6: 
    STANDARD_GRAVITY = 9.80665
    
    # MPU-6050 Registers
    SMPLRT_DIV   = 0x19 #Sample rate divisor register
    CONFIG       = 0x1A #General configuration register
    GYRO_CONFIG  = 0x1B
    ACCEL_XOUT_H = 0x3B #Accel X_H register
    ACCEL_YOUT_H = 0x3D #Accel Y_H register
    ACCEL_ZOUT_H = 0x3F #Accel Z_H register
    TEMP_OUT_H   = 0x41 
    GYRO_XOUT_H  = 0x43 #Gyro X_H register
    GYRO_YOUT_H  = 0x45 #Gyro Y_H register
    GYRO_ZOUT_H  = 0x47 #Gyro Z_H register   
    PW_MGMT_1    = 0x6B #Primary power/sleep control register

    def __init__(self, bus=1, address=0x68):
        self.address = address
        
        if _cat==0 or _cat==1 or _cat==3:
            self.bus = smbus.SMBus(bus)
        elif _cat==4 or _cat==5:
            self.bus = smbus.SMBus(8)
        else:
            del self
        
        self.bus.write_byte_data(self.address, self.PW_MGMT_1, 1) 
        self.bus.write_byte_data(self.address, self.CONFIG, 0)
        self.bus.write_byte_data(self.address, self.GYRO_CONFIG, 24) 
    
    def __del__(self):
        self.bus.close()

    def __read_reg_data(self, reg):
        high = self.bus.read_byte_data(self.address, reg)
        low = self.bus.read_byte_data(self.address, reg + 1)
    
        value = ((high << 8) | low)
        
        #to get signed value
        if(value > 32768):
            value = value - 65536

        return value

    def getTemp(self):
        raw = self.__read_reg_data(self.TEMP_OUT_H)
        return (raw / 340) + 36.53
    
    def getGyro(self, axis=None): #-90.0 ~ 90.0 degree/s
        x = self.__read_reg_data(self.GYRO_XOUT_H) / 131.0
        y = self.__read_reg_data(self.GYRO_YOUT_H) / 131.0
        z = self.__read_reg_data(self.GYRO_ZOUT_H) / 131.0

        ret = {'x':x, 'y':y, 'z':z} 

        try:
            return ret[axis.lower()]
        except (KeyError, AttributeError):
            return ret

    def getAccel(self, axis=None):  #-9.8 ~ 9.8 m/s^2
        x = self.__read_reg_data(self.ACCEL_XOUT_H) / 16384.0
        y = self.__read_reg_data(self.ACCEL_YOUT_H) / 16384.0
        z = self.__read_reg_data(self.ACCEL_ZOUT_H) / 16384.0

        ret = {'x':x * self.STANDARD_GRAVITY, 'y':y * self.STANDARD_GRAVITY, 'z':z * self.STANDARD_GRAVITY} 

        try:
            return ret[axis.lower()]
        except (KeyError, AttributeError):
            return ret

IMU = axis6
```

> Save & VIM Close
```sh
<ESC>
:x
```

## UnitTest (JupyterLab)
---
```python
import time
import ipywidgets as widgets
from threading import Thread
```
---
```python
delay = widgets.IntSlider(max=10000, description='delay')
gyro = [widgets.FloatSlider(min=-9.8, max=9.8, description='gyro_'+s) for s in ('x', 'y', 'z')]
accel = [widgets.FloatSlider(min=-9.8, max=9.8, step=0.01, description='accel_'+s) for s in ('x', 'y', 'z')]
display(delay)
for i in range(3):
    display(gyro[i])
for i in range(3):   
    display(accel[i])
```
---
```python
is_imu_thread = True

from pop.Pilot import IMU
imu = IMU()

def onReadIMU():
    while is_imu_thread:
        gyro[0].value, gyro[1].value, gyro[2].value = imu.getGyro().values()
        accel[0].value, accel[1].value, accel[2].value = imu.getAccel().values()

        time.sleep(delay.value/1000)

Thread(target=onReadIMU).start()
```
---
```python
is_imu_thread = False
```
