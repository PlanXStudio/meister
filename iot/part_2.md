# MQTT로 Auto 제어기 원격 제어

## MQTT
- MQTT는 IoT 표준 중 하나로 인터넷을 통해 토픽과 메시지로 해당 기기 원격 제어 
  - 토픽은 계층으로 구분되는 문자열 형식으로 메시지 종류 구분
    - 예: "iot/home/1101", "iot/home/2101"
  - 메시지는 문자열 형식으로 제어 동작 또는 데이터
    - 예: "light on"  
- 브로커와 클라이언트로 구성
  - 브로커는 일종의 서버(TCP 1883 포트)로 공개 서버 활용 가능
    - 공개 브로커: broker.hivemq.com
  - 클라이언트는 응용 프로그램(MQTTX 등) 또는 라이브러리(paho-mqtt 등) 사용

## MQTT 클라이언트 툴
### MQTTX 설치
- [설치 파일 다운로드](https://www.emqx.com/en/downloads/MQTTX/v1.9.6/MQTTX-Setup-1.9.6-x64.exe)
- 다운 받은 파일 실행
- 윈도우 메뉴에서 새로 설치한 MQTTX 실행

### 공개 브로커 연결
- Connections에서 New Connection 버튼 클릭
  - Name: HiveMQ
  - Host: broker.hivemq.com
  - Connect 버튼 선택

### MQTT 테스트
- 구독 등록
  - New Subscription 클릭
  - Topic: iot/home/1000
  - Confirm 선택
- 메시지 발행
  - Plantext 선택
  - Topic: iot/home/1000
  - 메시지: 문자열 입력
  - 전송 버튼 선택
- 특수 토픽 문자
  - \\ 계층 구분 
  - + 현재 계층 치환
  - \# 하위 모든 계층 치환  
    
## 게이트웨이 구현
- Auto 제어기와 인터넷에 위치한 MQTT 브로커 연결
  - MQTTX에서 전송한 토픽과 메시지(제어 명령)는 MQTT 브로커에 저장됨
  - MQTT 브로커는 저장한 토픽과 제어 명령을 게이트웨이에 전송한 후 삭제
  - 게이트웨이는 수신한 명령을 Auto 제어기에 전달
  - Auto 제어기는 게이트웨이가 전달한 명령 실행

### PC 게이트웨이
```python
from paho.mqtt.client import Client
from serial import Serial
from time import sleep

MQTT_SERVER = "broker.hivemq.com"

SERIAL_PORT = "COM5"    #자신의 포트 번호
TOPIC_ID = "1000"       #자신의 학번

TOPIC_IOT_HOME = "iot/home/" + TOPIC_ID

def on_connect(client, ser, flags, rc):
    if rc == 0:
        print("Connected")
        client.subscribe(TOPIC_IOT_HOME) 

def on_subscribe(client, ser, mid, granted_qos):
    print("Subscribed")

def on_message(client, ser, msg):
    cmd = msg.payload 
    ser.write(cmd+b'\r')

def on_disconnect(client, ser, rc):
    print("Disconnected")

def main():
    ser = Serial(SERIAL_PORT, 115200, timeout=0)
    client = Client(userdata=ser)

    client.on_connect = on_connect
    client.on_subscribe = on_subscribe
    client.on_message = on_message
    client.on_disconnect = on_disconnect 

    client.connect(MQTT_SERVER)

    try:
        client.loop_forever()
    except KeyboardInterrupt:
        client.disconnect()

if __name__ == "__main__":
    main()
```

**실행**
1. Auto 제어기에 Part_1의 "스마트 홈" 스크립트 실행
  ```sh
  xnode -p<포트> run -n <스크립트파일명>
  ```

2. PC 게이트웨이 스크립트 실행
  ```sh
  python <스크립트파일명>
  ```
