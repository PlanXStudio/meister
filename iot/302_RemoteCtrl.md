# MQTT로 IoT 장비 원격 제어
Auto 제어기의 PWM 컨트롤러에 연결된 팬과 조명의 속도 및 밝기를 인터넷 환경에서 GUI 프로그램을 이용해 원격 제어

## 시스템 구성
Auto 제어기에서 실행 중인 펌웨어와, PC1에서 실행하는 시리얼-인터넷 브릿지 및 PC2에서 실행하는 GUI 프로그램으로 구성 

### 준비물
- Auto 제어기: 1개
  - USB 케이블: 1개
  - 파워 어댑터: 1개 
  - 드라이버: 1개
  - 조명 패키지: 1개 (2개의 조명 포함) 
  - 팬: 2개
- PC: 2대
  - PC1: Audo 제어기와 시리얼 연결
  - PC2: PC1과 인터넷 연결
 
### 케이블링
Light1, Light2, Fan1, Fan2의 Red 선(VCC)을 PWM 포트 0, 1, 2, 3에 연결하고, Black 선은 PWM 및 DIO 포트의 GND에 연결 

## Auto 제어기
### PWM 클래스를 이용해 Auto 제어기용 펌웨어 구현
시리얼로 수신한 데이터에 따라 PWM 컨트롤러의 각 채널에 PWM 신호 출력

- PWM 클래스
  - PWM(): PWM 객체 생성
  - scan(): PWM 컨트롤러 검색. True이면 이상 없음
  - init(): PWM 컨트롤러 초기화
  - freq(n): 주파수 설정 (50 ~ 20000)
  - duty(ch, n): 채당 채널에 듀티 값에 해당하는 PWM 신호 출력
    - ch: 채널 번호 (0 ~ 3)
    - n: 튜티 값 (0 ~ 100)

- 데이터 포맷은 PWM 객체의 duty 메소드 호출에 대한 문자열
  - 예: "pwm.duty(0, 50)\r"

**firm_cond_ctrl.py**
```python
from xnode.pop.autoctrl import PWM

pwm = PWM()
pwm.init()

pwm.freq(1000)

while True:
    cmd = input().lower() # "pwm.duty(0, 50)\r"
    try:
        eval(cmd)
    except SyntaxError:
        pass
```

### 테스트
xnode 툴을 이용해 구현한 펌웨어를 Auto 제어기에 전송 및 실행한 후 제어 명령을 정의한 데이터 형식으로 전송

```sh
xnode --sport com13 run -in firm_cond_ctrl.py
```

```sh
pwm.duty(0, 30)
pwm.duty(0, 0)
pwm.duty(2, 40)
pwm.duty(2, 0)
```

## 시리얼과 인터넷 연결 브릿지
Auto 제어기와 시리얼로 연결된 PC1에서 진행하며, 인터넷에서 구독한 토픽 메시지를 Auto 제어기에 시리얼로 전달

PWM 채널에 따른 토픽 정의
- ams/iot/pwm/light/1
- ams/iot/pwm/light/2
- ams/iot/pwm/fan/1
- ams/iot/pwm/fan/2

### 시리얼 프로그램 구현
PC1에서 입력 받은 채널과 듀티 값을 묶어 PySerial을 이용해 시리얼 통신으로 Auto 제어기에 전달 

**bridge_cond_ctrl.py**
```python
from serial import Serial

ser = Serial("COM13", 115200, inter_byte_timeout=1)

def main():
    while True:
        ch = input("Enter of channel: ")
        duty = input("Enter of duty: ")
        ser.write(f"pwm.duty({ch}, {duty})\r".encode())

if __name__ == "__main__":
    main()
```

**테스트**
```sh
python bridge_cond_ctrl.py
```
```sh
Enter of channel: 0
Enter of duty: 20
```

### 브릿지 프로그램 구현
paho-mqtt를 이용해 인터넷으로 구독한 페이로드(데이터)를 시리얼을 통해 Auto 제어기에 전달
앞서 구현한 펌웨어 테스트 프로그램 수정

**bridge_cond_ctrl.py**
```python
from serial import Serial
import paho.mqtt.client as mqtt
import json

TOPIC_IOT_PWM = "asm/iot/pwm/#"
"""
asm/iot/pwm/light/1, 50
asm/iot/pwm/light/2, 50
asm/iot/pwm/fan/1, 50
asm/iot/pwm/fan/2, 50
"""

ser = Serial("COM13", 115200, inter_byte_timeout=1)

def on_connect(*args):
    if args[3] == 0:
        print("브로커에 연결되었습니다.")
        args[0].subscribe(TOPIC_IOT_PWM)
    else:
        pass

def on_subscribe(*args):
    print(f"브로커에 {TOPIC_IOT_PWM} 토픽 구독이 등록되었습니다.")

def on_message(*args):
    topic = args[2].topic
    try:
        duty = json.loads(args[2].payload)
    except ValueError:
        return

    if topic == "asm/iot/pwm/light/1":
        channel = 0
    elif topic == "asm/iot/pwm/light/2":
        channel = 1
    elif topic == "asm/iot/pwm/fan/1":
        channel = 2
    elif topic == "asm/iot/pwm/fan/2":
        channel = 3
    else:
        return
    
    ser.write(f"pwm.duty({channel}, {duty})\r".encode())

def main():
    c = mqtt.Client()
    c.on_connect = on_connect
    c.on_subscribe = on_subscribe
    c.on_message = on_message
    
    c.connect("mqtt.eclipseprojects.io")
    c.loop_forever() 
    
if __name__ == "__main__":
    main()
```

