# MQTT 기반 센서 제어 종합 과제

## 샘플 코드
```python
from paho.mqtt.client import Client
from pop import Cds, Pir, Ultrasonic, TempHumi, Potentiometer
from pop import Leds, Pixels
from time import time, strftime

MQTT_SERVER = "broker.hivemq.com"

TOPIC_IOT_ACTUATOR = "asm/iot/actuator" 
TOPIC_IOT_SENSORS = "asm/iot/sensors"

f = None
sensors_val = None
start_time = None

def post_sensors(client, sensors):
    global sensors_val

    cds_val = sensors[0].getValue()
    us_val = sensors[1].read()
    th_val = sensors[2].read() #temp, humi
    vr_val = sensors[3].getValue()

    sensors_val = f"{cds_val}, {us_val}, {th_val[0]:.1f}, {th_val[1]:.1f}, {vr_val}"
    client.publish(TOPIC_IOT_SENSORS, sensors_val)

def process_cmd(actuators, cmd):
    """
    cmd:
        1: leds on
        2: leds off
        3: pixel red
        4: pixel green
        5: pixel blue
        6: pixel off
        7: all off (leds off, pixel off)
    """
    print(cmd)

    if cmd == 1:
        actuators[0].on()    
    elif cmd == 2:
        actuators[0].off()
    elif cmd == 3:
        actuators[1].fill((255,0,0))
    elif cmd == 4:
        actuators[1].fill((0,255,0))
    elif cmd == 5:
        actuators[1].fill((0,0,255))
    elif cmd == 6:
        actuators[1].fill((0,0,0))
    elif cmd == 7:
        actuators[0].off()    
        actuators[1].fill((0,0,0))

def on_connect(client, userdata, flags, rc):
    global f

    if rc == 0:
        print("Connected")
        client.subscribe(TOPIC_IOT_ACTUATOR)
        f = open("result.txt", '+a')

def on_subscribe(client, userdata, mid, granted_qos):
    global start_time

    print("Subscribed")
    post_sensors(client, userdata[0])
    start_time = time()

def on_publish(client, userdata, mid):
    global sensors_val, start_time

    curr_time = strftime('%Y-%m-%d %H:%M:%S')
    result = f"{curr_time}, {sensors_val}\n"
    f.write(result)

    print(time() - start_time)
    if (time() - start_time) > 1:
        post_sensors(client, userdata[0])
        start_time = time()
    
def on_message(client, userdata, msg):
    cmd = int(msg.payload)
    process_cmd(userdata[1], cmd)

def main():
    cds = Cds()
    us = Ultrasonic()
    th = TempHumi()
    vr = Potentiometer()

    leds = Leds()
    pixel = Pixels()

    client = Client(userdata=((cds, us, th, vr),(leds, pixel)))
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

## 수행 과제
- MQTTX (GUI 기반 토픽 발행 및 구독용 범용 응용프로그램) 설치 후 과제 수행에 활용
  ```sh
  winget install MQTTX
  ```
  
- 샘플 코드 구조를 분석한 후 설명할 것
- 주어진 샘플을 센서 밣생자와 액추에이터 구독자로 분리해 구현한 후 센서 구독자과 액추에이터 발행자를 구현할 것
- 주어진 샘플에서 센서 발행과 액추에이터 구독을 동시에 수행하지 못하는 이유를 찾아보고 수정해 볼 것
