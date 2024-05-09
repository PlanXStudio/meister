# Python for IoT

## XNode Tools
> XNode, AutoCtrl 등 마이크로파이썬 기반 IoT 장비 제어
  
### 설치
```sh
pip install xnode genlib s2u smon quat3d
```

### xnode 툴 사용법
> XNode와 PC를 USB 케이블로 연결한 후 진행
>> XNode 전원 ON

**포트 확인**
```sh
xnode scan
```

**초기화**
```sh
xnode --sport <port> init
```

**코드 실행 1**
> 기본 실행
```sh
xnode --sport <port> run <you_file>.py
```

**코드 실행 2**
> 입력 Echo 끄기
```sh
xnode --sport <port> run -ni <you_file>.py
```

**코드 실행 3**
> 코드를 실행한 후 xnode 툴 종료
```sh
xnode --sport <port> run -n <you_file>.py
```

## 기본 패턴

### 제어문
**XNode (imu_xnode.py)**
```python
from xnode.pop.ext import IMU 
from time import sleep

imu = IMU()
imu.init()

while True:
    x, y, z = imu.read(IMU.ACCELERATION)
    print(x, y, z) # b"-0.4 -0.1 9.4\r\n"
    sleep(20 * 1/1000) # 20ms
```
```sh
xnode --sport <port> run -n imu_xnode.py
```

**Pc**
```python
from serial import Serial 
from time import sleep

ser = Serial("com10", 115_200)

while True:
    ret = ser.readline().decode()
    x = abs(float(ret.split(' ')[0])) 
    if x < 1.0:
        print("small")
    elif x < 5.0:
        print("medium")
    elif x < 10.0:
        print("large") 
    else:
        print("xxx")
        
    sleep(20/1000)
```

### 프로세싱 구조와 함수
**XNode (imu_processing_xnode.py)**
```python
from xnode.pop.ext import IMU 
import time 

imu = None

def setup():
    global imu
    imu = IMU()
    imu.init() 
 
def loop():
    x, y, z = imu.read(IMU.ACCELERATION)
    print(x, y, z)
    time.sleep(20 * 1/1000)

if __name__  == '__main__':
    setup()
    while True:
        loop()
```
```sh
xnode --sport <port> run -n imu_processing_xnode.py
```

**Pc**
```python
from serial import Serial 
from time import sleep

ser = None

def setup():
    global ser
    ser = Serial("com10", 115_200)
    
def loop():
    ret = ser.readline().decode()
    
    x = abs(float(ret.split(' ')[0])) 
    if x < 1.0:
        print("Safety")
    elif x < 5.0:
        print("Caution")
    elif x < 10.0:
        print("Danger") 
    else:
        print("Calamity")
        
    sleep(20/1000)

if __name__  == '__main__':
    setup()
    while True:
        loop()
```

### 클래스
**XNode (imu_class_xnode.py)**
```python
import time
from xnode.pop.ext import IMU

class Processing:
    def __init__(self):
        self.setup()
        while True:
            self.loop()
    
    def setup(self):
        self.imu = IMU()
        self.imu.init()
    
    def loop(self):
        x, y, z = self.imu.read(IMU.ACCELERATION)
        print(x, y, z)
        time.sleep(20 * 1/1000)
        
if __name__ == "__main__":
    Processing()
```
```sh
xnode --sport <port> run -n imu_class_xnode.py.py
```

**Pc**
```python
import sys
import time
import signal
import playsound
from serial import Serial
from multiprocessing import Process

class Processing:
    def __init__(self):
        signal.signal(signal.SIGINT, self.cleanup)
        self.setup()
        while True:
            self.loop()
    
    def setup(self):
        print("call setup")

    def loop(self):
        print("call loop")
        time.sleep(1)

    def cleanup(self, *args):
        sys.exit(0)

class SimpleMp3Player(Processing):
    def __init__(self):
        super().__init__()
    
    def setup(self):
        self.ser = Serial("com10", 115_200)
        self.flags = 0.0
        self.process = None
    
    def loop(self):   # "-0.14 0.15 1.5\r\n" --> ["-0.14", "0.15", "1.5\r"]
        x = abs(float(self.ser.readline().decode().split(" ")[0]))
        if self.flags != x:
            self.flags = x
            
        if 5.0 < self.flags <= 7.0:
            if self.process:
                self.process.terminate()
            self.process = Process(target=playsound.playsound, args=("beatles_yellow_submarine.mp3",))
            self.process.start()
        elif 7.0 < self.flags <= 10.0:
            if self.process:
                self.process.terminate()
            self.process = Process(target=playsound.playsound, args=("led_zeppelin_stairway_to_heaven.mp3",))
            self.process.start()
        elif 10.0 < self.flags:
            if self.process:
                self.process.terminate()
            self.process = Process(target=playsound.playsound, args=("acdc_thunderstruck.mp3",))
            self.process.start()
            
if __name__ == "__main__":
    SimpleMp3Player()
```
