## Overview
```python
import Jetson.GPIO as GPIO
import time

PWM_PIN = 33

GPIO.setwarnings(False)
GPIO.setmode(GPIO.BOARD)
GPIO.setup(PWM_PIN, GPIO.OUT)

pwm = GPIO.PWM(PWM_PIN, 50)
pwm.start(50.0)

while True:
    time.sleep(1)
    print("hello, pwm")

pwm.stop()
GPIO.cleanup()
```

## Python Library for Jetson
- Jetson Xavier NX GPIO Header J12 PINOUT
> https://jetsonhacks.com/nvidia-jetson-xavier-nx-gpio-header-pinout/

- Jetson-IO
```sh
> sudo /opt/nvidia/jetson-io/jetson-io.py
```

- Jetson.GPIO - Linux for Tegra
> https://github.com/NVIDIA/jetson-gpio

## VSCode Development Environment
- Start
   - VSCode Remote connection
   - Install Python Extensions
- main() function 
  ```python
  def main():
      pass
      
  if __name__ == "__main__":
      main()
  ```
- Run & Debugging
- Jupyter Notebook
  - #%%
  - .ipynb
  
## Advanced
- Generator
> https://wikidocs.net/16069

- First-class fucntion
> https://velog.io/@tmqjf4921/Python-%EC%9D%BC%EA%B8%89%ED%95%A8%EC%88%98-%EA%B8%B0%EB%B3%B8-%ED%8A%B9%EC%A7%95

- Closure
> https://yeonfamily.tistory.com/11

- Decorator
> https://wikidocs.net/160127
