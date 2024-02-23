```python
from pop import Pixels
import paho.mqtt.client as mqtt

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        client.subscribe("asm/iot/pixel")

def on_message(client, userdata, message):
    data = message.payload.decode().split(',')
    pix.fill((int(data[0]), int(data[1]), int(data[2])))

pix = Pixels()
client = mqtt.Client()
client.on_connect = on_connect
client.on_message = on_message
client.connect("broker.hivemq.com")
client.loop_forever()
```
