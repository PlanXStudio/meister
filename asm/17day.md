# 원격 제어 응용
## MQTT로 Auto 제어기 원격 제어
### MQTT
- MQTT는 IoT 표준 중 하나로 원격 제어를 위해 **인터넷을 통해 토픽과 메시지 발생하고 구독** 
  - 토픽: 메시지 종류를 구분하는 문자열
    - 영문자, 숫자, '_', '-'로 구성되며 '/'로 계층(레벨) 구분
    - #: 현재 및 하위 모든 계층 대체  
    - +: 현재 계층 대체  
    - 예
      - "iot/home/1101"
      - "iot/home/2101"
      - "iot/home/+"
      - "iot/#"
  - 메시지: 문자열(Plantext) 형식으로 제어 동작 또는 데이터
    - 예: "light on"  
- 브로커와 클라이언트로 구성
  - 브로커는 일종의 서버(TCP 1883 포트)로 공개 브로커 활용 가능
  - 클라이언트는 응용 프로그램(MQTTX 등) 또는 라이브러리(paho-mqtt 등) 사용
- 공개 브로커

|Name |	Broker Address | TCP Port	| TLS Port | WebSocket Port| Message Retention|
|---|---|---|---|---|---|
Eclipse	| mqtt.eclipse.org	| 1883	| N/A	| 80, 443 |	YES  
Mosquitto	| test.mosquitto.org	| 1883	| 8883, 8884	| 80	| YES  
HiveMQ | broker.hivemq.com	| 1883	| N/A	| 8000	| YES  
Flespi | mqtt.flespi.io | 1883 | 8883 | 80, 443 | YES
Dioty	| mqtt.dioty.co |	1883 | 8883 |	8080, 8880 |	YES
Fluux	| mqtt.fluux.io |	1883 | 8883 |	N/A |	N/A
EMQX | broker.emqx.io |	1883 | 8883| 8083 |	YES

<br>

### MQTT 클라이언트 툴
**MQTTX 설치**
- [설치 파일 다운로드](https://www.emqx.com/en/downloads/MQTTX/v1.9.6/MQTTX-Setup-1.9.6-x64.exe)
  - 로컬 공유(https://koreaoffice-my.sharepoint.com/:u:/g/personal/devcamp_korea_ac_kr/EWtxHHp_2KNFmTx7qVjebrwBAtWmtRtfu4h_BaoQjGAVRg?e=duNZeu)
- 다운 받은 파일 실행
- 윈도우 메뉴에서 새로 설치한 MQTTX 실행

**공개 브로커 연결**
- Connections에서 New Connection 버튼 클릭
  - Name: HiveMQ
  - Host: broker.hivemq.com
  - Connect 버튼 선택

**MQTT 테스트**
- 구독 등록
  - New Subscription 클릭
  - Topic: iot/home/1000
  - Confirm 선택
- 메시지 발행
  - Plantext 선택
  - Topic: iot/home/1000
  - 메시지: 문자열 입력
  - 전송 버튼 선택

**다음과 같이 실습을 진행하시오.**
- 다음과 같이 4개 계층으로 토픽을 정의하라.
  - 첫 번째 계층: "iot"
  - 두 번째 계층: "home", "factory"
  - 세 번째 계층(그룹 구분): "1000", "2000", "3000", "4000", "5000"
  - 네 번째 계층(자신 구분): "01", "02", "03", "04" 
- 정의한 토픽으로 메시지를 발행할 때 다음과 같이 구독해 보라.
  - 네 번째 계층이 같은(자신의) 토픽 구독  
  - 세 번째 계층이 같은 그룹 토픽 구독
  - 두 번째 계층이 같은 모든 하위 그룹 토픽 구독 
  - 첫 번째 계층이 같은 모든 하위 그룹 토픽 구독

<br>

### 게이트웨이 구현
- 전체 구조는 다음과 같음
  - Auto 제어기 <---시리얼--- PC (게이트웨이) ---인터넷---> MQTT 브로커
- 게이트웨이는 Auto 제어기와 인터넷에 위치한 MQTT 브로커 연결
  - MQTTX에서 전송한 토픽과 메시지(제어 명령)는 MQTT 브로커에 저장됨
  - MQTT 브로커는 저장한 토픽과 제어 명령을 게이트웨이에 전송한 후 삭제
  - 게이트웨이는 수신한 명령을 Auto 제어기에 전달
  - Auto 제어기는 게이트웨이가 전달한 명령 실행

**PC 게이트웨이 구현**
```python
from paho.mqtt.client import Client
from serial import Serial
from time import sleep

MQTT_SERVER = "broker.hivemq.com" #MQTT 브로커 주소

SERIAL_PORT = "COM5"    #자신의 포트 번호
TOPIC_GROUP = "5000/"   #자신의 고유 그룹
TOPIC_ID    = "01"      #자신의 고유 번호

TOPIC_IOT_HOME = "iot/home/" + TOPIC_GROUP + TOPIC_ID

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


## 카메라로 Auto 제어기 원격 제어
### 카메라에서 영상 데이터 얻기
```python
import cv2

def main():
    cap = cv2.VideoCapture(0)

    while True:
        _, frame = cap.read()
        cv2.imshow("Camera", frame)
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    cap.release()
    cv2.destroyAllWindows()

if __name__ == '__main__':
    main()
```

### 사직찍기
```python
import cv2

def main():
    cap = cv2.VideoCapture(0)
    cnt = 0

    while True:
        _, frame = cap.read()
        cv2.imshow("Camera", frame)
        key = cv2.waitKey(1) & 0xFF
        if key == ord('q'):
            break
        elif key == ord('c'):
            cv2.imwrite("./my%d.jpg"%(cnt), frame)
            cnt = cnt + 1

    cap.release()
    cv2.destroyAllWindows()

if __name__ == '__main__':
    main()
```

### 얼굴인식
```python
import cv2

def main():
    cap = cv2.VideoCapture(0)
    face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + "haarcascade_frontalface_default.xml")

    while True:
        _, frame = cap.read()

        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        faces = face_cascade.detectMultiScale(gray, scaleFactor=1.1, minNeighbors=5, minSize=(30,30))
        for x, y, w, h in faces:
            cv2.rectangle(frame, (x, y), (x+w, y+h), (0, 255, 0), 2)
        
        cv2.imshow("Face Detection", frame)
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    cap.release()
    cv2.destroyAllWindows()

if __name__ == '__main__':
    main()
```

### 방문자 인식 및 도어락 제어
- 얼굴이 인식되면 사진을 찍은 후 도어락 이벤트 발생
- 다음 문제점을 해결할 것!
  - 실시간으로 얼굴을 인식하므로 1초에 수십회 이벤트 발생
    
```python
import cv2
from serial import Serial

SERIAL_PORT = "COM5" #자신의 포트 번호

def main():
    cap = cv2.VideoCapture(0)
    face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + "haarcascade_frontalface_default.xml")
    ser = Serial(SERIAL_PORT, 115200, timeout=0)
    cnt = 0

    while True:
        _, frame = cap.read()

        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        faces = face_cascade.detectMultiScale(gray, scaleFactor=1.1, minNeighbors=5, minSize=(30,30))
        if len(faces) >= 1:
            ser.write("doorlock\r".encode())
            cv2.imwrite("./visitant%d.jpg"%(cnt), frame)
            cnt += 1

        cv2.imshow("Visitant", frame)
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    cap.release()
    cv2.destroyAllWindows()

if __name__ == '__main__':
    main()
```
