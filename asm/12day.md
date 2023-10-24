# Zigbee 기반 XNode 제어를 위한 MicroPython 프로그래밍 심화

## Processing(Arduino) 프로그래밍 구조 적용
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
```
- setup() 함수의 역할은 무엇인가?
- loop() 함수의 역할은 무엇인가?
- setup()과 loop() 함수에서 공유할 객체는 어떻게 사용하는가?
- [심화] main() 함수의 while 루프에서 sleep()을 사용하는 이유는 무엇인가?


## UART 수신 처리
> Uart 객체를 만든 후 read() 메소드로 xnode가 수신한 데이터 읽기
>> xnode -p<포트번호> run -i <MicroPython스크립트>

```python
from time import sleep
from pop import Uart

uart = None

def setup():
    global uart
    uart = Uart()

def loop():
    oneByte = uart.read(1)
    uart.write("> %s\n"%oneByte)

def main():
    setup()
    while True:
        loop()
        sleep(0.01)

if __name__ == "__main__":
    main()
```
- <TAB>에 대한 바이트 문자열은 무엇인가?
- <SPACE>에 대한 바이트 문자열은 무엇인가?
- <BACKSPACE>에 대한 바이트 문자열은 무엇인가?
- <ENTER>에 대한 바이트 문자열은 무엇인가?

## UART 줄 단위 수신 함수(readLine()) 구현
> 줄 단위 수신은 1바이트씩 <ENTER> 전까지 누적해 읽음

```python
def readLine():
    buffer = ""
    while True:
        oneByte = uart.read(1)
        
        if oneByte == b"\r":
            return buffer
        elif oneByte == b"\x08": 
            continue
        else:
            buffer += oneByte.decode()
```
- 왜 1바이트씩 읽어 처리하는가?
- Uart() 객체로 읽은 데이터를 decode()로 변환하는 이유는?

## UART 줄 단위 송신 함수(writeLine()) 구현
> 송신할 문자열 끝에 <ENTER>를 추가해 write() 메소드에 전달
>> write() 메소드에 문자열을 전달하면 xnode는 이를 바이트 문자열로 바꿔 송신
```python
def writeLine(buffer):
    buffer += "\n"
    uart.write(buffer)
```

## UART로 XNode를 제어하는 통합 스크립트 작성
- PC에서 명령을 전송하면 XNode는 Uart로 이를 수신한 후 해당 작업 수행
 Led, Battery, AmbientLight, Tphg, Uart 객체 사용  
- 페이로드 정의
  - <명령> [옵션]
    - led
      - on 또는 off 옵션에 따라 LED 켜고 끄기
    - battery
      - 배터리 전압 송신
    - light
      - 주변광 밝기 송신
    - tphg
      - temp, humi, all 옵션에 따라 온도 또는 숩도 또는 온도, 습도 송신
  - 명령 또는 옵션이 형식에 벗어나면 오류 메시지 송신  

<details>
<summary>전체 코드</summary>

```python
from time import sleep
from pop import Uart
from pop import Led, Battery, AmbientLight, Tphg, Uart

led, battery, light, tpht, uart = None, None, None, None, None

def readLine():
    buffer = ""
    while True:
        oneByte = uart.read(1)
        
        if oneByte == b"\r":
            return buffer
        elif oneByte == b"\x08": #backspace
            continue
        else:
            buffer += oneByte.decode()

def writeLine(buffer):
    buffer += "\n"
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
            
        if cmd[0] == "led" and len(cmd) == 2:
            doLed(cmd[1])
        elif cmd[0] == "battery" and len(cmd) == 1:
            doBattery()
        elif cmd[0] == "light" and len(cmd) == 1:
            doLight()
        elif cmd[0] == "tphg" and len(cmd) == 2:
            doTphg(cmd[1])
        else:
            writeLine("Unknown command")
    ```
  - [심화] if문 대신 딕셔너리로 해당 함수를 한 번에 호출하도록 수정해 보라.
