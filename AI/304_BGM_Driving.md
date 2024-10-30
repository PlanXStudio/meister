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

## 음악 파일 백그라운드 재생
파이썬 표준 라이브러리인 Process, Thread와 외부 라이브러리인 playsound를 이용해 백그라운드 오디오 출력 구현
- Process: playsound를 별도 프로세스로 만든 후 종료 제어
- Thread: Process의 종료 감시 및 사용자 콜백 호출
- playsound: 매우 간단한 멀티 플랫폼용 오디오 포맷 출력 라이브러리로 MP3 지원

playsound가 설치되어 있지 않으면, 다음과 같이 설치
```sh
pip install playsound
```

### SimplePlayer 클래스 구현
**샘플 음악**
[StairwayToHeaven_LedZeppelin.mp3](https://1drv.ms/u/s!AtTAtBZJQ9JFp8U47OtQpzQdwd7Flw?e=G8ridD)

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
```

### 테스트 코드
**test1.py**
```python
from splay import SimplePlayer

def main():
    p = SimplePlayer("StairwayToHeaven_LedZeppelin.mp3")
    while True:
        if p.isPlaying:
            if input("Do you want to stop? (y/n)").lower() == 'y':
                print("stoped")
                break
        else:
            print("finished")
            break

if __name__ == "__main__":
    main()
```

**test2.py**
```python
from splay import SimplePlayer

def main():
    def finished():
        print("finished")
    
    p = SimplePlayer("StairwayToHeaven_LedZeppelin.mp3", finished)
    while True:
        if input("Do you want to stop? (y/n)").lower() == 'y':
            print("stoped")
            break

if __name__ == "__main__":
    main()
```
### gTTS와 음성 합성
gTTS는 구글 인공지능 음성 합성 서비스를 이용해 텍스트를 MP3 오디오 파일로 변환

