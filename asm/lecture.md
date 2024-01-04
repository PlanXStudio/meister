## XNode Relay test
```python
from machine import Pin                                                                                
from time import sleep

def relay_create(ch):
    if ch == 1:
        pin = Pin('D0', Pin.OUT, value=0)
    elif ch == 2:
        pin = Pin('D6', Pin.OUT, value=0)
    elif ch == 3:
        pin = Pin('D5', Pin.OUT, value=0)
    else:
        pin = None
    return pin
        
def main():
    r1 = relay_create(1)
    r2 = relay_create(2)
    r3 = relay_create(3)

    r1.on()
    sleep(1)
    r1.off()
    
    r2.on()
    sleep(1)
    r2.off()

    r3.on()
    sleep(1)
    r3.off()

main()  
```
