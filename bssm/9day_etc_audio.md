## Install
```sh
sudo pip3 install playsound 
```
## TTS
```sh
gtts-cli -l ko -o <filename>.mp3 "<text>"
play <filename>.mp3
```
## Simple Play
```python
from playsound import playsound

playsound('./start.mp3')
```

## Multiple Play
```python
import multiprocessing
from playsound import playsound

play_list = ['beatles_yellow_submarine.mp3', 'led_zeppelin_stairway_to_heaven.mp3', 'acdc_thunderstruck.mp3']

for s in play_list:
    p = multiprocessing.Process(target=playsound, args=(s,))
    p.start()
    input("press ENTER to next playback")
    p.terminate()

print("Stop Play")
```
