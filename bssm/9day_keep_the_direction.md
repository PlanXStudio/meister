# Keep the direction with AI

## Pandas Upgrade
> sudo pip3 install --upgrade pandas

## Training
```python
from pop.Pilot import SerBot
from pop.Pilot import IMU
from pop import AI
import numpy as np
import time

bot = SerBot()
imu = IMU()
linear = AI.Linear_Regression(ckpt_name='ktd')

dataset = {'gyro':[], 'steer':[]}
bot.setSpeed(50)

for n in np.arange(-1.0, 1.0+0.1, 0.2):
    n = round(n, 1)
    bot.steering = n
    bot.forward()
    time.sleep(0.5)
    gy = imu.getGyro('z')
    time.sleep(0.5)
    bot.backward()
    time.sleep(1)
    bot.stop()
    n = -n #Is this correct ???

    dataset['gyro'].append([gy])
    dataset['steer'].append([n]) 

    print({'gyro':gy, 'steer':n}) 


linear.X_data = dataset['gyro']
linear.Y_data = dataset['steer']

linear.train(times=100, print_every=10)
```

## Prediction
```python
from pop.Pilot import SerBot
from pop.Pilot import IMU
from pop import AI
import time

bot = SerBot()
imu = IMU()
linear = AI.Linear_Regression(True, ckpt_name='ktd')

bot.forward()
bot.setSpeed(50)

try:
    while True: 
        pred = imu.getGyro('z')
        value = linear.run([pred])[0][0]
        
        """
        You need to calculate a reasonable value to put in here. 
        ex) (value+0.1) * 1.5
        """
        bot.steering = 1.0 if value > 1.0 else -1.0 if value < -1.0 else value 
        
        time.sleep(0.1)
except KeyboardInterrupt:
    bot.stop()
```
