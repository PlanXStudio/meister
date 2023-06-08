## MQTT Simple Example
> rand publish and subscribe

### Publish
- mqtt_rand_pub.py
```python
import paho.mqtt.client as mqtt
import random
import time
import signal

TOPIC_RAND = "soda/sensors/value"
BROKER_ADDR = "broker.hivemq.com"

def rand_publish(client):
    value = random.randint(0, 255)
    client.publish(TOPIC_RAND, value)
    time.sleep(1)

def _signal_handler(signal, frame):
    client.disconnect()

def _on_connect(client, userdata, flags, rc):
    if rc == 0:
        rand_publish(client)

def _on_publish(client, userdata, mid):
    rand_publish(client)

def main():
    signal.signal(signal.SIGINT, _signal_handler)

    client = mqtt.Client()
    client.on_connect = _on_connect
    client.on_publish = _on_publish

    client.connect(BROKER_ADDR)
    client.loop_forever()

if __name__ == "__main__":
    main()
```

### Subscribe
- mqtt_rand_sub.py
```python
import paho.mqtt.client as mqtt
import signal

TOPIC_RAND = "soda/sensors/value"
BROKER_ADDR = "broker.hivemq.com"

def _signal_handler(signal, frame):
    client.disconnect()

def _on_connect(client, userdata, flags, rc):
    if rc == 0:
        client.subscribe(TOPIC_RAND)        

def _on_message(client, userdata, message):
    print(message.topic, int(message.payload))

def main():
    signal.signal(signal.SIGINT, _signal_handler)
    
    client = mqtt.Client()
    client.on_connect = _on_connect
    client.on_message = _on_message

    client.connect(BROKER_ADDR)
    client.loop_forever()
 
if __name__ == "__main__":
    main()
```
