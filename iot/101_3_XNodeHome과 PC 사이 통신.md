# 실습장치와 PC 사이 통신
```sh
            |------<송신 버퍼>-----   -------<수신 버퍼>-----|  
<실습장치><포트>                     X                     <포트><PC>  
            |------<수신 버퍼>-----   -------<송신 버퍼>-----|  
```

## 실습장치에서 시리얼 통신
실습장치에서 시리얼 포트로 데이터를 보내고 받을 때는 표준함수인 input(), print() 또는 pop 라이브러리에서 제공하는 Uart.read()/Uart.readLine(), Uart.write() 사용

### 파이썬 표준 입출력
- print()는 문자열 출력 결과를 표준 출력 버퍼(STDOUT)에 전달
  - STDOUT은 운영체제에서 관리
  - 운영체제는 STDOUT에 저장된 문자열을 그래픽 어댑터의 텍스트 버퍼에 전달
  - 그래픽 어댑터는 텍스트 버퍼 내용을 명령 프롬프트 같은 텍스트 출력창에 표시
- input()는 표준 입력 버퍼(STDOUT)에 마지막에 줄바꿈 문자(<ENTER> 문자)가 포함된 문자열을 읽음
  - STDIN은 운영체제에서 관리
  - 운영체제는 키보드가 <ENTER>를 입력할 때까지 앞서 입력한 문자들을 STDIN에 저장

### 마이크로파이썬의 print()와 input()
- 마이크로파이썬 인터프리터는 STDOUT을 시리얼의 출력 버퍼에 전달
  - print()는 시리얼 송신
- 마이크로파이썬 인터프리터는 시리얼 입력 버펀을 STDIN에 전달
  - input()은 시리얼 수신

### pop 라이브리리와 시리얼 통신
- Uart 객체를 통해 시리얼 송수신 지원. 문자열은 내부에서 인코딩/디코딩 처리
  - write(): 문자열을 시리얼로 전송
  - read(): 시리얼로부터 일정 크기의 문자열 수신. 수신된 문자열이 읽을 크기보다 작으면 모두 읽을 때까지 대기함
  - readLine(): 시리얼로부터 줄단위 문자열 수신. 줄단위 문자가 수신될 때까지 대기함

## PC에서 시리얼 통신
PC의 시리얼 포트에서 파이썬으로 데이터를 읽고 쓰려면 pyserial 라이브러리 사용하며, xnode 툴을 설치하면 함께 설치됨 

### pyserial

다음 명령으로 PC에 pyserial이 설치되었는지 확인
```sh
pip list | findstr "pyserial"
```

만약 설치되어 있지 않다면 다음과 같이 설치
```sh
pip install pyserial
```

pyserial이 Serial 객체로 PC이 시리얼 포트에서 데이터를 읽고 쓸 수 있음
- Serial(port, baudrate): 시리얼 객체 생성
  - port: 사용할 포트 이름. 실습장치가 연결된 포트 사용
  - baudrate: 전송속도. **115200**으로 설정
- in_waiting: 프로퍼티로 현재 수신 버퍼에 저장된 바이트 문자열 크기
- out_waiting: 프로퍼티로 현재 송신 버퍼에 저장된 바이트 문자열 크기
- write(): 바이트 문자열을 시리얼로 전송. 문자열은 전송 전에 반드시 바이트 문자열로 변환해야 함
  - 대량의 데이터를 전송할 때는 out_waiting으로 송신 버퍼의 여유 크기를 확인하면서 전송.
- flush() 송신 버퍼의 내용을 강제로 전송함
- read(): 시리얼로부터 일정 크기의 바이트 문자열 수신. 수신된 바이트 문자열이 읽을 크기보다 작으면 모드 읽을 때까지 대기함
  - 현재 수신된 모든 데이터를 읽을 때는 in_waiting을 인자로 사용
- readline(): 시리얼로부터 줄단위 문자열 수신. 줄단위 바이트 문자가 수신될 때까지 대기함
- reset_input_buffer(): 수신 버퍼를 모두 비움
- reset_output_buffer(): 송신 버퍼를 모두 비움
- close(): 통신 종료

### 에코 테스트
PC에서 전송한 문자열을 실습장비가 다시 PC로 전송함으로써 정상적으로 통신이 수행됨을 확인

1. PC에서 실습장비를 위한 새 파일(serial_xnode.py)을 만든 후 다음 코드 입력
```python
from xnode.pop.core import Uart

def setup():
    pass

def loop():
    cmd = Uart.readLine()
    Uart.write(cmd)
        
if __name__ == "__main__":
    setup()
    while True:
        loop()
```

- 마이크로파이썬의 input(), print() 대신 pop 라이브러리의 Uart.readLine()과 Uart.write() 권장
  - input(), print()는 PC에서 pyserial로 데이터를 주고 받을 때 추가 처리 필요
    
