## LED Sender
```python
from pop import Led, time

mos_table = {
    'A':".-", 'B':"-...", 'C':"-.-.", 'D':"-..", 'E':".", 'F':"..-.", 'G':"--.", 'H':"....", 'I':"..", 'J':".---", 'K':"-.-", 'L':".-..", 'M':"--", 'N':"-.", 
    'O':"---", 'P':".--.", 'Q':"--.-", 'R':".-.", 'S':"...", 'T':"-", 'U':"..-", 'V':"...-", 'W':".--", 'X':"-..-", 'Y':"-.--", 'Z':"--.."
}

def mos(ch, dot=0.2):
    for m in mos_table[ch]:
        l.on()
        time.sleep(dot) if m == '.' else time.sleep(dot*3)
        l.off()
        time.sleep(dot) 

l = Led()

while True:
    mos('S')
    mos('O')
    mos('S')
```

## AmbientLight Receiver
```python
from pop import AmbientLight
from pop import time
	
lx = AmbientLight(True)
t0 = time.ticks_ms()

while True:
    if time.ticks_ms() - t0 >= 100:
        t0 = time.ticks_ms()
        val = lx.read()
        print(val)
        """
        if val > 35:
            print(1)
        else:
            print(0)
        """
```
