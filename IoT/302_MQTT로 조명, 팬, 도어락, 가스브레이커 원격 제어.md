# MQTT로 조명, 팬, 도어락, 가스브레이커 원격 제어
인터넷으로 연결된 컴퓨터에서 GUI 프로그램을 이용해 Auto 제어기의 PWM 컨트롤러에 연결된 가스브레이커와 팬 및 릴레이에 연결된 도어락, 조명 상태를 원격 제어합니다.

## 시스템 구성
Auto 제어기에서 실행하는 펌웨어와, PC1에서 실행하는 시리얼-인터넷 브릿지 프로그램 및 PC2에서 실행하는 GUI 프로그램으로 구성되며, 환경에 따라 PC1과 PC2는 같은 PC일 수 있습니다.

```xml
      MCU      <--- 시리얼 ---> PC1      <--- 인터넷 ---> 브로커 <--- 인터넷 ---> PC2
      펌웨어                    브릿지                                           GUI
      (micrpython)             (python, pyserial, paho-mqtt)                    (python, pyqt6, paho-mqtt)
```

### 준비물
- Auto 제어기: 1개
  - USB 케이블: 1개
  - 파워 어댑터: 1개 
  - 드라이버: 1개
  - 조명: 2개 (1조)
  - 팬: 1개
  - 도어락: 1개  
  - 가스브레이커: 1개
- PC: 2대
  - PC1: Audo 제어기와 시리얼 연결
  - PC2: PC1과 인터넷 연결

### 케이블링
GasBreaker의 Red를 PWM 포트 0,  Black은 1에 연결하고, Fan의 Red는 PWM 포트 3, Black은 GND에 연결합니다. 

```sh
                        G   
                        |         
                        Fan     GasBreaker
                        |  (Black)|    |(Red)
PWM Port -->  12V GND   3    2    1    0
```

DoorLock은 Relay 1에 Black 2선을 모두 연결하고, Light1과 Light2의 Red는 각각 Relay 2, Realy 3의 O에, Black은 각각 GND에 연결합니다.  
```sh
                              G        G
                              |        |
                  DoorLock    Light1    Light2
                   |   |           |        |
Relay Port --->    C   O      C    O    C   O
                  RELAY_1
```

## Auto 제어기 펌웨어
Auto 제어기에 연결된 장치를 제어하는데 필요한 펌웨어를 구현해 봅니다.

### 프로토콜 정의
먼저 PWM과 Relay에 연결된 장치와 이들의 동작을 분석해 봅니다.
```sh
PWM
    GaseBreaker 
        Open
        Close
        Stop
    Fan
        speed(0 ~ 100)
Relay
    DoorLock
        stateChange
    Light
        1
            on
            off
        2
            on
            off
```

분석 결과를 토대로 GaseBreaker, Fan, DoorLock, Light를 device로, Light의 1, 2를 group으로(나머지는 그룹 없음), 각 디자이스의 동작을 action으로 구분해 프로토콜 구조를 확정합니다.
```sh
<device> <group> <action>
```

따라서 PC에서 Auto 제어기로 전송하는 문자열은 다음과 같은 형식입니다.
``` sh
device          group           action
-----------------------------------------------------
gasbreaker      none            open | close | stop
fan             none            0..100
doorlock        none            statechange
light           1 | 2           on | off
```

### 펌웨어 구현
PC로부터 수신한 문자열에서 공백 문자를 기준으로 3개의 문자열로 나눈 후 deivce와 group, action을 검사해 해당 동작을 수행합니다.

```python
cmd = input().lower().split()  
```

만약 수신한 문자열이 "light 1 on"이라면 split() 결과는 리스트로 ["light", "1", "on"]입니다. 따라서 cmd[0]은 device, cmd[1]은 group, cmd[2]는 action에 해당합니다.

```python
if cmd[0] == "light":            # device
    if cmd[1] == "1":            # group
        if cmd[2] == "on":       # action
            # 조명1을 켭니다.
        elif cmd[2] == "off":
            # 조명1을 끕니다.          
```

전체 코드는 다음과 같습니다.

**firm_total_ctrl.py**  
```python
from xnode.pop.autoctrl import PWM
from xnode.pop.autoctrl import Relay, DIO
import time

pwm = PWM()                        # gasbreaker: ch[1:0], fan: ch[3]
doorlock = Relay(DIO.P_RELAY[0])   # relay 1
light1 = Relay(DIO.P_RELAY[1])     # relay 2
light2 = Relay(DIO.P_RELAY[2])     # relay 3

def setup():
    pwm.init()
    pwm.freq(1000)

def loop():
    cmd = input().lower().split()  

    if len(cmd) != 3:
        return

    if cmd[0] == "gasbreaker":
        if cmd[2] == "open":
            pwm.duty(0, 100)
            pwm.duty(1, 0)
        elif cmd[2] == "close":
            pwm.duty(0, 0)
            pwm.duty(1, 100)
        elif cmd[2] == "stop":
            pwm.duty(0, 0)
            pwm.duty(1, 0)
    elif cmd[0] == "fan":
        try:
            val = int(cmd[2])  # "95"
            pwm.duty(3, val)
        except:
            pass
    elif cmd[0] == "doorlock":
        if cmd[2] == "statechange":
            doorlock.on()
            time.sleep(0.5)
            doorlock.off()
    elif cmd[0] == "light":
        if cmd[1] == "1":
            if cmd[2] == "on":
                light1.on()
            elif cmd[2] == "off":
                light1.off()
        elif cmd[1] == "2":
            if cmd[2] == "on":
                light2.on()
            elif cmd[2] == "off":
                light2.off()
    
if __name__ == "__main__":
    setup()
    while True:
        loop()
```