2. xnode 툴의 run 명령으로 작성할 파일을 실행한 후 오류가 없는지 결과 확인
```sh
xnode --sport com11 run serial_xnode.py
```
- 문자열을 입력한 후 \<Enter>를 누르면, 실습장비에서 수신한 문자열을 다시 PC로 전송함
- 오류가 없으면 \<Ctrl>+c를 눌러 xnode 툴 종료 

3. xnode 툴을 강제로 종료한 후 다시 run -n 명령으로 작성한 파일을 실습장비에 실행 및 xnode 툴 종료
```sh
xnode --sport com4 run -n serial_xnode.py
```

4. PC를 위한 새 파일(serial_pc.py)을 만든 후 다음 코드 입력
```python
from serial import Serial 

ser = Serial("COM4", 115_200)

while True:
    data = input(">")
    ser.write((data + '\n').encode())
    ret = ser.readline().decode()
    print(ret)
```

5. 작성한 파일을 python 인터프리터로 PC에서 실행
```sh
python serial_pc.py
```
- 문자열을 입력한 후 \<Enter>를 누르면 실습장비로 문자열이 전송되고, 실습장비에서 다시 PC 보낸 문자열을 읽어 화면에 표시

## 시리얼 통신 응용
실습장비의 확장 포트에 IMU 확장을 꼽은 후 PC에서 시리얼 통신으로 실습장비의 가속도 센서값을 읽은 후 필요한 응용 구현  
관성 센서는 가속도(3축), 각속도(3축), 지자기(3축)으로 구성되며, 자동차, 드론 등에서 충격 감지, 자세 제어 등에 활용 
- 가속도(액설러미터): 해당 축 방향에 가해진 순간 충격 또는 기울기
- 각속도(자이로스코프): 해당 축 방향으로 순간 회전한 각도 
- 지자기(마그네틱): 해당 축 방향의 자성 세기

축은 직선 방향을 나타내며 XNode 모트를 바닦에 놓은 상태에서 x, y 축은 IMU 확장에 인쇄된 그램으로 확인, z축은 하늘과 땅을 잇는 선  

### 실습장비의 IMU 센서값을 PC에서 읽기
  
**실습장비(imu_xnode.py)**
```python
from xnode.pop.core import Uart
from xnode.pop.ext import IMU 
from time import sleep_ms

imu = IMU() 
imu.init()  #초기화(반드시 필요함!)

while True:
    x, y, z = imu.read(IMU.ACCELERATION)
    Uart.write(x, y, z) #바이트 문자열이 PC로 전달됨. (예: b"-0.4 -0.1 9.4\r\n")
    sleep_ms(20) #20ms
```

**PC(imu_pc.py)**
```python
from serial import Serial 
from time import sleep

ser = Serial("com4", 115_200)

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

### 프로세싱 구조 적용
아두이노에서 채택한 프로세싱 구조는 미디어아트를 위한 프로그래밍 방식 중 하나로 이미지를 출력하는 draw() 대신 범용 무한루 프인 loop() 사용
  
**실습장비(imu_processing_xnode.py)**
```python
from xnode.pop.core import Uart
from xnode.pop.ext import IMU 
import time 

imu = IMU()

def setup():
    imu.init() 
 
def loop():
    x, y, z = imu.read(IMU.ACCELERATION)
    Uart.write(x, y, z)
    time.sleep_ms(20)

if __name__  == '__main__':
    setup()
    while True:
        loop()
```

**PC(imu_processing_pc.py)**
```python
import sys
import signal
from serial import Serial
from time import sleep

ser = Serial("com4", 115_200)

def setup():
    pass
    
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

def cleanup(*args):
    ser.close()
    sys.exit(0)

if __name__  == '__main__':
    signal.signal(signal.SIGINT, self.cleanup)
    setup()
    while True:
        loop()
```

### 클래스로 확장
가속도 값의 크기에 따라 PC에서 해당 음악 재생  
음악 재생을 위해 다음과 같이 playsound 라이브러리를 설치한 후 재생할  MP3 음악 파일 준비

```sh
pip install playsound=1.2.2
```

**실습장비(imu_class_xnode.py)**
```python
from xnode.pop.core import Uart
from xnode.pop.ext import IMU
import time

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
        Uart.write(x, y, z)
        time.sleep_ms(20)

if __name__ == "__main__":
    Processing()
```

**PC(imu_class_pc.py)**
> 클래스 상속을 통한 오버라이딩 기법 적용

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
        self.ser = Serial("com4", 115_200)
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

    def cleanup(self, *args):
        ser.close()
        suprt().cleanup()
            
if __name__ == "__main__":
    SimpleMp3Player()
```
