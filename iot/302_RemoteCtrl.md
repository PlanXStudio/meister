# 인터넷 기반 원격 제어

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
