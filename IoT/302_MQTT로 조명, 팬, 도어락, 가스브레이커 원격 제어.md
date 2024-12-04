# MQTT로 도어락, 가스브레이커 원격 제어
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

### 펌웨어

**firm_total_ctrl.py**  
```python
from xnode.pop.autoctrl import PWM
from xnode.pop.autoctrl import Relay, DIO
import time

"""
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
protocals
<device name>   [group name]    <action>
gasbreaker      none            open | close | stop
fan             none            0..100
doorlock        none            statechange
light           1 | 2           on | off
"""


pwm = PWM()
doorlock = Relay(DIO.P_RELAY[0])    #relay 1 -> doorlock
light1 = Relay(DIO.P_RELAY[1])      #relay 2 -> light1
light2 = Relay(DIO.P_RELAY[2])      #relay 3 -> light2

def setup():
    pwm.init()
    pwm.freq(1000)

def loop():
    cmd = input().lower().split()  # ["gasebreaker", "none", "open"] 
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
