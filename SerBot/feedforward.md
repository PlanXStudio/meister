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

DIST = 300 # unit: cm
current_dist = None
current_detect = None
bot = None

def work():
    lidar = Lidar()
    lidar.connect()
    lidar.startMotor()
    
    while True:
        v = lidar.getVectors()
        #Todo

def loop():
    global current_dist
    
    for _ in range(10):
        time.sleep(1)
        if current_detect < 50:
            pass #bot.stop()
        else:
            pass #bot.forward()
        
    current_dist += 10
    if current_dist >= DIST:
        sys.exit()

def setup():
    global current_dist
    global bot

    bot = SerBot()
    threading.Thread(target=work, daemon=True).start()
    
    bot.forward()
    current_dist = 0

def main():
    setup()   
    while True:
        loop()

if __name__ == '__main__':
    main()
```