**테스트**
MQTTX를 브릿지와 같은 브로커에 연결한 후 토픽 메시지 발생

- 새 연결
  - Name: EclipseProjects
  - Host: mqtt.eclipseprojects.io
- 발행
  - Type: JSON
  - Topic: asm/iot/pwm/light/1
  - Payload: 40

## 원격 제어용 GUI
MQTT 브로커에 토픽 메시지를 발생하는 기능을 pyqt6 기반 GUI로 구현

### PyQt6용 MQTT 클라이언트 구현
**pyqt6_mqtt.py**
```python
import json
from PyQt6.QtCore import QObject, pyqtSignal as Signal
import paho.mqtt.client as mqtt

class PyQt6MqttClient(QObject):
    connectSignal = Signal(int)
    publishSignal = Signal(int)
    subscribeSignal = Signal(int, int)
    messageSignal = Signal(str, object)
    
    def __init__(self, parent=None):
        super().__init__(parent)
    
        self.client = mqtt.Client()
        self.client.on_connect = self.on_connect
        self.client.on_publish = self.on_publish
        self.client.on_subscribe = self.on_subscribe
        self.client.on_message = self.on_message
        
    def on_connect(self, client, userdata, flags, rc):
        self.connectSignal.emit(rc)
    
    def on_publish(self, client, userdata, mid):
        self.publishSignal.emit(mid)
    
    def on_subscribe(self, client, userdata, mid, granted_qos):
        self.subscribeSignal.emit(mid, granted_qos)
    
    def on_message(self, userdata, message):
        self.messageSignal.emit(message.topic, json.loads(message.payload))
    
    def connect(self, broker):
        self.client.connect(broker)
        self.client.loop_start()
    
    def publish(self, topic, payload):
        self.client.publish(topic, json.dumps(payload))
```

### 원격 제어용 GUI 구현
QT 디자이너로 화면 디자인
- groupLight1
  - diagLight1
    - 0 ~ 50 
  - fndLight1
    - digit: 2
  - dialLight1.valueChanged(int) --> fndLight1.display(int) 
- groupLight2
  - diagLight2
    - 0 ~ 50 
  - fndLight2
    - digit: 2
  - dialLight2.valueChanged(int) --> fndLight2.display(int) 
- groupFan1
  - diagFan1
    - 0 ~ 50 
  - fndFan1
    - digit: 2
  - dialFan1.valueChanged(int) --> fndFan1.display(int) 
- groupFan2
  - diagFan2
    - 0 ~ 50 
  - fndFan2 
    - digit: 2
  - dialFan2.valueChanged(int) --> fndFan2.display(int) 

