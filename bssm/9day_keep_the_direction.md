# Keep the direction with AI

## Pandas Upgrade
> sudo pip3 install --upgrade pandas

## Training
- ktd_training.py
```python
from pop.Pilot import SerBot
from pop.Pilot import IMU
from pop.AI import Linear_Regression
import numpy as np
import time

bot = SerBot()
imu = IMU()
linear = Linear_Regression(ckpt_name='ktd')

dataset = {'gyro_z':[], 'steer':[]}
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

    dataset['gyro_z'].append([gy])
    dataset['steer'].append([n]) 

    print({'gyro_z':gy, 'steer':n}) 


linear.X_data = dataset['gyro_z']
linear.Y_data = dataset['steer']

linear.train(times=100, print_every=10)
```

## Prediction
- ktd_prediction.py
```python
from pop.Pilot import SerBot
from pop.Pilot import IMU
from pop.AI import Linear_Regression
import time

bot = SerBot()
imu = IMU()
linear = Linear_Regression(True, ckpt_name='ktd')

bot.forward()
bot.setSpeed(50)

try:
    while True: 
        gz = imu.getGyro('z')
        pred_steer = linear.run([gz])[0][0]
        
        """
        You need to calculate a reasonable 'pred_steer' to put in here. 
        ex) (pred_steer+0.1) * 1.5
        """
        bot.steering = 1.0 if pred_steer > 1.0 else -1.0 if pred_steer < -1.0 else pred_steer 
        
        time.sleep(0.1)
except KeyboardInterrupt:
    bot.stop()
```
