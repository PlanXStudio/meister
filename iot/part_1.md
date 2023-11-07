# IoT 개발환경 for 마이크로컨트롤러
## 실습환경
- PC와 실습장치(이하 Auto 제어기)를 USB 케이블(A to microB)로 연결 (시리얼 통신)
  - Auto 제어기에는 고성능 마이크로컨트롤러(Cortex-M4)와 Zigbee 모뎀(저전력 개인무선통신), 릴레이, PWM 컨트롤러, 터미널 포트 등이 포함되어 있음
  - 마이크로파이썬(마이크로컨트롤러를 위한 파이썬 축소 버전)으로 동작
- 케이블링 (수행평가 항목임!)
  - Auto 제어기에 12V DC 전원 어댑터 연결
  - USB 허브에 5V DC 전원 어댑터 연결(마이크로USB B 커넥터)
    - 전용 데이터 케이블을 PC에 연결 (전용 포트)
  - FAN을 릴레이 채널3에 연결 (O, GND)
  - 전등을 릴레이 채널2에 연결 (O, GND)
  - 도어락을 릴레이 채널1에 연결 (C, O)
    
### VSCode 통합개발환경 설치
- [VSCode 다운로드](https://koreaoffice-my.sharepoint.com/:u:/g/personal/devcamp_korea_ac_kr/EeZDFUrmbqBBsFNwhkXNGdQB0QnclPjdaY_rTfOzJssBNQ?e=mpFaKY)
- C:\에 압축해제 (반디집 권장)
   - 결과: C:\VSCode
- 사용자 환경 변수 PATH에 python.exe(파이썬 인터프리터), pip.exe(외부 파이썬 라이브러리 설치 툴) 경로 추가
  - \<WIN\>+r 입력 후 실행창이 표시되면 다음 명령 실행
    ```sh
    sysdm.cpl
    ```
  - 시스템 속성창이 표시되면 "고급 > 환경 변수"를 선택한 후 "사용자 변수" 목록에서 "Path" 항목 더블클릭
  - 빈 칸을 더블클릭한 후 아래 경로 추가
    ```sh
    C:\VSCode\ext\python
    ```
    ```sh
    C:\VSCode\ext\python\Scripts
    ```
  - "위로 이동" 버튼으로 추가한 항목을 순으로 가장 앞으로 이동
- 결과 확인을 위해 C:/VSCode/code.exe를 실행한 후 메뉴에서 "터미널 > 새 터미널" 실행
  ```sh
  python --version
  ```
  ```sh
  pip --version
  ```

### Auto 제어기 제어 명령
- VSCode의 터미널창에서 진행

**시리얼 포트 찾기**
- Auto 제어기를 USB 허브에 연결하지 않은 상태에서 실행
```sh
xnode scan
```
- Auto 제어기를 USB 허브에 연결 한 후 실행 
```sh
xnode scan
```
- Auto 제어기에 할당된 자신의 포트 번호는 몇 번인가?

** Auto 제어기에서 스크립트 파일 실행**
```sh
xnode -p<포트이름> run <스크립트파일명>
```
> 스크립트가 끝날 때까지 시리얼 출력을 기다림

- 추가 옵션
  - -n: 시리얼 출력을 기다리지 않으므로 PC 쪽에서는 프로그램이 종료한 것처럼 보임 
    - 스크립트는 Auto 제어기에서 계속 실행됨
  - -i: PC의 키보드 입력을 시리얼을 통해 Auto 제어기에서 실행 중인 스크립트에 전달
    - Auto 제어기에서 실행 중인 스크립트는 시리얼로부터 데이터를 읽는 구문이 구현되어 있어야 함
    - 누른 키를 터미널 창에 표시함 (Echo on)
  - -ni (또는 -n -i): -i와 같으나 누른 키를 터미널 창에 표시하지 않음 (Echo off)

<br>

---

<br>


## IoT 프로그래밍
### 마이크로컨트롤러를 위한 Processing 프로그래밍 구조
> 프로세싱은 예술가를 위해 언어로 멀티미디어 프로그래밍에 사용되었으며 Arduino도 이 구조를 채택함

```python
from time import sleep
from pop import Uart

uart = None

def setup():
    uart = Uart()
    uart.write("Starting...\n")

def loop():
    uart.write("Loop...\n")
    sleep(1)

def main():
    setup()
    while True:
        loop()
        sleep(0.01)

if __name__ == "__main__":
    main()
```

**코드 실행**
```sh
xnode scan
```
```
xnode -p<포트번호> run <스크립트파일명>
```

**실행 종료**
- [방법1] 키보드 인터럽트로 통신 종료
  - \<CTRL\> + c
- [방법2] 시리얼 통신 강제로 종료
  - USB 케이블 분리 후 다시 연결
- [방법3] 실행 중인 스크립트 코드 강제 종료
  - Auto 제어기 전원 분리 후 다시 연결

**다음 질문에 답하시오.**
- from ~ import 문장의 의미는 무엇인가? 
- 함수란 무엇인가?
- setup() 함수의 역할은 무엇인가?
- loop() 함수의 역할은 무엇인가?
- setup()과 loop() 함수에서 공유할 객체는 어떻게 사용하는가?
- main() 함수에 포함된 while True: 문장의 의미는 무엇인가?
- [심화] main() 함수의 while 루프에서 sleep()을 사용하는 이유는 무엇인가?

### UART 송수신 처리
- Uart 클래스의 객체를 만든 후 데이터 송수신
  - read(): Auto 제어기가 수신한 데이터 읽기
  - write(): Auto 제어기에서 PC로 데이터 쓰기
    - print() 함수로 대체 가능

```python
from time import sleep
from pop import Uart

uart = None

def setup():
    global uart
    uart = Uart()
    uart.write("Starting...\n")

def loop():
    oneByte = uart.read(1)
    uart.write("> %s\n"%(oneByte)) # print("> %s\n"%(oneByte))

def main():
    setup()
    while True:
        loop()
        sleep(0.01)

if __name__ == "__main__":
    main()
```

**실행**
- PC쪽 키보드 입력을 Auto 제어기로 전달하기 위해 -i 옵션과 함께 실행
  ```sh
  xnode -p<포트번호> run -i <스크립트파일명>
  ```

**다음 질문에 답하시오.**
- PC에서 데이터를 전송하지 않으면 어떻게 되는가?
- PC에서 전송한 a 키의 수신 결과는 무엇인가?
- PC에서 전송한 A 키의 수신 결과는 무엇인가?
- PC에서 전송한 \<TAB\> 키의 수신 결과는 무엇인가?
- PC에서 전송한  \<SPACE\> 키의 수신 결과는 무엇인가?
- PC에서 전송한 \<BACKSPACE\> 키의 수신 결과는 무엇인가?
- PC에서 전송한 \<ENTER\> 키의 수신 결과는 무엇인가?
- [심화] 바이트 문자열과 파이썬 문자열의 차이점은 무엇인가?
  - b'Hello" VS 'Hello'

### UART 줄 단위 수신 함수(readLine()) 구현
- 줄 단위 수신은 1바이트씩 \<ENTER\> 전까지 누적해 읽음

```python
EOL_R = b'\r' #키보드 입력이 아니라면 b'\n'으로 변경 가능

def readLine():
    buffer = ""
    while True:
        oneByte = uart.read(1)
        
        if oneByte == EOL_R:
            return buffer
        else:
            buffer += oneByte.decode()
```

**다음 질문에 답하시오.**
- readLine() 함수를 정의하는 이유는 무엇인가? 
- readLine() 함수는 왜 1바이트씩 읽어 처리하는가?
- Uart() 객체의 read() 메소드로 읽은 데이터를 decode()로 변환하는 이유는 무엇인가?

### UART 줄 단위 송신 함수(writeLine()) 구현
- 송신할 문자열 끝에 <ENTER>를 추가해 write() 메소드에 전달
  - write() 메소드에 문자열을 전달하면 UART 객체는 내부에서 이를 바이트 문자열로 바꿔 송신

```python
EOL_W = '\n'

def writeLine(buffer):
    buffer += EOL_W
    uart.write(buffer)
```

**다음 질문에 답하시오.**
- write() 메소드는 왜 전달받은 파이썬 문자열을 바이트 문자열로 바꿔 송신하는가?
- 문자열 끝에 줄바꿈 문자를 추가해 전송하면 어떤 장점이 있는가? 

### 시리얼 통신 루프백(loopback) 테스트 스크립트
- PC에서 줄 단위로 전달한 문자열(\<ENTER\>로 종료)을 Auto 제어가 PC에 다시 전송함

```python
from time import sleep
from pop import Uart

EOF_R = b'\r'
EOF_W = '\n'

uart = None

def readLine():
    buffer = ""
    while True:
        oneByte = uart.read(1)
        
        if oneByte == EOF_R:
            return buffer
        else:
            buffer += oneByte.decode()

def writeLine(buffer):
    buffer += EOF_W
    uart.write(buffer)
    
def setup():
    global uart
    
    uart = Uart()
    writeLine("Starting...")

def loop():
    cmd = readLine()
    writeLine(cmd)
        
def main():
    setup()
    while True:
        loop()
        sleep(0.01)
    
if __name__ == '__main__':
    main()
```

**실행**
- PC에는 입력한 문자열이 표시되지 않도록 -ni 옵션과 함께 실행
  ```sh
  xnode -p<포트번호> run -ni <스크립트파일명>
  ```

<br> 

---

<br>

## 스마트 홈 프로그래밍
- Auto 제어기에 연결된 환기 팬, 조명, 도어락 제어
- PC 시리얼 스크립트를 작성해 Auto 제어기 제어

### Auto 제어기 스크립트
- PC에서 줄 단위 문자열 명령을 전송하면 Auto 제어기는 Uart로 이를 수신한 후 해당 작업 수행
- FAN, Light, DoorLock 클래스를 이용해 Auto 제어기에 연결된 환기 팬, 조명, 도어락 제어
  - FAN: 릴레이 채널3에 연결된 환기 팬 켜고 끄기
    - on() 또는 off() 메소드
  - Light: 릴레이 채널2에 연결된 조명 켜고 끄기
    - on() 또는 off() 메소드
  - DoorLock: 릴레이 채널1에 연결된 도어락 이벤트(열림 또는 닫힘) 발생
    - work() 메소드

- 문자열 데이터 형식 정의
  - <명령> [옵션]
    - fan 명령 
      - on 또는 off 옵션에 따라 환기팬 켜고 끄기
    - light 명령
      - on 또는 off 옵션에 따라 조명 켜고 끄기
    - doorlock 명령
      - 옵션은 없으며, 도어락 이벤트 생성 
- 예외 처리
  - 명령 또는 옵션이 형식에 벗어나면 오류 메시지 송신  

<details>
<summary>전체 코드</summary>

```python
from time import sleep
from pop import Uart
from pop import FAN
from pop import Light
from pop import DoorLock

EOF_R = b'\r'
EOF_W = '\n'

uart = None

fan = None
light = None
doorlock = None

def readLine():
    buffer = ""
    while True:
        oneByte = uart.read(1)
        
        if oneByte == EOF_R:
            return buffer
        else:
            buffer += oneByte.decode()

def writeLine(buffer):
    buffer += EOF_W
    uart.write(buffer)
    
def setup():
    global uart, fan, light, doorlock
    
    uart = Uart()
    writeLine("Starting...")
    
    fan = FAN() #릴레이 채널3 ('D5')
    light = Light() #릴레이 채널2 ('D6')
    doorlock = DoorLock() #릴레이 채널1 ('D0')

def loop():
    cmd = readLine().lower().split(" ")
            
    if cmd[0] == "fan":
        if  len(cmd) == 2:
            if cmd[1] == "on":
                fan.on()
            elif cmd[1] == "off":
                fan.off()
            else:
                writeLine("Unknown option")
        else:
            writeLine("Unknown command")
    elif cmd[0] == "light":
        if len(cmd) == 2:
            if cmd[1] == "on":
                light.on()
            elif cmd[1] == "off":
                light.off()
            else:
                writeLine("Unknown option")
        else:
            writeLine("Unknown command")
    elif cmd[0] == "doorlock":
        if len(cmd) == 1:
            doorlock.work()
        else:
            writeLine("Unknown option")
    else:
        writeLine("Unknown command")
        
def main():
    setup()
    while True:
        loop()
        sleep(0.01)
    
if __name__ == '__main__':
    main()
```
</details>

**실행**
```sh
xnode -p<포트번호> run -i <스크립트파일명>
```
    
**다음 질문에 답하시오.**
- setup() 함수에서 다음 코드의 의미는 무엇인가?
  ```python
  led = Led()
  light = AmbientLight()
  tphg = Tphg()
  ```
- loop() 함수에서 다음 코드의 의미는 무엇인가?
  ```python
  cmd = readLine().lower().split(" ")
  ```
- loop() 함수에 포함된 다음 선택 구조의 의미를 설명하시오.
  ```python
  if <조건>:
     <명령1>
  else:
     <명령2>
  ```
  ```python
  if <조건1>:
      <명령1>
  elif <조건2>:
      <명령2>
  else:
      <명령3>
  ```    
- loop() 함수 구조를 다음 요구에 맞게 수정해 보라. 단, 실행 결과는 기존과 같아야 한다.
  - 해당 명령을 각각 do_led(), do_light(), do_tpgh() 함수에서 처리되도록 변경했다. 해당 함수를 구현하라.
    ```python
    def do_led(cmd):
        #이곳에 해당 내용 구현1

    def do_light(cmd):
        #이곳에 해당 내용 구현2

    def do_tphg(cmd):
        #이곳에 해당 내용 구현3
      
    def loop():
        cmd = readLine().lower().split(" ")
            
        if cmd[0] == "led":
            do_led(cmd)
        elif cmd[0] == "light":
            do_light(cmd)
        elif cmd[0] == "tphg":
            do_tphg(cmd)
        else:
            writeLine("Unknown command")
    ```
- [심화] if문 대신 딕셔너리로 해당 함수를 한 번에 호출하도록 수정해 보라.

### PC 스크립트
```python
from serial import Serial
from time import sleep

PORT = "COM10" #자신의 포트 번호로 변경

def main():
    ser = Serial(PORT, 115200, timeout=0)

    ser.write("led on\r".encode())
    sleep(1)
    ser.write("led off\r".encode())
    sleep(1)
    
    ser.write("tphg all\r".encode())
    sleep(0.5)
    print(ser.readline().decode())
    
if __name__ == "__main__":
    main()
```
**실행 절차**
- Auto 제어기 스크립트를 다음과 같이 실행
  ```sh
  xnode -p<포트번호> run -n <스크립트파일명>
  ```
  
- PC 스크립트를 다음과 같이 실행
  ```sh
  python <스크립트파일명>
  ```

---


### PC 스크립트
- 1초 단위로 환기팬 켜기, 환기팬 끄기, 조명 켜기, 조명 끄기, 도어락 이벤트 발생 후 종료
<details>
<summary>전체 코드</summary>

```python
from serial import Serial
from time import sleep

PORT = "COM10" #자신의 포트 번호로 변경

def main():
    ser = Serial(PORT, 115200, timeout=0)

    ser.write("fan on\r".encode())
    sleep(1)
    ser.write("fan off\r".encode())
    sleep(1)

    ser.write("light on\r".encode())
    sleep(1)
    ser.write("light off\r".encode())
    sleep(1)
    
    ser.write("doorlock\r".encode())
    sleep(1)
    
if __name__ == "__main__":
    main()
```
</details>


### PC 스크립트를 참고해 Auto 제어기 스트립트를 구현하시오.
- 앞서 구현한 기본 기능 제어를 참고해 do_fan(), do_light(), do_doorlock() 함수 구현.
<details>
<summary>전체 코드</summary>

```python
from time import sleep
from pop import Uart
from pop import FAN
from pop import Light
from pop import DoorLock

EOF_R = b'\r'
EOF_W = '\n'

uart = None

fan = None
light = None
doorlock = None

def readLine():
    buffer = ""
    while True:
        oneByte = uart.read(1)
        
        if oneByte == EOF_R:
            return buffer
        else:
            buffer += oneByte.decode()

def writeLine(buffer):
    buffer += EOF_W
    uart.write(buffer)
    
def setup():
    global uart, fan, light, doorlock
    
    uart = Uart()
    fan = FAN() #릴레이 채널3
    light = Light() #릴레이 채널2
    doorlock = DoorLock() #릴레이 채널1

def do_fan(cmd):
    #이곳에 기능 구현1

def do_light(cmd):
    #이곳에 기능 구현2

def do_doorlock(cmd):
    #이곳에 기능 구현3

def loop():
    cmd = readLine().lower().split(" ")
            
    if cmd[0] == "fan":
        if  len(cmd) == 2:
            do_fan(cmd)
        else:
            writeLine("Unknown command")
    elif cmd[0] == "light":
        if len(cmd) == 2:
            do_light(cmd)
        else:
            writeLine("Unknown command")
    elif cmd[0] == "doorlock":
        if len(cmd) == 1:
            do_doorlock(cmd)
        else:
            writeLine("Unknown command")
    else:
        writeLine("Unknown command")
        
def main():
    setup()
    while True:
        loop()
        sleep(0.01)
    
if __name__ == '__main__':
    main()
```
</details>
