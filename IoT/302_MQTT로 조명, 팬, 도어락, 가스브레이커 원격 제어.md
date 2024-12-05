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

분석 결과를 토대로 다음과 같이 프로토콜을 정의합니다.
```sh
<device name>   <group name>    <action>
```

정의한 프로토콜을 충족하려면 PC는 Auto 제어기로 다음과 같은 형식의 문자열을 전송해야 합니다.
``` sh
gasbreaker      none            open | close | stop
fan             none            0..100
doorlock        none            statechange
light           1 | 2           on | off
```

### 펌웨어 구현

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
    cmd = input().lower().split()  # ["gasebreaker", "none", "open"] 
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

**serial_total_ctrl.py**  
```python
from serial import Serial

XNODE_PORT = "COM20" # 자신의 COM 포트로 변경할 것
ser = Serial(XNODE_PORT, 115200, inter_byte_timeout=1)

def main():
    while True:
        device = input("Enter of Devic: ") # gasbreaker | fan | doorlock | light
        group = input("Enter of Group: ") # none | 1 | 2
        action = input("Enter of Action: ") # open | close | stop | 0..100 | statechange | on | off
        
        cmd = f"{device} {group} {action}\r".encode()
        print(">>> Write:", cmd)
        
        ser.write(cmd)

if __name__ == "__main__":
    main()
```

**bridge_total_ctrl.py**
```python
from serial import Serial
import paho.mqtt.client as mqtt
import json


XNODE_PORT = "COM20" # 자신의 COM 포트로 변경할 것
TOPIC_IOT_TOTAL = "asm/iot/total/#"
"""
topic                       payload {"group":<value>, "action":<value>}
asm/iot/total/gasbreaker    none    open | 1close | stop
asm/iot/total/fan           none    0..10
asm/iot/totla/doorlock      none    statechange
asm/iot/totla/light         1 | 2   on | off
"""

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
