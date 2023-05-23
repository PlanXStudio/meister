## 이준영, 김지윤
```python
import time
from pop import Camera
from pop.Pilot import Object_Follow
from pop.Pilot import SerBot

bot = None
of = None
person_not_found = False
person_not_found_cnt = 0

def setup():
    global bot, of

    cam = Camera()
    of = Object_Follow(cam)
    bot = SerBot()

    of.load_model()
    print("="*50)
    print("Model load ok!")
    print("It starts in about 10 seconds.")

def loop():
    global person_not_found_cnt, pre_rate, person_not_found

    person = of.detect(index='person')
    if person:
        person_not_found_cnt = 0
        person_not_found = False
        x = round(person['x'] * 4, 1)
        rate = round(person['size_rate'], 1)

        bot.steering =  1.0 if x > 1.0 else -1.0 if x < -1.0 else x

        if rate > 0.4:
            person_not_found = True
            bot.stop()
        elif rate > 0.3:
            bot.forward(40)
        elif rate > 0.2:
            bot.forward(60)
        else:
            bot.forward(80)

        print(f"{rate}, {bot.steering}")
    else:
        if person_not_found == False:
            person_not_found_cnt += 1
            if person_not_found_cnt > 5:
                bot.setSpeed(50)
                if bot.steering < 0:
                    bot.turnLeft()
                    time.sleep(0.3)
                elif bot.steering > 0:
                    bot.turnRight()
                    time.sleep(0.3)
                else:
                    bot.stop()
                person_not_found = True
        bot.stop()
        print("person not dectected...")  
 
def main():
    setup()
    while True:
        try:
            loop()
        except KeyboardInterrupt:
            break
    
    bot.stop()

if __name__ == '__main__':
    main()
```
## 황우석, 김민세
```python
from pop import Camera
from pop.Pilot import Object_Follow
from pop.Pilot import SerBot
from lidar import Lidar

bot = None
of = None
lidar = None

person_not_found_cnt = 0
flag = 0
lidarNotCount = 0

def setup():
    global bot, of, lidar

    direction_count = 8

    cam = Camera()
    of = Object_Follow(cam)
    bot = SerBot()
    lidar = Lidar(500, direction_count)

    of.load_model()
    print("="*50)
    print("Model load ok!")
    print("It starts in about 10 seconds.")

def loop():
    global person_not_found_cnt, flag, lidarNotCount

    person = of.detect(index='person')
    if person:
        detect = lidar.collisonDetect(500)

        person_not_found_cnt = 0
        x = round(person['x'] * 4, 1)
        rate = round(person['size_rate'], 1)
        
        if detect[0] == 1 or detect[-1] == 1:
            lidarNotCount = 0
            bot.stop()
        else:
            lidarNotCount += 1
            if lidarNotCount >= 5 :
                bot.forward(60)
                bot.steering =  1.0 if x > 1.0 else -1.0 if x < -1.0 else x
                flag = 0 if x < 0 else 1 
 
        print(f"{x}, {bot.steering}")            
    else:
        if lidarNotCount < 5:
            bot.stop()
        elif person_not_found_cnt >= 10:
            if flag:
                bot.turnRight()
            else :
                bot.turnLeft()
        else :
            person_not_found_cnt += 1
 
def main():
    setup()
    while True:
        try:
            loop()
        except KeyboardInterrupt:
            break
    
    bot.stop()

if __name__ == '__main__':
    main()
```
