# IoT 원격 제어를 위한 MQTT 라이브러리 실습

## 공개 MQTT 브로커(서버)

|Name |	Broker Address | TCP Port	| TLS Port | WebSocket Port| Message Retention|
|---|---|---|---|---|---|
Eclipse	| mqtt.eclipse.org	| 1883	| N/A	| 80, 443 |	YES  
Mosquitto	| test.mosquitto.org	| 1883	| 8883, 8884	| 80	| YES  
HiveMQ | broker.hivemq.com	| 1883	| N/A	| 8000	| YES  
Flespi | mqtt.flespi.io | 1883 | 8883 | 80, 443 | YES
Dioty	| mqtt.dioty.co |	1883 | 8883 |	8080, 8880 |	YES
Fluux	| mqtt.fluux.io |	1883 | 8883 |	N/A |	N/A
EMQX | broker.emqx.io |	1883 | 8883| 8083 |	YES

## paho-mqtt 라이브러리
### 설치
```sh
pip install paho-mqtt
pip show paho-mqtt 
```

### MQTT 서버 연결
```python
from paho.mqtt.client import Client

MQTT_SERVER = "broker.hivemq.com"

def main():
    client = Client()
    client.connect(MQTT_SERVER)

if __name__ == "__main__":
    main()
```

### 연결 콜백 및 메시지 루프
```python
def on_connect(client, userdata, flags, rc):
    print("Connected with result code " + str(rc))

def main():
    client = Client()
    client.on_connect = on_connect
    client.connect(MQTT_SERVER)
    client.loop_forever()
```

### 키보드 인터럽트 예외 처리
**try/except 구문**
```python
if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        pass
```

### 정리
- paho.mqtt.client 모듈의 Client 클래스 로드
- MQTT 콜백 함수 정의
- Clinet 객체 생성
- MQTT 콜백 함수 등록
- MQTT 메시지 루프 실행

<details>
<summary>전체 코드</summary>

```python
from paho.mqtt.client import Client

MQTT_SERVER = "broker.hivemq.com"

def on_connect(client, userdata, flags, rc):
    print("Connected with result code " + str(rc))

def main():   
    client = Client()
    client.on_connect = on_connect
    client.connect(MQTT_SERVER)
    client.loop_forever()

if __name__ == "__main__":
    main()
```
</details>


### 토픽 구독
**토픽**
- 영문자, 숫자, _, -로 구성되며 /로 계층(레벨) 표현
  - asm/hello, asm/hello/123
- 계층 대체(특수) 문자는 #, +
  - #: 현재 및 하위 모든 계층 대체
  - +: 현재 계층 대체

```python
TOPIC_HELLO = "asm/hello"

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        client.subscribe(TOPIC_HELLO)   

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        client.subscribe(TOPIC_HELLO)   

def on_subscribe(client, userdata, mid, granted_qos):
    print("Successfully subscribe")

def main():
    client = Client()
    client.on_connect = on_connect
    client.on_subscribe = on_subscribe
    client.on_message = on_message
```

<details>
<summary>전체 코드</summary>

```python
from paho.mqtt.client import Client

MQTT_SERVER = "broker.hivemq.com"
TOPIC_HELLO = "asm/hello"

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        client.subscribe(TOPIC_HELLO)   

def on_subscribe(client, userdata, mid, granted_qos):
    print("Successfully subscribe")

def on_message(client, userdata, msg):
    print(msg.topic + " " + msg.payload.decode())

def main():   
    client = Client()
    client.on_connect = on_connect
    client.on_subscribe = on_subscribe
    client.on_message = on_message
    client.connect(MQTT_SERVER)
    client.loop_forever()

if __name__ == "__main__":
    main()
```
</details>

### 토픽 메시지 발행
```python
TOPIC_HELLO = "asm/hello"

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print("Connected to MQTT server")
        client.publish(TOPIC_HELLO, "Hello World!")

def on_publish(client, userdata, mid):
    print("Message published")

def main():
    client = Client()
    client.on_connect = on_connect
    client.on_publish = on_publish
```

<details>
<summary>전체 코드</summary>

```python
from paho.mqtt.client import Client

MQTT_SERVER = "broker.hivemq.com"
TOPIC_HELLO = "asm/hello"

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print("Connected to MQTT server")
        client.publish(TOPIC_HELLO, "Hello World!")

def on_publish(client, userdata, mid):
    print("Message published")

def main():
    client = Client()
    client.on_connect = on_connect
    client.on_publish = on_publish
    client.connect(MQTT_SERVER)
    client.loop_forever()

if __name__ == "__main__":
    main()
```
</details>

## 응용 예제

### 난수 발행 및 구독
asm/randint 토픽에 1초 단위로 난수를 발행하는 발행자와 이를 구독하는 구독자를 구현해 보자

