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

## SimplePlayer 라이브러리

**splay.py**
```python
from playsound import playsound
from threading import Thread
from multiprocessing import Process
import time

class SimplePlayer:
    def __init__(self, path, exit_handler=None):
        self.__process = Process(target=playsound, args=(path,), daemon=True)
        self.__process.start()
        if exit_handler:
            Thread(target=self.__loop, args=(exit_handler,), daemon=True).start()
        
    def __loop(self, exit_handler):
        while self.isPlaying: time.sleep(1e-3)
        exit_handler()
        
    def Stop(self):
        if self.__process.is_alive:
            self.__process.terminate()

    @property
    def isPlaying(self):
        return self.__process.is_alive


def main1():
    p = SimplePlayer("StairwayToHeaven_LedZeppelin.mp3")
    while True:
        if p.isPlaying:
            if input("Do you want to stop? (y/n)").lower() == 'y':
                print("stoped")
                break
        else:
            print("finished")
            break

def main2():
    def finished():
        print("finished")
    
    p = SimplePlayer("StairwayToHeaven_LedZeppelin.mp3", finished)
    while True:
        if input("Do you want to stop? (y/n)").lower() == 'y':
            print("stoped")
            break

if __name__ == "__main__":
    main2()
```

