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
**signal 콜백**
```python
import signal

def sigint(client):   
    def signal_handler(signal, frame):
        client.disconnect()

    signal.signal(signal.SIGINT, signal_handler)

def main():   
    client = Client()
    sigint(client)
    client.on_connect = on_connect
    client.connect(MQTT_SERVER)
    client.loop_forever()

if __name__ == "__main__":
    main()
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
import signal

MQTT_SERVER = "broker.hivemq.com"

def sigint(client):   
    def signal_handler(signal, frame):
        client.disconnect()

    signal.signal(signal.SIGINT, signal_handler)

def on_connect(client, userdata, flags, rc):
    print("Connected with result code " + str(rc))

def main():   
    client = Client()
    sigint(client)
    client.on_connect = on_connect
    client.connect(MQTT_SERVER)
    client.loop_forever()

if __name__ == "__main__":
    main()
```
</details>


### 토픽 메시지 구독
```python
TOPIC_HELLO = "asm/hello"

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        client.subscribe(TOPIC_HELLO)   

def on_message(client, userdata, msg):
    print(msg.topic + " " + msg.payload.decode())

def main():
    client = Client()
    client.on_connect = on_connect
    client.on_message = on_message
```

<details>
<summary>전체 코드</summary>

```python
from paho.mqtt.client import Client
import signal

MQTT_SERVER = "broker.hivemq.com"
TOPIC_HELLO = "asm/hello"

def sigint(client):   
    def signal_handler(signal, frame):
        client.disconnect()

    signal.signal(signal.SIGINT, signal_handler)

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        client.subscribe(TOPIC_HELLO)   

def on_message(client, userdata, msg):
    print(msg.topic + " " + msg.payload.decode())

def main():   
    client = Client()
    sigint(client)
    client.on_connect = on_connect
    client.on_message = on_message
    client.connect(MQTT_SERVER)
    client.loop_forever()

if __name__ == "__main__":
    main()
```
</details>

### 토픽 메시지 발생
```python
MY_TOPIC = "asm/hello"

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        msg = input("Enter your message: ")
        client.publish(MY_TOPIC, msg)

def on_publish(client, userdata, mid):
    msg = input("Enter your message: ")
    client.publish(MY_TOPIC, msg)

def main():
    client = Client()
    client.on_connect = on_connect
    client.on_publish = on_publish
```

<details>
<summary>전체 코드</summary>

```python
from paho.mqtt.client import Client
import signal

MQTT_SERVER = "broker.hivemq.com"
MY_TOPIC = "asm/hello"

def sigint(client):   
    def signal_handler(signal, frame):
        client.disconnect()

    signal.signal(signal.SIGINT, signal_handler)

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        msg = input("Enter your message: ")
        client.publish(MY_TOPIC, msg)

def on_publish(client, userdata, mid):
    msg = input("Enter your message: ")
    client.publish(MY_TOPIC, msg)

def main():
    client = Client()
    sigint(client)
    client.on_connect = on_connect
    client.on_publish = on_publish
    client.connect(MQTT_SERVER)
    client.loop_forever()

if __name__ == "__main__":
    main()
```
</details>

## 응용 예제
asm/randint 토픽에 1초 단위로 난수를 발행하는 발행자와 이를 구독하는 구독자를 구현해 보자

### asm/randint 토픽
```python
TOPIC_RADINT = "asm/randint"
```

### 1초 단위 지연
```python
import time

time.sleep(1)
```

### 난수 생성
```python
from random import randint

value = randint(10)
```

### 1초 단위로 난수 발행
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
import signal
import time

MQTT_SERVER = "broker.hivemq.com"
TOPIC_RADINT = "asm/randint"

def sigint(client):   
    def signal_handler(signal, frame):
        client.disconnect()

    signal.signal(signal.SIGINT, signal_handler)

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
    sigint(client)
    client.on_connect = on_connect
    client.on_publish = on_publish
    client.connect(MQTT_SERVER)
    client.loop_forever()

if __name__ == "__main__":
    main()
```
</details>

### 난수 구독자
- 연결되면 TOPIC_RANDINT 구독
- on_message 콜백에서 페이로드를 int 타입으로 변경

<details>
<summary>전체 코드</summary>

```python
from paho.mqtt.client import Client
import signal

MQTT_SERVER = "broker.hivemq.com"
TOPIC_RADINT = "asm/randint"

def sigint(client):   
    def signal_handler(signal, frame):
        client.disconnect()

    signal.signal(signal.SIGINT, signal_handler)

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print("ok")
        client.subscribe(TOPIC_RADINT)   

def on_message(client, userdata, msg):
    print(int(msg.payload))

def main():   
    client = Client()
    sigint(client)
    client.on_connect = on_connect
    client.on_message = on_message
    client.connect(MQTT_SERVER)
    client.loop_forever()

if __name__ == "__main__":
    main()
```
</details>
