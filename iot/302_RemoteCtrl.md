# MQTT로 IoT 장비 원격 제어

## 시스템 구성
### Auto 제어기
Light와 Fan의 Red 선(VCC)을 PWM 포트 A(0)와 B(2)에 연결하고, Black 선은 PWM 및 IO포트의 GND에 연결 
Pwm 클래스를 이용해 펌웨어 구현
```python
```

### PC1 (브릿지)
PySerial과 paho-mqtt로 데이터 교환

### PC2 (원격 제어)
paho-mqtt와 pyqt6로 GUI 기반 원격 제어

## MQTT 테스트
### 단방향 통신
**mqtt_const.py**
```python
BROKER_SERVER= "mqtt.eclipseprojects.io"
TOPIC_LOTTO = "asm/iot/0/lotto"
```

**mqtt_pub_lotto.py**
```python
import sys
import json
import random

import paho.mqtt.client as mqtt
from mqtt_const import BROKER_SERVER, TOPIC_LOTTO

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print("브로커에 연결되었습니다.")
        lotto = random.sample(range(1, 45+1), 6)
        client.publish(TOPIC_LOTTO, json.dumps(lotto))
        print(lotto)
    else:
        print("브로커에 연결할 수 없습니다.")
        sys.exit()

def on_publish(client, userdata, mid):
    print("브로커에 토픽 메시지가 게시되었습니다.")
    sys.exit()

def main():
    c = mqtt.Client()
    c.on_connect = on_connect
    c.on_publish = on_publish
    
    c.connect(BROKER_SERVER)
    c.loop_forever()

if __name__ == "__main__":
    main()
```

**mqtt_sub_lotto.py**
```python
import sys
import json
import random

import paho.mqtt.client as mqtt
from mqtt_const import BROKER_SERVER, TOPIC_LOTTO

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print("브로커에 연결되었습니다.")
        client.subscribe(TOPIC_LOTTO)
    else:
        print("브로커에 연결할 수 없습니다.")
        sys.exit()

def on_subscribe(client, userdata, mid, granted_qos):
    print("브로커에 토픽 구독이 등록되었습니다.")

def on_message(client, userdata, message):
    t = message.topic
    p = json.loads(message.payload)
    print(t, p)
    
def main():
    c = mqtt.Client()
    c.on_connect = on_connect
    c.on_subscribe = on_subscribe
    c.on_message = on_message
    
    c.connect(BROKER_SERVER)
    c.loop_forever()

if __name__ == "__main__":
    main()
```

## PyQt6와 MQTT로 구현하는 PWM 기반 조명, 팬 제어기
### PyQt6를 위한 MQTT Client
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

### GUI
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
