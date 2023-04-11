## [종합 과제] IMU, Lidar 기반 정적 경로 주행
- 5m 왕복 주행
  - 5m 직진 후 턴, 다시 5m 직진 후 출발지에 멈춤 
- IMU의 Yaw 값을 이용해 최대한 직진성 유지
- Lidar로 충돌이 감지되면 우회

```python
from pop.Pilot import SerBot
from pop.Pilot import IMU
from pop.LiDAR import Rplidar
import timeit

bot = None
imu = None
lidar = None
DEST2TIME = 5000
DETECT = 300
CHECK_TURN = False

def init():
    global bot, imu, lidar
    
    bot = SerBot()
    imu = IMU()
    lidar = Rplidar()

    bot.setSpeed(50)
    bot.forward()

    lidar.connect()
    lidar.startMotor()

def destroy():
    bot.stop()
    lidar.stopMotor()

def forward_detect(point_frame, dest):
    for p in point_frame:
        if p[0] > (360-30) or p[0] < (0+30):
            if p[1] <= dest:
                return True
        else:
            return False

def turn_180():
    pass

def stablilizer(yaw):
    pass

def main():
    global CHECK_TURN

    init()

    t0_ms = timeit.default_timer()

    while True:
        t1_ms = timeit.default_timer()
        if (t1_ms - t0_ms) * 1000 >= DEST2TIME:
            if not CHECK_TURN:
                CHECK_TURN = True
                turn_180()
                t0_ms = timeit.default_timer()
            else:
                break

        yaw = tuple(imu.getGyro().values())[2]
        point_frame = lidar.getVectors()

        stablilizer(yaw)
        detect = forward_detect(point_frame, DETECT)
    
        print(yaw, detect)

    destroy()

if __name__ == "__main__":
    main()
```
