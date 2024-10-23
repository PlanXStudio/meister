# 배경 음악과 함께 로봇 이동

## 스레드 기본 구조
배경 음악 재생 스레드와 로봇 이동 스레드로 구분해야 함.

```python
from threading import Thread
import time
import random


buff = 0

def task_buff_write():
    global buff
    
    t2 = Thread(target=task_buff_read, daemon=True)
    t2.start()
    
    t0 = time.time()
    
    while True:
        if time.time() - t0 >= 5000:
            break
        
        buff += 1
        time.sleep(0.001)

def task_buff_read():
    while True:
        n = random.randint(1, 10)
        time.sleep(n/100)
        print(buff)

t1 = Thread(target=task_buff_write)
t1.start()

t1.join()

```