![{AA354EAE-DED6-4512-A0F5-E82B38FBB5D1}](https://github.com/user-attachments/assets/0fd75a1f-e621-4142-96eb-50d38a855ca7)

**ConditionCtrl.ui**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<ui version="4.0">
 <class>MainWindow</class>
 <widget class="QMainWindow" name="MainWindow">
  <property name="geometry">
   <rect>
    <x>0</x>
    <y>0</y>
    <width>322</width>
    <height>339</height>
   </rect>
  </property>
  <property name="windowTitle">
   <string>Condition Controller</string>
  </property>
  <widget class="QWidget" name="centralwidget">
   <widget class="QGroupBox" name="groupLight">
    <property name="enabled">
     <bool>false</bool>
    </property>
    <property name="geometry">
     <rect>
      <x>10</x>
      <y>20</y>
      <width>301</width>
      <height>141</height>
     </rect>
    </property>
    <property name="title">
     <string>Light</string>
    </property>
    <widget class="QDial" name="dialLight">
     <property name="geometry">
      <rect>
       <x>20</x>
       <y>20</y>
       <width>111</width>
       <height>111</height>
      </rect>
     </property>
     <property name="maximum">
      <number>100</number>
     </property>
     <property name="singleStep">
      <number>2</number>
     </property>
     <property name="orientation">
      <enum>Qt::Horizontal</enum>
     </property>
     <property name="invertedAppearance">
      <bool>false</bool>
     </property>
     <property name="invertedControls">
      <bool>false</bool>
     </property>
     <property name="wrapping">
      <bool>false</bool>
     </property>
     <property name="notchTarget">
      <double>1.000000000000000</double>
     </property>
     <property name="notchesVisible">
      <bool>true</bool>
     </property>
    </widget>
    <widget class="QLCDNumber" name="fndLight">
     <property name="geometry">
      <rect>
       <x>190</x>
       <y>40</y>
       <width>91</width>
       <height>61</height>
      </rect>
     </property>
     <property name="frameShape">
      <enum>QFrame::WinPanel</enum>
     </property>
     <property name="frameShadow">
      <enum>QFrame::Sunken</enum>
     </property>
     <property name="smallDecimalPoint">
      <bool>false</bool>
     </property>
     <property name="digitCount">
      <number>3</number>
     </property>
    </widget>
   </widget>
   <widget class="QGroupBox" name="groupFan">
    <property name="enabled">
     <bool>false</bool>
    </property>
    <property name="geometry">
     <rect>
      <x>10</x>
      <y>180</y>
      <width>301</width>
      <height>141</height>
     </rect>
    </property>
    <property name="title">
     <string>Fan</string>
    </property>
    <widget class="QDial" name="dialFan">
     <property name="geometry">
      <rect>
       <x>20</x>
       <y>20</y>
       <width>111</width>
       <height>111</height>
      </rect>
     </property>
     <property name="maximum">
      <number>100</number>
     </property>
     <property name="singleStep">
      <number>2</number>
     </property>
     <property name="orientation">
      <enum>Qt::Horizontal</enum>
     </property>
     <property name="invertedAppearance">
      <bool>false</bool>
     </property>
     <property name="invertedControls">
      <bool>false</bool>
     </property>
     <property name="wrapping">
      <bool>false</bool>
     </property>
     <property name="notchTarget">
      <double>1.000000000000000</double>
     </property>
     <property name="notchesVisible">
      <bool>true</bool>
     </property>
    </widget>
    <widget class="QLCDNumber" name="fndFan">
     <property name="geometry">
      <rect>
       <x>190</x>
       <y>40</y>
       <width>91</width>
       <height>61</height>
      </rect>
     </property>
     <property name="frameShape">
      <enum>QFrame::WinPanel</enum>
     </property>
     <property name="frameShadow">
      <enum>QFrame::Sunken</enum>
     </property>
     <property name="smallDecimalPoint">
      <bool>false</bool>
     </property>
     <property name="digitCount">
      <number>3</number>
     </property>
    </widget>
   </widget>
  </widget>
 </widget>
 <resources/>
 <connections>
  <connection>
   <sender>dialLight</sender>
   <signal>valueChanged(int)</signal>
   <receiver>fndLight</receiver>
   <slot>display(int)</slot>
   <hints>
    <hint type="sourcelabel">
     <x>85</x>
     <y>95</y>
    </hint>
    <hint type="destinationlabel">
     <x>245</x>
     <y>90</y>
    </hint>
   </hints>
  </connection>
  <connection>
   <sender>dialFan</sender>
   <signal>valueChanged(int)</signal>
   <receiver>fndFan</receiver>
   <slot>display(int)</slot>
   <hints>
    <hint type="sourcelabel">
     <x>85</x>
     <y>255</y>
    </hint>
    <hint type="destinationlabel">
     <x>245</x>
     <y>250</y>
    </hint>
   </hints>
  </connection>
 </connections>
</ui>
```

**ConditionCtrl.py**
```python
import sys
from PyQt6.QtWidgets import QApplication, QMainWindow, QMessageBox
from ConditionCtrl_ui import Ui_MainWindow
from pyqt6_mqtt import PyQt6MqttClient

class ConditionCtrl(QMainWindow, Ui_MainWindow):
    def __init__(self):
        super().__init__()
        self.setupUi(self)
        self.dialLight.sliderReleased.connect(self.onLight_sliderReleased)
        self.dialFan.valueChanged.connect(self.onFan_valueChanged)
    
        self.client = PyQt6MqttClient(self)
        self.client.connectSignal.connect(self.onConnect)
        self.client.publishSignal.connect(self.onPublish)
        self.client.connect("mqtt.eclipseprojects.io")
        
    def onConnect(self, rc):
        if rc == 0:
            QMessageBox.information(self,"MQTT Broker", "브로커에 연결되었습니다.")
            self.groupLight.setEnabled(True)
            self.groupFan.setEnabled(True)
        else:
            self.close()
    
    def onPublish(self, mid):
        print(mid)
    
    def onLight_sliderReleased(self):
        value = self.dialLight.value()
        self.client.publish("asm/iot/pwm/light", value)
            
    def onFan_valueChanged(self, value):
        self.client.publish("asm/iot/pwm/fan", value)

if __name__ == "__main__":
    app = QApplication(sys.argv)
    ui = ConditionCtrl()
    ui.show()
    app.exec()
```