**sm/randint 토픽**
```python
TOPIC_RADINT = "asm/randint"
```

**1초 단위 지연**
```python
import time

time.sleep(1)
```

**난수 생성**
```python
from random import randint

value = randint(10)
```

**1초 단위로 난수 발생**
- 1초 단위로 TOPIC_RANDINT 토픽에 0 ~ 10 사이 난수를 발생하는 함수 정의
  ```python
  def rand_publish(client):
      value = randint(0, 10)
      client.publish(TOPIC_RADINT, value)
      time.sleep(1)
  ```

- 연결되면 난수 발생 함수 호출
- on_publish 콜백에서 난수 발생 함수 호출

<details>
<summary>전체 코드</summary>

```python
from paho.mqtt.client import Client
from random import randint
import time

MQTT_SERVER = "broker.hivemq.com"
TOPIC_RADINT = "asm/randint"

def rand_publish(client):
    value = randint(0, 10)
    print(value)
    client.publish(TOPIC_RADINT, value)
    time.sleep(1)

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        rand_publish(client)

def on_publish(client, userdata, mid):
    rand_publish(client)

def main():
    client = Client()
    client.on_connect = on_connect
    client.on_publish = on_publish
    client.connect(MQTT_SERVER)
    client.loop_forever()

if __name__ == "__main__":
    main()
```
</details>

**난수 구독자**
- 연결되면 TOPIC_RANDINT 구독
- on_message 콜백에서 페이로드를 int 타입으로 변경

<details>
<summary>전체 코드</summary>

```python
from paho.mqtt.client import Client

MQTT_SERVER = "broker.hivemq.com"
TOPIC_RADINT = "asm/randint"

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print("ok")
        client.subscribe(TOPIC_RADINT)   

def on_subscribe(client, userdata, mid, granted_qos):
    print("Successfully subscribe")

def on_message(client, userdata, msg):
    print(int(msg.payload))

def main():   
    client = Client()
    client.on_connect = on_connect
    client.on_subscribe = on_subscribe
    client.on_message = on_message
    client.connect(MQTT_SERVER)
    client.loop_forever()

if __name__ == "__main__":
    main()
```
</details>

### 간단한 채팅
하나의 프로그램(파일)로 채팅 구현

**스레드로 input() 대기 문제 해결**
- input()을 실행하면 사용자가 ENTER키를 누를 때까지 명령 프롬프트(쉘)는 차단됨
  - 브로커로부터 메시지 수신 가능
  - 명령 프롬프트(쉘)가 차단된 동안에는 print()로 메시지를 출력할 수 없음
- input() 구문을 스레드로 메인 프로그램과 분리해 실행 
  - 스레드는 메인 프로그램과 별개로 새로운 프로그램처럼 동작
  - 전역 변수과 함수는 공유함
    
```python
from threading import Thread

def post_data(client):
    payload = input()
    client.publish(TOPIC_CHATT_MY, payload)

Thread(target=post_data, args=(client,)).start()
```

**다중 토픽**
- 전체 메시지 구독
```python
TOPIC_CHATT_ALL = "asm/chatt/+"
```

- 자신의 메시지 발생
```python
TOPIC_CHATT_MY = "asm/chatt/chanmin"
```

**토픽 구독 및 발생**
- on_subscribe 콜백: 서버로부터 토픽 구독 확인
- on_publish 콜백: 서버로부터 토픽 메시지 게시 확인
- on_message 콜백: 서버로부터 토픽 메시지 수신

<details>
<summary>전체 코드</summary>

```python
from paho.mqtt.client import Client
from threading import Thread

MQTT_SERVER = "broker.hivemq.com"
TOPIC_CHATT_ALL = "asm/chatt/+"
TOPIC_CHATT_MY = "asm/chatt/chanmin"

def post_data(client):
    payload = input()
    client.publish(TOPIC_CHATT_MY, payload)

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print("Successfully connected")
        client.subscribe(TOPIC_CHATT_ALL)
    else:
        print("Failed to connect")
        client.disconnect()

def on_subscribe(client, userdata, mid, granted_qos):
        Thread(target=post_data, args=(client,)).start()

def on_publish(client, userdata, mid):
    Thread(target=post_data, args=(client,)).start()

def on_message(client, userdata, msg):
    print(msg.topic, "->", msg.payload.decode())

def main():
    client = Client()
    client.on_connect = on_connect
    client.on_subscribe = on_subscribe
    client.on_publish = on_publish
    client.on_message = on_message
    client.connect(MQTT_SERVER)
    try:
        client.loop_forever()
    except KeyboardInterrupt:
        client.disconnect()

if __name__ == "__main__":
    main()
```
</details>
