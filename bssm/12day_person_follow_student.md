## 박창은/이주형
```python
from pop import Camera
from pop.Pilot import Object_Follow
from pop.Pilot import SerBot

bot = None
of = None
cnt = 0

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
    global cnt
    person = of.detect(index='person')
    if person:
        cnt = 0
        x = round(person['x'] * 4, 1)
        rate = round(person['size_rate'], 2)
        
        if rate < 0.1:
            bot.setSpeed(90)
        elif rate < 0.15:
            bot.setSpeed(80)
        elif rate > 0.3:
            bot.stop()
        else:
            bot.forward(60)
            bot.steering =  1.0 if x > 1.0 else -1.0 if x < -1.0 else x
 
        print(f"{rate}, {bot.steering}")            
    else:
        if cnt > 40:
            bot.stop()
            print("person not dectected...")  
        elif cnt == 20:
            bot.setSpeed(50)
            if bot.steering < 0:
                bot.turnLeft()
            else:
                bot.turnRight()
            cnt += 1
        else:
            print("waiting person")
            cnt += 1
 
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
