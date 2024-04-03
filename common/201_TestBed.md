# AIoT TestBed
AIoT TestBed는 3개의 Edge Computer와 5개의 Zigbee V3 기반 Auto 제어기 및 Zigbee V3 코디네이터를 통해 모든 액추에이터와 센서 및 카메라, 픽셀 디스플레이를 제어합니다.

### Edge Computer
데비안 계열(우분투)의 리눅스로 운영되며, 대형 터치 디스플레이를 통해 사용자 인터페이스를 제공하는 Main Edge Computer와 2대의 카메라 제어용 Edge Computer 및 픽셀 디스플레이 제어용 Edge Computer로 구성됩니다.

### Auto 제어기
센서와 액추에이터는 모두 Auto 제어기에 연결되어 있습니다. Auto 제어기는 MCU 기반의 마이크로파이썬 코드로 동작하며, 저전력 무선 통신인 Zigbee로 Main Edige Computer와 통신합니다.  
Auto 제어기는 조도 센서를 비롯해, 온도, 습도 센서가 포함되어 있습니다.

### 코디네이터
Main Edige Computer에 Zigbee 통신을 제공하기 위한 장치로 Auto 제어기의 Zigbee 네트워크를 관리합니다.

### 센서와 액추에이터
출입문, 거실, 주방으로 나워 각각 Auto 제어기와 센서가 배치되어 있습니다.

**출입문**
조명 및 도어락과 움직임 감지기(PIR)이 위치합니다.

**거실**
조명 및 환기팬, 미세먼지 센서, 자동 커튼 제어기가 위치합니다.

**주방**
조명과 환기팬 및 가스 잠금 밸브, 가스 누출 감지기가 이치합니다.

### 픽셀 디스플레이
Edge Computer로 제어하는 일종의 전광판입니다. 한/영 출력이 가능하고 전경 및 배경색 변경과 깜빡임 및 이동과 같은 간단한 효과를 부여할 수 있습니다.

## AIoT TestBed 장치 연결
실습은 MQTT 프로토콜을 활용하여 파이썬 프로그래밍을 통해 이루어집니다. 이를 활용하기 위해서는 MQTT Broker에 접속되어야 합니다. MQTT Broker는 AIoT TestBed의 Edge Computer에 미리 설치되어 있어 개인이 활용하는 PC 또는 랩탑이 TestBed 장치와 유선 또는 무선으로 연결하여 Broker에 연결하는 방식입니다. 여기서는 TestBed에 연결하는 방법에 대해 소개합니다. 

### 전원
실습 장비의 전원은 장비 좌측 하단(아랫면)에 있습니다. 이곳에 AC 220V 전원 케이블을 연결하고 옆에 있는 전원 스위치를 ON 시키면 TestBed가 부팅됩니다.

### 네트워크 연결
AIoT TestBed에는 이더넷 허브와 Wi-Fi AP(Access Point)가 내장되어 있습니다. 이를 통해 장비에 장착된 Edge Computer 및 Controller 사이 및 외부에서 접속한 컴퓨터와 통신합니다.

**유선(Ethernet) 연결**
유선 연결 단자는 전원 단자 옆에 있습니다. 네트워크 케이블을 AIoT TestBed의 유선 네트워크포트에 연결할 때, 이더넷 포트가 없는 랩탑은 별도의 USB 탕비의 이더넷 어댑터를 추가로 사용합니다.

이더넷으로 AIoT TestBed과 통신할 때는 다음과 같이 해당 어댑터에 새로운 IP 주소와 서브넷마스크를 설정해야 합니다.

```sh
ncpa.cpl
```
- IP: 192.168.5.120
- 서브넷마스크: 255.255.255.0
 
**무선(Wi-Fi) 연결**
무선 연결은 AIoT TestBed 내부에 포함된 Wi-Fi AP를 이용합니다. 비밀 번호를 설정되어 있지 않으므로 해당 SSID를 찾아 연결하면 됩니다. Wi-Fi는 이더넷과 달리 컴퓨터에 자동으로 IP와 넷마스트가 설정되므로 사용자가 따로 할 필요는 없습니다.

Wi-Fi AP의 SSID는 사전에 ‘<고유 코드>-TB<일련 번호>’ 형태로 부여되는데, 고유 코드가 ASM이라면 컴퓨터의 무선 연결에서 다음과 같은 Wi-Fi AP 목록을 확인할 수 있습니다. 5G 접미사는 무선 신호가 5GHz입니다.   

```sh
ASM-TB01
ASM-TB015G
...
```

### TestBed 내부 장치 IP 
AIoT TestBed에는 리눅스로 운영되는 메인 Edge Computer와 2개의 카메라 제어용 Edge Computer가 있는데, 이들은 SSH 등을 통해 접속이 가능합니다.  
각 장치는 고정된 IP가 할당되어 있으며 IP 주소는 다음과 같습니다. 

장치 |	내부 IP주소  
-----|----------------|  
Wi-Fi AP | 192.168.5.1  
Main Edge |	192.168.5.201 (MQTT Broker)  
Camera Edge 1 |	192.168.5.202   
Camera Edge 2 |	192.168.5.203   
Pixel Display |	192.168.5.204  

---

## AIoT TestBed와 MQTT 
Main Edge Computer는 Zigbee 노드와 인터넷을 연결하는 일종의 게이트웨이로 사전에 MQTT 브로커가 설치되어 있어, 외부에서는 이 브로커를 통해 MQTT 토픽과 메시지로 각각의 Zigbee 노드를 제어할 수 있습니다. 
 
