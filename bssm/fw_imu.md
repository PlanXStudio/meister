```python
from pop.Pilot import SerBot, IMU
import timeit

bot = SerBot()
imu = IMU()

bot.setSpeed(60)
bot.forward()
count = 0
delay = False

t0_10 = timeit.default_timer()
while True:
    t1_10 = timeit.default_timer()
    if (t1_10-t0_10) * 10000 >= 100:
        t0_10 = t1_10
        count += 1
        if tuple(imu.getGyro().values())[2]:      
            bot.steering = -1.0
            delay = True
            t0_1 = timeit.default_timer()

    if (delay):
        t1_1 = timeit.default_timer()
        if (t1_1-t0_1) * 10000 >= 10:
            delay = False
            bot.steering = 0.0
            
    if count > 500:
        break
bot.stop()

```
