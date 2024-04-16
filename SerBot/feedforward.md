# Processing 구조
```python
def loop():
    pass

def setup():
    pass

def main():
    setup()
    while True:
        loop()

if __name__ == '__main__':
    main()
```

## Tick 카운터 기반 조건
```python
import time
import sys

t0 = None
TARGET_TIME = 10 * 1000 # 10 second

def loop():
    if time.time() - t0 > TARGET_TIME:
        sys.exit()

def setup():
    global t0
    t0 = time.time()

def main():
    setup()
    while True:
        loop()

if __name__ == '__main__':
    main()
```



## [과제] 일정 거리 이동
```python
import time
import sys
import threading
from pop.Pilot import SerBot
from pop.LiDAR import Rplidar

DIST = 300 # unit: cm
current_dist = None
current_detect = None

bot = None
lidar = None

def work():
    lidar.connect()
    lidar.startMotor()
    
    while True:
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
        sys.exit()

def setup():
    global current_dist
    global bot, lidar

    bot = SerBot()
    lidar = Rplidar()

    threading.Thread(target=work, daemon=True).start()
    
    bot.forward()
    current_dist = 0

def clean():
    lidar.stopMotor()
    bot.stop()
    
def main():
    setup()   
    try:
        while True:
            loop()
    except KeyboardInterrupt:
        clean()

if __name__ == '__main__':
    main()
```
