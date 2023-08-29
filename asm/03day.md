# MQTT 기반으로 로또 번호를 발행하고 구독하는 프로그램 작성
## 구독 프로그램 
### 구현 조건 
- #1 학번을 문자열로 입력  
- #2 구독 토픽을 브로커에 등록하는 코드 작성  
- #3: 로또 발행 요청 토픽과 학번을 페이로드로 메시지를 발행하는 코드 작성
- #4: 브로커 연결을 종료하는 코드 작성
- #5: MQTT 클라이언트 객체에 콜백을 등록하는 코드 작성
- #6: 메시지 루프를 실행하는 코드 작성

### 실행 및 결과
> 완성한 프로그램을 실행하면 다음과 같은 결과를 출력한 후 종료. (학번과 로또 번호는 다를 수 있음)
```sh
$ python student.py
Connected
Subscribed
Published
asm/lotto/2000 [31, 41, 12, 19, 36, 30]
Disconnected
```

### 코드 리뷰
**테스트 코드**
```python
from paho.mqtt.client import Client

MQTT_SERVER = "broker.hivemq.com"

#1: 학번을 문자열로 입력하세요.
STUDENT_ID = ""

TOPIC_LOTTO_SUB = "asm/lotto/" + STUDENT_ID
TOPIC_LOTTO_PUB = "asm/lotto/pub"

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print("Connected")
        #2: 로또 구독 토픽을 브로커에 등록하는 코드를 작성하세요.
        

def on_subscribe(client, userdata, mid, granted_qos):
    print("Subscribed")
    #3 로또 발행 요청 토픽과 학번을 페이로드로 메시지를 발행하는 코드를 작성하세요.
    

def on_publish(client, userdata, mid):
    print("Published")

def on_message(client, userdata, msg):
    print(msg.topic, msg.payload.decode()) 
    #4: 브로커 연결을 종료하는 코드를 작성하세요.


def on_disconnect(client, userdata, rc):
    print("Disconnected")

def main():
    client = Client()
    #5: MQTT 클라이언트 객체에 콜백을 등록하는 코드를 작성하세요.





    client.connect(MQTT_SERVER)

    #6 메시지 루프를 실행하는 코드를 작성하세요.
    

if __name__ == "__main__":
    main()
```

**답안**
```python
from paho.mqtt.client import Client

MQTT_SERVER = "broker.hivemq.com"

STUDENT_ID = "2000"

TOPIC_LOTTO_SUB = "asm/lotto/" + STUDENT_ID
TOPIC_LOTTO_PUB = "asm/lotto/pub"

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print("Connected")
        client.subscribe(TOPIC_LOTTO_SUB) 

def on_subscribe(client, userdata, mid, granted_qos):
    print("Subscribed")
    client.publish(TOPIC_LOTTO_PUB, STUDENT_ID)

def on_publish(client, userdata, mid):
    print("Published")

def on_message(client, userdata, msg):
    print(msg.topic, msg.payload.decode()) 
    client.disconnect()

def on_disconnect(client, userdata, rc):
    print("Disconnected")

def main():
    client = Client()
    client.on_connect = on_connect
    client.on_subscribe = on_subscribe
    client.on_publish = on_publish
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

## 발행 프로그램
> 구독 프로그램을 실행하기 전에 먼저 실행  
> \<Ctrl\>+c로 종료하며, 발행 결과는 result.txt 파일에 저장됨

### 실행 및 결과
```sh
$ python teacher.py
Connected
Subscribed
Published
2501 [32, 5, 23, 34, 20, 6]
Published
2101 [19, 3, 6, 33, 10, 29]
Published
2201 [7, 30, 17, 1, 25, 3]
Published
<Ctrl>+c

$ type result.txt
2501 [32, 5, 23, 34, 20, 6]
2101 [19, 3, 6, 33, 10, 29]
2201 [7, 30, 17, 1, 25, 3]
2211 [5, 42, 3, 34, 19, 6]
2516 [1, 8, 13, 27, 24, 10]
2502 [31, 41, 12, 19, 36, 30]
```

### 사전 지식
**난수**
```python
import random

lotto = str(random.sample(range(1, 46), 6))
```

**파일 출력과 f스트링**
```python
f = open("result.txt", '+a')

result = f"{student_id} {lotto}\n"

f.write(result)
```

### 코드 리뷰
```python
from paho.mqtt.client import Client
import random

MQTT_SERVER = "broker.hivemq.com"

TOPIC_LOTTO_SUB = "asm/lotto/pub" 
TOPIC_LOTTO_PUB = "asm/lotto/"

f = None
student_id = None
lotto = None

def on_connect(client, userdata, flags, rc):
    global f

    if rc == 0:
        print("Connected")
        client.subscribe(TOPIC_LOTTO_SUB)
        f = open("result.txt", '+a')

def on_subscribe(client, userdata, mid, granted_qos):
    print("Subscribed")

def on_publish(client, userdata, mid):
    print("Published")
    result = f"{student_id} {lotto}\n"
    print(result, end='')
    f.write(result) 

def on_message(client, userdata, msg):
    global student_id, lotto

    student_id = msg.payload.decode()
    lotto = str(random.sample(range(1, 46), 6))
    client.publish(TOPIC_LOTTO_PUB + student_id, lotto)

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
        f.close()

if __name__ == "__main__":
    main()
```
