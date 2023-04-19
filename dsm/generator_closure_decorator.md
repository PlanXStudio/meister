## Overview
### 1. Get sensor data with Generator 
```python
def get_battery():
    batt = Battery()
    while True:
        yield batt.read()

gen_battery = get_battery()
result = next(gen_battery)
```

### 2. Add Closures 
> Creating generators and hiding next() calls
```python
def outer(f):
  g = f()
  def inner():
    return next(g)
  return inner
  
def get_battery():
    batt = Battery()
    while True:
        yield batt.read()
```
**Step1**
```python
inner_gen_battery = outer(get_battery)
result = inner_gen_battery()
```
**Step2-1**
```python
get_battery = outer(get_battery)
```
**Step2-2**
```python
result = get_battery()
```

### 3. Add Decorator 
> Passing a function into a closure and hiding the inner function return
```python
def outer(f):
  g = f()
  def inner():
    return next(g)
  return inner

@outer  #Step2-1 automatic processing
def get_battery():
    batt = Battery()
    while True:
        yield batt.read()

result = get_battery()
```

## All Code

```python
from pop import Battery
from pop import AmbientLight
from pop import Tphg
import time, os

def outer(f):
    g = f()
    def inner():
        return next(g)
    return inner

@outer
def get_battery():
    batt = Battery()
    while True:
        yield batt.read()

@outer
def get_light():
    light = AmbientLight()
    while True:
        yield light.read()

@outer
def get_tphg():
    tphg = Tphg()
    while True:
        yield tphg.read()

def main():
    F_NAME = "sensor.dat"
    if F_NAME in os.listdir():
        os.remove(F_NAME)
    
    f = open(F_NAME, 'w')
    f.write("BATTER, LIGHT, TEMP, PRESS, HUMI, GAS\n") #CSV(Comma-Separated-Values)
    while True:
        b = get_battery() 
        l = get_light()
        t, p, h, g = get_tphg() # Return tuple(temp, press, humi, gas)
        fmt = "%.1f, %.2f, %.2f, %.2f, %.2f, %.2f"%(b, l, t, p, h, g)
        print(fmt)
        f.write(fmt + '\n')
        time.sleep(1)
    
if __name__ == "__main__":
    main()
```
## Test
```sh
> xnode scan
  - com_port list
  
> xnode -p<com_port> run <file>.py
  - ...result...
  - <Ctrl>c

> xnode -p<com_port> ls /flash
  - file list
  
> xnode -p<com_port> get <xnode_file_name> <local_file_name>
```
