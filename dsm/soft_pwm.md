```python
from pop import Led
import time

class LedPwm(Led):
    def __init__(self, freq=100, max_level=10, debug=False):
        super().__init__()
        self.__freq_ms = 1/freq
        self.__max_level = max_level
        self.__debug = debug
        
        self.__hi_ms = self.__freq_ms
        self.__low_ms = self.__freq_ms - self.__hi_ms
    
    def __bright(self):
        self.on()
        time.sleep(self.__hi_ms)
        self.off()
        time.sleep(self.__low_ms)
    
    def bright(self, level):
        if level == 0:
            self.off()
            return
        self.__hi_ms = self.__freq_ms / (self.__max_level/level)
        self.__low_ms = self.__freq_ms - self.__hi_ms
        self.__bright()
        if (self.__debug):
            print(self.__freq_ms, self.__hi_ms, self.__low_ms)

led = LedPwm()	

for n in range(10, -1, -1):
    print("current level: %d"%(n))
    for i in range(1, 100*2+1):
        led.bright(n)
led.off()
```
