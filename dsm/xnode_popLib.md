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

**Uart**
- Uart()
  - Create Uart Object
- write(data)
  - write string
- read()
  - read byte

```python
from pop import Uart
from pop import Led, Battery

uart = Uart()
led = Led()
battery = Battery()

uart.write("Start...\n")

while True:
    cmd = uart.read().decode()
    if cmd == 'q':
        break
    elif cmd == 'l':
        led.off() if led.stat() else led.on()
	uart.write("\nLed %s\n"%("ON" if led.stat() else "OFF"))
    elif cmd == 'b':
        uart.write("\nBattery: %.2f Volt\n"%(battery.read()))
    else:
        uart.write("\nUnknown command\n")
uart.write("\nThe End...\n")
```
>> *xnode -pcom<port_num> run -i <file_name>.py*
>>> *-i* is echo

**File**
- open(file, mode)
  - Create file object
    - file: file name
    - mode: 'r' (read: default) or 'w' (write). --> 'a' (append) is not support
- write(data)
  - write data to file
- readline()
  - read a file line by line. None if there are no more lines to read 
- close()
  - close file

```python
from pop import Led, Light, Tphg
import time, os

led = Led()
light = Light()
tphg = Tpht()

f_name = 'sensors.dat'

if f_name in os.listdir():
    os.remove(f_name)

f = open(f_name, 'w')

f.write('LIGHT, TEMP, HUMI\n')

for _ in range(10):
    led.off() if led.stat() else led.on()
    
    l = light.read()
    t, _, h, _ = tphg.read()
    
    data = "%d,%.2f,%.2f"%(l, t, h)
    
    print(data)
    f.write(data+'\n')
    time.sleep(1)
    
f.close()
```
>> *xnode -pcom<port_num> put <file_name>.py main.py*  
>>> XNode reset  
  
>> *xnode -pcom<port_num> get sensors.dat sensors.dat*  


```python
f_name = 'sensors.dat'

f = open(f_name)

while True:
    data = f.readline()
    if not data:
        break
    print(data,end='')
     
f.close()
```
