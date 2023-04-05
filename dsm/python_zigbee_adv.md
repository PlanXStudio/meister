## 1. Closure Overview
```python
from pop import Led
import time

print("Start :)")

def action(pattern):
    def inner():
        yield from pattern
    return inner

def ledShow(led):
    def run(action, wait=0.5):
        for a in action():
            led.on() if a else led.off()
            time.sleep(wait)
    return run

def main():
    led = Led()
    a = action([1, 1, 0, 1, 0, 0, 0, 1, 0, 1, 0])
    show = ledShow(led)
    show(a)

if __name__ == '__main__':
    main()
```

## 2. Sensing with closure & decorator
```python
from pop import Led
from pop import Battery, AmbientLight, Tphg
import time

print("Start :)")

def gen_caller(gen):
    g = gen()
    def wrapper():
        return next(g)
    return wrapper

def gen_caller2(arg):
    def caller(gen):
        g = gen(arg)
        def wrapper():
            return next(g)
        return wrapper
    return caller


@gen_caller
def getBattery():
    batt = Battery()
    max = 4.2
    min = 3.2
    block = 10
   
    step = (max-min) / block
    block_table = {i*10:(min+step*i) for i in range(block+1)}

    while True:
        val = batt.read()
        desc = "HIGH" if val >= block_table[80] else "MIDDLE" if val >= block_table[30] else "LOW"
        yield (val, desc)

@gen_caller
def getLight():
    light = AmbientLight()
    
    while True:
        val = light.read()
        yield val

@gen_caller
def getTphg():
    tpht = Tphg()
    while True:
        yield tpht.read()

@gen_caller
def getTempHumi():
    while True:
        t, _, h, _ = getTphg()
        yield (t, h)

@gen_caller
def ledSwitching():
    led = Led()
    while True:
        led.off() if led.stat() else led.on()
        yield

@gen_caller2(0.05)
def ledToggle(wait=0.1):
    while True:
        ledSwitching()
        time.sleep(wait)
        ledSwitching()
        time.sleep(wait)
        yield


def main():
    for _ in range(10):
        print("%.1f volt (%s)"%(getBattery()))
        print("%d lx"%(getLight()))
        print("%.1f, %.1f"%(getTempHumi()))
        time.sleep(1)
        ledToggle()

if __name__ == '__main__':
    main()
```

## Co-Routine
```python

from pop import Led
from pop import Battery, AmbientLight, Tphg
import time

print("Start :)")

def co_routine(func):
    def wrapper(*args, **kwargs):
        co = func(*args, **kwargs)
        next(co)
        return co
    return wrapper

@co_routine
def Altitude():
    tphg = Tphg()
    
    while True:
        sea_level = yield
        altitude, press = tphg.altitude(sea_level)
        yield (altitude, press)
        
def main():
    co = Altitude()
    for _ in range(5):
        print(co.send(1301.3))
        time.sleep(0.1)

if __name__ == '__main__':
    main()```
