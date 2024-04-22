# 피드포워드(Feed-Forward)와 피드백(Feed-Back) 제어
- 피드포워드 제어는 피드백 경로가없는  Open-loop 형태로 외란에 의한 제어량을 미리 상정해 이에 상응하는 동작 수행.
  ```
  입력(목푯값) --> [컨트롤러]--> 조작량(연산값) --> [제어모델] --> 출력(제어량)
  ```  
- 피드백 제어는 Closed-loop 형태의 센서를 통해 외란에 의한 제어량 변화를 감지하며, 이를 상쇄하는제어 동작 수행.
  ```
  입력(목푯값) --> [컨트롤러]--> 조작량(연산값) --> [제어모델] --> 출력(제어량)  
               ^                              |  
         검출값 |-------------[센서]------------  
  ```
  
## Processing 구조
```python

is_stop = False

def loop():
    pass

def setup():
    pass

def cleanup():
    global is_stop

    is_stop = True

def main():
    setup()
    while not is_stop:
        loop()

if __name__ == '__main__':
    main()
```

## Tick 카운터 기반 인터벌 조건
```python
import time

is_stop = False
t0 = None
TARGET_TIME = 10 * 1000 # 10 second

def loop():
    if time.time() - t0 > TARGET_TIME:
        cleanup()

def setup():
    global t0
    t0 = time.time()

def cleanup()
    global is_stop

    is_stop = True

def main():
    setup()
    while not is_stop:
        loop()

if __name__ == '__main__':
    main()
```


## [과제] 일정 거리 이동
```python
import time
import threading
from pop.Pilot import SerBot
from pop.LiDAR import Rplidar

DIST = 300 # unit: cm
current_dist = None
current_detect = None

is_stop = False
bot = None
lidar = None

def work():
    lidar.connect()
    lidar.startMotor()
    
    while not is_stop:
        vs = lidar.getVectors()
        for v in vs:
            print(v[0], v[1]*10) #Todo v[0]:angle (unit degree), v[1]:distance (unit cm)

def loop():
    global current_dist
    
    for _ in range(10):
        time.sleep(1)
        if False: #Todo
            bot.stop()
        else:
            bot.forward()
        
    current_dist += 10
    if current_dist >= DIST:
        cleanup()

def setup():
    global current_dist
    global bot, lidar

    bot = SerBot()
    lidar = Rplidar()

    threading.Thread(target=work, daemon=True).start()
    
    bot.forward()
    current_dist = 0

def cleanup():
    global is_stop

    lidar.stopMotor()
    bot.stop()
    is_stop = True

def main():
    setup()   
    try:
        while not is_stop:
            loop()
    except KeyboardInterrupt:
        pass
    cleanup()

if __name__ == '__main__':
    main()
```