## 브릿지
인터넷에서 MQTT로 구독한 토픽 메시지를 Auto 제어기 프로토콜로 변환해 시리얼로 Auto 제어기에 전송하는 브릿지를 2단계로 구현합니다.

### 1단계: 시리얼 프로토콜 확인
먼저 해당 프로토콜을 시리얼 통신으로 Auto 제어기에 전송해 해당 디바이스가 정상적으로 제어되는지 확인합니다.

**serial_total_ctrl.py**  
```python
from serial import Serial

XNODE_PORT = "COM20" # 자신의 COM 포트로 변경할 것
ser = Serial(XNODE_PORT, 115200, inter_byte_timeout=1)

def main():
    while True:
        device = input("Enter of Devic: ")     # gasbreaker | fan | doorlock | light
        group = input("Enter of Group: ")      # none | 1 | 2
        action = input("Enter of Action: ")    # open | close | stop | 0..100 | statechange | on | off
        
        cmd = f"{device} {group} {action}\r".encode()
        print(">>> Write:", cmd)
        
        ser.write(cmd)

if __name__ == "__main__":
    main()
```

### 2단계: 시리얼에 MQTT 결합
시리얼 프로토콜 확인이 끝나면 MQTT 토픽 메시지를 정의한 후 이를 구독하는 기능을 추가합니다.
프로토콜을 참조해 정의한 토픽 메시지 구조는 다음과 같습니다. 토픽은 디바이스를, 페이로드는 딕셔너리(JSON)로 그룹과 액션을 포함합니다. 
```sh
topic (device)              payload (group, action)
----------------------------------------------------------------------------------
asm/iot/total/gasbreaker    {"group":none,  "action":<"open"|"close"|"stop">}
asm/iot/total/fan           {"group":none,  "action":<0..100>}
asm/iot/totla/doorlock      {"group":none,  "action":"statechange"}
asm/iot/totla/light         {"group":<1|2>, "action":<"on"|"off">}
```

브릿지는 "asm/iot/totla/#"을 구독한 후 수신된 토픽을 검사해 device 값을 정하고, 딕셔너리 타입의 페이로드에서 "group"과 "action" 키로 group과 action 값을 얻습니다. 

브릿지의 전체 코드는 다음과 같습니다.

**bridge_total_ctrl.py**
```python
from serial import Serial
import paho.mqtt.client as mqtt
import json


XNODE_PORT = "COM20" # 자신의 COM 포트로 변경할 것
TOPIC_IOT_TOTAL = "asm/iot/total/#"

ser = Serial(XNODE_PORT, 115200, inter_byte_timeout=1)

def on_connect(*args):
    if args[3] == 0:
        print("브로커에 연결되었습니다.")
        args[0].subscribe(TOPIC_IOT_TOTAL)
    else:
        pass

def on_subscribe(*args):
    print(f"브로커에 {TOPIC_IOT_TOTAL} 토픽 구독이 등록되었습니다.")

def on_message(*args):    
    topic = args[2].topic
    try:
        group_action = json.loads(args[2].payload)
    except ValueError:
        return
    
    print(group_action)
    
    if topic == "asm/iot/total/gasbreaker":
        device = "gasbreaker"
    elif topic == "asm/iot/total/fan":
        device = "fan"
    elif topic == "asm/iot/total/doorlock":
        device = "doorlock"
    elif topic == "asm/iot/total/light":
        device = "light"
    else:
        return

    group = group_action['group']
    action = group_action['action']

    cmd = f"{device} {group} {action}\r".encode()

    print(cmd)
    ser.write(cmd)

def main():
    c = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2)
    c.on_connect = on_connect
    c.on_subscribe = on_subscribe
    c.on_message = on_message
    
    c.connect("mqtt.eclipseprojects.io")
    c.loop_forever() 
    
if __name__ == "__main__":
    main()
```

### 브릿지 테스트
XNode에 펌웨어를 실행하고 PC1에 브릿지를 실행했다면 "mqtt.eclipseprojects.io" 브로커에 연결된 MQTTX 툴로 토픽 메시지를 발행해 해당 디바이스가 제어되는지 확인합니다.  

페이로드는 JSON 형식이므로 도어락을 제어하는 토픽 메시지는 다음과 같습니다.  
<img src="res/total_mqttx1.png">   

다음은 조명을 제어하는 토픽 메시지입니다.  
<img src="res/total_mqttx2.png">   
