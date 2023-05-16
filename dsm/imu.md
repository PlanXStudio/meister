## from issue

```python
try:
    from pop import IMU
except:
    try:
        from IMU import IMU
    except:
        from EXT_IMU import IMU
```

## Gen closure
```python
def gen_impl(f):
    g = f()
    def wapper():
        return next(g)
    return wapper
```

## IMU Example
```python
@gen_impl
def get_imu_calibration():
    imu = IMU()
    while True:
        yield imu.calibration() #sys, gyro, accel, mag
 
@gen_impl
def get_imu_9x():
    imu = IMU()
    while True:
        yield imu.accel(), imu.gyro(), imu.magnetic()
 
@gen_impl
def get_imu_euler():
    imu = IMU()
    while True:
        yield imu.euler() #azimuth, roll, pitch
 
@gen_impl
def get_imu_quat():
    imu = IMU()
    while True:
        yield imu.quat()
```

## Test
```python
def cal():
    while True:
        ret = get_imu_calibration()
        print(ret)
        if sum(ret) == 12:
            break
        time.sleep(0.1)

def euler():
    while True:
        print(get_imu_euler())
        time.sleep(0.05)

def main():
    cal()
    euler()


if __name__ == '__main__':
    main()
```