### AIoT TestBed Topic List
Edge Computer 내부의 Broker와 통신하여 TestBed의 센서의 값을 확인하거나 액추에이터를 제어할때는 토픽을 활용합니다. 각각의 토픽들은 미리 정의되어 있으며 정해진 토픽을 활용하는 형태로 TestBed를 활용합니다. 

최상위 토픽은 각 TestBed의 고유 코드로 설정되어 있습니다. 앞서 소개한 바와 같이 코드 코드가 ASM이고 5대의 TestBed가 설치되어 있다면 최상위 토픽은 장비마다 다음과 같습니다.


Device | Main Topic 
-------|------------
#1 | ASM01
#2 | ASM02
#3 | ASM03
#4 | ASM04
#5 | ASM05

다음 절의 각각의 토픽 리스트 소개에서는 편의상 최상위 토픽을 <고유 코드>라고 표기하겠습니다. 

### 액추에이터 제어(/actuator)
**조명 제어**
- Data: 0(끄기) or 1(켜기)
- Topic: <고유 코드>/actuator/light
- 하위 노드
  - /kitchen: 부엌 조명 제어
  -	/living: 거실 조명 제어
  -	/door: 현관 조명 제어

**팬 제어**
- Data: 0(끄기) or 1(켜기)
- Topic: <고유 코드>/actuator/fan
- 하위 노드
  -	/kitchen: 부엌 팬 제어
  -	/living: 거실 팬 제어

**커튼 제어**
- Data: 0(올리기) or 1(내리기)
- Topic: <고유 코드>/actuator/curtain

**도어락 제어**
- Data: 0(잠금) or 1(열림)
- Topic: <고유 코드>/actuator/lock

**가스브레이크 제어**
- Data: 0(잠금) or 1(열림)
- Topic: <고유 코드>/actuator/gasbreaker

### Pixel Display 제어(/display)

**텍스트 표시**
- Data: 문자열(ex: Hello)
- Topic: <고유 코드>/display

**백그라운드 색상 제어**
- Data: 문자열(색상코드 ex: FFFFFF)
- Topic: <고유 코드>/display/bgc

**텍스트 색상 제어**
- Data: 문자열(색상코드 ex: FFFFFF)
- Topic: <고유 코드>/display/tc

**텍스트 시프팅 방향 설정**
- Data: ‘left’(왼쪽) or ‘right’(오른쪽) or ‘off’(비활성화)
- Topic: <고유 코드>/display/shifting_dir

**텍스트 시프팅 딜레이 설정**
- Data: 정수(ms 단위 ex: 10)
- Topic: <고유 코드>/display/shifting_delay

**Display 점멸 주기 설정**
- Data: 정수(활성화 및 주기 설정 ms  ex: 10) or ‘off’ (비활성화)
- Topic: <고유 코드>/display/blink

### 센서 데이터 수집(/sensor)
센서 데이터 토픽 설명 중 ‘하위 노드’ 라고 적혀져 있을 경우, 해당 하위 노드까지 합쳐진 토픽을 구독해야 관련 데이터가 표시됩니다.

**습도 데이터**
- Data: 0~100
- Topic: <고유 코드>/sensor/humi
- 하위 노드
  - /kitchen: 부엌 습도 데이터
  -	/living: 거실 습도 데이터
  -	/door: 현관 습도 데이터

**온도 데이터**
- Data: 온도 정수값
- Topic: <고유 코드>/sensor/temp
- 하위 노드
  -	/kitchen: 부엌 온도 데이터
  -	/living: 거실 온도 데이터
  - /door: 현관 온도 데이터

**조도 데이터**
- Data: 정수값
- Topic: <고유 코드>/sensor/light
- 하위 노드
  -	/living: 거실 조도 데이터

**가스 데이터**
- Data: 0(미감지) or 1(감지)
- Topic: <고유 코드>/sensor/gasdata

**먼지 데이터**
- Data: 정수값
- Topic: <고유 코드>/sensor/dust

**PIR 데이터**
- Data: 0(미감지) or 1(감지)
- Topic: <고유 코드>/sensor/pir

## 파이썬 스크립트
MQTTX와 같은 범용 툴로 먼저 AIoT TestBed에 토픽과 메시지를 발생(액추에이터)하고 센서값을 구독(센서)해 본 후 파이썬으로 자동화 합니다.

### Template
아래 코드를 기반으로 AIoT TestBed에 publish(<토픽>, <데이터>)로 액추에이터 제어 토픽을 발행하고, subscribe(<토픽>)으로 센서 토픽을 구독하도록 구현해 봅니다.

```python
import paho.mqtt.client as mqtt
import time

def on_connect(client, userdata, flags,  reason_code, properties):
    if reason_code == 0:
        print("Ok Connection")
        #이곳에서 새로운 토픽을 발행하거나, 구독할 수 있습니다.
        
def on_publish(client, userdata, mid, reason_code, properties):
    print(mid)
    #이곳에서 새로운 토픽을 발생할 수 있읍니다.

def on_message(client, userdata, message):
    print(f"{message.topic}, {message.payload}")

def main():
    client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2)
    client.on_connect = on_connect
    client.on_publish = on_publish
    client.on_message = on_message
    
    client.connect("192.168.5.201")
    client.loop_forever()

    """
    loop_forever() 대신 loop_start()를 사용할 수 있습니다. 
    client.loop_start()

    이후 사용자는 프로그램을 종료하지 않고 지속적으로 토픽을 발행하거나 대기해야 합니다.

    끝으로 종료전 연결을 끊고 라이브러리 루프를 종료해야 합니다.
    client.disconnect()
    client.loop_stop()
    """

if __name__ == "__main__":
    main()
```
