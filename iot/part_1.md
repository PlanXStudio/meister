# IoT 개발환경 for 마이크로컨트롤러
## 실습환경
- PC와 XNode를 USB 케이블(A to microB)로 연결 (시리얼 통신)
  - XNode는 고성능 마이크로컨트롤러(Cortex-M4)와 Zigbee 모뎀(저전력 개인무선통신)으로 구성
  - 마이크로파이썬(마이크로컨트롤러를 위한 파이썬 축소 버전)으로 동작
- XNode의 전원 ON (실습이 끝나면 반드시 OFF 할 것!) 

### VSCode 통합개발환경 설치
- [VSCode 다운로드](https://koreaoffice-my.sharepoint.com/:u:/g/personal/devcamp_korea_ac_kr/EeZDFUrmbqBBsFNwhkXNGdQB0QnclPjdaY_rTfOzJssBNQ?e=mpFaKY)
  - C:\에 압축해제
    - 결과: C:\VSCode
  - 사용자 환경 변수 PATH에 실행 파일 경로 추가 (첫 줄로 이동)
    ```sh
    sysdm.cpl
    ```
    
    - 고급 > 한경 변수 > 사용자 변수 > Path
      ```sh
      C:\VSCode\ext\python
      ```
      ```sh
      C:\VSCode\ext\python\Scripts
      ```

### XNode 제어
- VSCode의 터미널창에서 진행

**시리얼 포트 찾기**
```sh
xnode scan
```

** PC의 마이크로파이썬 스크립트를 XNode에 차례로 전달하면서 실행**
```sh
xnode -p com3 run app.py
```
>  스크립트가 끝날 때까지 시리얼 출력을 기다림

- 추가 옵션
  - -n: 시리얼 출력을 기다리지 않으므로 PC 쪽에서는 프로그램이 종료한 것처럼 보임 
    - 스크립트는 XNode에서 계속 실행됨
    - XNode에서 시리얼로 출력하는 데이터를 다른 툴(PuTTY, smon 등)로 확인할 때 사용
  - -i: PC의 키보드 입력을 시리얼을 통해 XNode에서 실행 중인 스크립트에 전달
    - XNode에서 실행 중인 스크립트는 시리얼로부터 데이터를 읽는 구문이 구현되어 있어야 함
    - 누른 키를 터미널 창에 표시함 (Echo on)
  - -ni (또는 -n -i): -i와 같으나 누른 키를 터미널 창에 표시하지 않음 (Echo off)
    
## IoT 프로그래밍
### 마이크로컨트롤러를 위한 Processing 프로그래밍 구조
> 프로세싱은 예술가를 위해 언어로 멀티미디어 프로그래밍에 사용되었으며 Arduino도 이 구조를 채택함

```python
from time import sleep

def setup():
    pass

def loop():
    pass

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
xnode -p<포트번호> run <MicroPython스크립트>
```

- 다음 질문에 답하시오.
  - from ~ import 문장의 의미는 무엇인가? 
  - 함수란 무엇인가?
  - setup() 함수의 역할은 무엇인가?
  - loop() 함수의 역할은 무엇인가?
  - setup()과 loop() 함수에서 공유할 객체는 어떻게 사용하는가?
  - main() 함수에 포함된 while True: 문장의 의미는 무엇인가?
  - [심화] main() 함수의 while 루프에서 sleep()을 사용하는 이유는 무엇인가?

### UART 송수신 처리
- Uart 객체 생성 후 버퍼에 읽고 쓰기
  - read() 메소드로 버퍼에서 xnode가 수신한 데이터 읽기
  - write() 메소드로 버퍼에 PC에 전송할 데이터 쓰기
    - print() 함수로 대체 가능
> xnode -p<포트번호> run -i <MicroPython스크립트>

```python
from time import sleep
from pop import Uart

uart = None

def setup():
    global uart
    uart = Uart()

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
- 다음 질문에 답하시오.
  - PC에서 데이터를 전송하지 않으면 어떻게 되는가?
  - PC에서 전송한 \<TAB\>의 수신 결과는 무엇인가?
  - PC에서 전송한  \<SPACE\>의 수신 결과는 무엇인가?
  - PC에서 전송한 \<BACKSPACE\>의 수신 결과는 무엇인가?
  - PC에서 전송한 \<ENTER\>의 수신 결과는 무엇인가?
  - 바이트 문자열과 파이썬 문자열의 차이점은 무엇인가?
    - b'Hello" VS 'Hello'

### UART 줄 단위 수신 함수(readLine()) 구현
> 줄 단위 수신은 1바이트씩 <ENTER> 전까지 누적해 읽음

```python
EOL_R = b'\r'

def readLine():
    buffer = ""
    while True:
        oneByte = uart.read(1)
        
        if oneByte == EOL_R:
            return buffer
        else:
            buffer += oneByte.decode()
```
- 다음 질문에 답하시오.
  - readLine() 함수를 정의하는 이유는 무엇인가? 
  - readLine() 함수는 왜 수신 버퍼에서 데이터를 1바이트씩 읽어 처리하는가?
  - Uart() 객체의 read() 메소드로 읽은 데이터를 decode()로 변환하는 이유는 무엇인가?

### UART 줄 단위 송신 함수(writeLine()) 구현
> 송신할 문자열 끝에 <ENTER>를 추가해 write() 메소드에 전달
>> write() 메소드에 문자열을 전달하면 xnode는 이를 바이트 문자열로 바꿔 송신
```python
EOL_W = '\n'

def writeLine(buffer):
    buffer += EOL_W
    uart.write(buffer)
```
- 다음 질문에 답하시오.
  - write() 메소드는 왜 전달받은 파이썬 문자열을 바이트 문자열로 바꿔 쓰기 버퍼에 저장하는가?
  - 문자열 끝에 줄바꿈 문자를 추가해 전송하면 어떤 장점이 있는가? 


### UART로 XNode를 제어하는 통합 스크립트 작성
- PC에서 명령을 전송하면 XNode는 Uart로 이를 수신한 후 해당 작업 수행
  - Led, Battery, AmbientLight, Tphg, Uart 객체 사용  
- 데이터 형식 정의
  - <명령> [옵션]
    - led
      - 옵션: on 또는 off 옵션에 따라 LED 켜고 끄기
    - battery
      - 배터리 전압 송신. 옵션 없음
    - light
      - 주변광 밝기 송신. 옵션 없음
    - tphg
      - 옵션: temp, humi, all 옵션에 따라 온도 또는 습도 또는 온도, 습도 송신
  - 명령 또는 옵션이 형식에 벗어나면 오류 메시지 송신  

<details>
<summary>전체 코드</summary>

```python
from time import sleep
from pop import Uart
from pop import Led, Battery, AmbientLight, Tphg

EOF_R = b'\r'
EOF_W = '\n'

led, battery, light, tpht, uart = None, None, None, None, None

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
    global led, battery, light, tphg, uart
    
    led, battery, light, tphg, uart = Led(), Battery(), AmbientLight(), Tphg(), Uart()
   
def loop():
    cmd = readLine().lower().split(" ")
            
    if cmd[0] == "led" and len(cmd) == 2:
        if cmd[1] == "on":
            led.on()
        elif cmd[1] == "off":
            led.off()
        else:
            writeLine("Unknown option")
    elif cmd[0] == "battery" and len(cmd) == 1:
        ret = "%.1f Volt"%(battery.read())
        writeLine(ret)
    elif cmd[0] == "light" and len(cmd) == 1:
        ret = "%d lux"%(light.read())
        writeLine(ret)
    elif cmd[0] == "tphg" and len(cmd) == 2:
        temp, _, humi, _ = tphg.read()
        if cmd[1] == "temp":
            ret = "%.1f C"%(temp)
            writeLine(ret)
        elif cmd[1] == "humi":
            ret = "%.1f %%"%(humi)
            writeLine(ret)
        elif cmd[1] == "all":
            ret = "%.1f C, %.1f %%"%(temp, humi)
            writeLine(ret)
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

- 다음 질문에 답하시오.
  - 다음 코드의 의미는 무엇인가?
    ```python
    led, battery, light, tphg, uart = Led(), Battery(), AmbientLight(), Tphg(), Uart()
    ```
  - 다음 코드의 의미는 무엇인가?
    ```python
    cmd = readLine().lower().split(" ")
    ```
  - loop() 구조를 다음 요구에 맞게 수정해 보라
    - 해당 명령을 각각 doLed(), doBattery(), doLight(), doTpgh() 함수에서 처리되도록 변경했다. 해당 함수를 구현하라.
      ```python
      def loop():
          cmd = readLine().lower().split(" ")
            
          if cmd[0] == "led":
              doLed(cmd)
          elif cmd[0] == "battery":
              doBattery(cmd)
          elif cmd[0] == "light":
              doLight(cmd)
          elif cmd[0] == "tphg":
              doTphg(cmd)
          else:
              writeLine("Unknown command")
      ```
  - [심화] if문 대신 딕셔너리로 해당 함수를 한 번에 호출하도록 수정해 보라.


### PC 프로그래밍
**XNode를 위한 PC 시리얼 통신 프로그램 작성**
> PC에는 pyserial 라이브러리가 설치되어 있어야 함
>> pip install pyserial
```python
from serial import Serial
from time import sleep

PORT = "COM10"

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
- XNode에서 시리얼 포트를 독점하지 않도록 주의
  ```sh
  xnode -p<포트번호> run -n <MicroPython스크립트>
  ```
- XNode MicorPython 스크립트를 실행한 후 PC Python 스크립트 실행
  ```sh
  python <Python스크립트>
  ```
