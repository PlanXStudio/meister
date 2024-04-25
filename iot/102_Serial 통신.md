# Serial 통신
XNode에서 시리얼로 전송한 센서 데이터를 PC에서 수신  
시리얼 통신 전송 속도는 기본적으로 115200bps

## XNode
- IMU의 read()는 다양한 관성 센서값 반환. IMU.ACCELRATION은 가속도 값
- 마이크로파이썬에서 print()는 바이트 문자열을 시리얼로 상대방(PC)에 전송

> imu.py
```python
from xnode.pop.ext import IMU
from time import sleep

imu = IMU() # IMU 객체 생성
imu.init()

while True:
    x, y, z = imu.read(IMU.ACCELERATION)
    print(x, y, z)
    sleep(20/1000)
```

**포트 확인**
```sh
xnode scan
```

**정상적으로 실행되는지 확인**
```sh
xnode --sport <your_port> run imu.py
```

**마이크로파이썬 코드를 실행한 후 xnode 툴은 종료**
- 시리얼 통신은 1:1 통신이므로 xnode에서 시리얼 포트를 잡고 있으면, 다른 프로그램에서 해당 포트를 사용할 수 없음

```sh
xnode --sport <your_port> run -n imu.py
```

## PC
- Serial의 readline()은 시리얼 수신 버퍼에서 줄 단위((\n)로 데이터 읽기
- 수신한 문자열은 바이트 문자열이므로 decode()로 파이썬 문자열(유니코드)로 변환
- split()는 구분 문자를 이용해 단어 단뤼로 분리한 후 리스트의 요소에 대입
- float()는 실수 문자열을 실수로 변환
- abs()는 음수를 양수로 변환
- Serial의 reset_input_buffer()는 수신 버퍼를 모두 비움

```python
from serial import Serial
from time import sleep

serial = Serial("com10", 115200) # Serial 객체 생성. com10은 <your_port>

while True:
    ret = serial.readline().decode() 
    x = abs(float(ret.split(' ')[0]))

    #TODO: if x < n ... elif x < m ... else

    sleep(20/1000)
    serial.reset_input_buffer()
```
