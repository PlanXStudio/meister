# Pop Library for XNode (type B)

## Basic
> import time   
> from pop import Led, Battery, AmbientLight, Tphg

**time module**
- sleep(n)
  - Delay time
  - n: seconds. Milliseconds if decimal point is used
- sleep_ms(n)
  - Delay time in milliseconds
- ticks_ms()
  - Return integer unit count times
- ticks_diff(m, n)
  - m, n: number of counts in integer units
  - Calculate and return the difference between the two

```python
import time

start = time.ticks_ms()

time.sleep(1)
time.sleep_ms(500)

delta = time.ticks_diff(time.ticks_ms(), start)

print("Operation took %d ms to execute"%(delta))
```

```python
t0 = time.ticks_ms()
while True:
    t1 = time.ticks_ms()
    if (t1 - t0 => 10): #10ms
        t1 = t0
	#todo
```

**Led Class**
- Led()
  - Create LED Object  
- on()
  - LED ON
- off()
  - LED OFF
- stat()
  - Return true if the LED is on, otherwise it is off

```python
from pop import Led
import time

hz100 = 1/100

l = Led()	
print("max light")
l.on()
time.sleep(2)

print("1/2 light")
for i in range(1, 50*2+1):
    l.off()
    print(1 if l.stat() else 0, end='')
    time.sleep(int(hz100/2)) 
    l.on()
    time.sleep(int(hz100/2))
    print(1 if l.stat() else 0, end='')
l.off()
```

```python
from pop import Led
import time

class LedEx(Led):
    def __init__(self):
        super().__init__()

    def toggle(self):
        self.off() if self.stat() else self.on()

l = LedEx()	

for _ in range(10):
    l.toggle()
    print("Led on" if l.stat() else "Led off")
    time.sleep(.1)
```

**Batter Class**
- Battery()
  - Create Batter Object
- read()
  - Returns the actual battery voltage. Charging is required if below 3.2V

```python
from pop import Battery
import time

b = Battery()

max = 4.2
min = 3.2
block = 10
   
step = (max-min) / block
block_table = {i*10:(min+step*i) for i in range(block+1)}
print(block_table)

for _ in range(10):
    val = b.read()
    print("Battery: %.1f Volt"%(val), end=", ")
    print("HIGH") if val >= block_table[80] else print("MIDDLE") if val >= block_table[30] else print("LOW")
    time.sleep(1)
```

**AmbientLight Class**
- AmbientLight(cont=False)
  - Create AmbientLight Object
    - cont: If true, use continuous measurement mode. Default is False 
- read()
  - Returns the illuminance value in lux
- stop()
  - Stop measurement when in continuous measurement mode

```python
from pop import AmbientLight
import time
	
lx = AmbientLight(True)
t0 = time.ticks_ms()

while True:
    t1 = time.ticks_ms()
    if time.ticks_diff(t1, t0) >= 1000:
        t0 = t1
        val = lx.read()
        print("light = %d lx"%(val))

lx.stop() #do not run!
```

**Tphg Class**
- Tphg()
  - Create Tpgh Object
- read()
  - The return value is a tuple object (temperature, barometric pressure, humidity, gas)
- sealevel(altitude)
  - altitude: current measured altitude
  - The return value is a tuple object (sea level pressure, barometric pressure)
- altitude(sealevel)
  - sealevel: current measurement of sea level pressure
  - Returns a tuple object (altitude, barometric pressure)

```python
from pop import Tphg
import time

tphg = Tphg()
   
for _ in range(5):
    temp, _, humi, _ = tphg.read()
    print("Temp = %.1f C, Humi = %.1f RH"%(temp, humi))
    time.sleep(1)
```

```python
from pop import Tphg
import time

tphg = Tphg()
   
for _ in range(5):
    altitude, press = tphg.altitude(1013.4) #https://www.weather.go.kr/weather/observation/currentweather.jsp
    print("Altitude = %d m, Pressure = %d"%(altitude, press))
    time.sleep(1)
```

```python
from pop import Tphg
import time

tphg = Tphg()
   
for _ in range(5):
     sea_level, press = tphg.sealevel(88) #dsm altitude (https://earth.google.com/web/)
     print("Sea Level = %.1f hPa, Pressure = %d"%(sea_level, press))
     time.sleep(1)
```
