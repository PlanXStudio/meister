# MQTT 기반 IoT 센서 제어 종합 과제

## paho-mqtt 라이브러리 사용자 인자
> Client() 객체를 만들 때 userdata 인자에 사용자 데이터 전달 가능  
> 모든 callback 함수의 userdata 인자로 넘겨짐
> 여러 개의 데이터는 튜플 또는 리스트로 전달

```python
def on_connect(client, userdata, flags, rc):
    global f

    if rc == 0:
        print("Connected")
        f = open("result_sensor.txt", '+a')
        post_sensors(client, userdata)

def main():
    cds = Cds()
    us = Ultrasonic()
    th = TempHumi()
    vr = Potentiometer()

    client = Client(userdata=(cds, us, th, vr))
```

## 샘플
### 빛, 움직임 감지, 거리 감지, 온도/습도, 가변저항 센서값 발행
> iot_sensors.py

```python
from paho.mqtt.client import Client
from pop import Cds, Pir, Ultrasonic, TempHumi, Potentiometer
from time import sleep, strftime

MQTT_SERVER = "broker.hivemq.com"

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
    print(sensors_val)
    
    client.publish(TOPIC_IOT_SENSORS, sensors_val)

def on_connect(client, userdata, flags, rc):
    global f

    if rc == 0:
        print("Connected")
        f = open("result_sensor.txt", '+a')
        post_sensors(client, userdata)

def on_publish(client, userdata, mid):
    global sensors_val

    curr_time = strftime('%Y-%m-%d %H:%M:%S')
    result = f"{curr_time}, {sensors_val}\n"
    f.write(result)

    sleep(2)
    post_sensors(client, userdata)
    
def main():
    cds = Cds()
    us = Ultrasonic()
    th = TempHumi()
    vr = Potentiometer()

    client = Client(userdata=(cds, us, th, vr))
    client.on_connect = on_connect
    client.on_publish = on_publish

    client.connect(MQTT_SERVER)
    
    try:
        client.loop_forever()
    except KeyboardInterrupt:
        client.disconnect()
        f.close()

if __name__ == "__main__":
    main()
```

### LED, 픽셀 디스플레이 제어 구독
> iot_actuators.py
```python
from paho.mqtt.client import Client
from pop import Leds, Pixels
from time import strftime

MQTT_SERVER = "broker.hivemq.com"

TOPIC_IOT_ACTUATOR = "asm/iot/actuator" 

f = None
start_time = None

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
        f = open("result_actuator.txt", '+a')

def on_subscribe(client, userdata, mid, granted_qos):
    print("Subscribed")
    
def on_message(client, userdata, msg):
    cmd = int(msg.payload)

    print(f"{cmd}")
    process_cmd(userdata, cmd)

    curr_time = strftime('%Y-%m-%d %H:%M:%S')
    result = f"{curr_time}, {cmd}\n"
    f.write(result)

def main():
    leds = Leds()
    pixel = Pixels()

    client = Client(userdata=(leds, pixel))
    client.on_connect = on_connect
    client.on_subscribe = on_subscribe
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
- PC에 MQTTX (GUI 기반 토픽 발행 및 구독용 범용 응용프로그램) 설치 후 과제 수행에 활용
  ```sh
  winget install MQTTX
  ```
- 샘플 테스트
  - 실습장치(PyCBasic 2)에서 2개의 샘플 코드를 실행해 봅니다. (VSCode의 터미널 분할 기능 사용)
    - PC에서 ncpa.cpl 명령으로 USB 이더넷의 IP 192.168.101.120 및 서브넷마스크 255.255.255.0 확인이 필요합니다.   
    - 실습장치의0 IP는 192.168.101.101이고 계정 ID는 soda, 계정 패스워드 soda입니다.
  - PC에서 MQTTX를 실행한 후 센서값 구독 토픽과 액추에이터 제어 발행 토픽을 이용해 센서값을 구독하고 액추에이터 제어 토픽을 발행해 봅니다.
    - 브로커는 broker.hivemq.com를 사용합니다.
    - 센서값 구독 토픽은 asm/iot/sensors입니다.
    - 액추에이터 제어 발행 토픽은 asm/iot/actuator입니다.
  - 수행한 테스트 과정을 문서로 적어 봅니다.
- 샘플 코드의 구조를 분석해 봅니다.
  - 전체 코드 실행 흐름을 문서로 적어 봅니다.
  - 줄 단위로 명령문의 의미를 문서로 적어 봅니다.
- PC에서 센서값을 구독하고 액추에이터 제어 토픽을 발행하는 프로그램을 작성해 봅니다.
  - paho MQTT 클라이언트 라이브러리를 이용합니다.
  - 브로커 및 센서값 구독과 액추에이터 제어 발행 토픽은 MQTTX에서 테스트한 것과 같습니다.
  - 2개의 파이썬 스크립트(iot_sensors_sub.py, iot_actuators_pub.py)로 구현한 후 실행해 봅니다.
- [심화(난이도 최상)] 실습장비에서 실행되는 2개의 샘플과 PC에서 구현한 결과물은 각각 하나의 파이썬 스크립트로 병합해 봅니다.
  - 실습장비의 센서값 발행과 액추에이터 제어 구독을 하나의 파이썬 스크립트에서 처리해야 합니다.
  - PC의 센서값 구독과 액추에이터 제어 발행을 하나의 파이썬 스크립트에서 처리해야 합니다.
  - sleep()과 같은 지연 함수는 비동기 호출을 차단하는 문제가 있습니다. 이를 해결해 보세요.  
- 작성한 문서와 구현한 소스 코드를 제출해 주세요.
  - 심화문제는 선택입니다. 
