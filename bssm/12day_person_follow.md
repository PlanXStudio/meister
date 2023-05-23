```python
from pop import Camera
from pop.Pilot import Object_Follow
from pop.Pilot import SerBot

bot = None
of = None

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
    person = of.detect(index='person')
    if person:
        x = round(person['x'] * 4, 1)
        rate = round(person['size_rate'], 1)
        
        if rate > 0.2:
            bot.stop()
        else:
            bot.forward(60)
            bot.steering =  1.0 if x > 1.0 else -1.0 if x < -1.0 else x
 
        print(f"{rate}, {bot.steering}")            
    else:
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
