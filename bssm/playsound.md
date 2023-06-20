## Install playsound
```sh
pip3 install playsound 
```

## Class implementation
- PlaySound.py
```python
from playsound import playsound
from multiprocessing import Process

class PlaySound:
    def __init__(self, paths=()):
        self._paths = paths
        self._curr_pos = 0
        self._last_pos = len(paths) - 1

    def __del__(self):
        self.stop()

    def __play(self):
        self.stop()
        self._task = Process(target=playsound, args=(self._paths[self._curr_pos],))
        self._task.start()

    def is_play(self):
        return hasattr(self, '_task') and self._task.is_alive()

    def play(self):
        if self.is_play():
            return

        self.__play()

    def next(self):
        self._curr_pos += 1
        if self._curr_pos > self._last_pos:
            self._curr_pos = 0

        self.__play()

    def prev(self):
        self._curr_pos -= 1
        if self._curr_pos < 0:
            self._curr_pos = self._last_pos
            
        self.__play()

    def stop(self):
        if hasattr(self, '_task') and self._task.is_alive():
            self._task.terminate()
            self._task.join()                
```

## Test code
- PlaySound_Test.py
```python
from PlaySound import PlaySound

def main():
    paths= ('p_start.mp3', 'p_next.mp3', 'p_stop.mp3')
    ps = PlaySound(paths)

    while True:
        num = int(input())
        if num == 1:
            ps.play()
        elif num == 2:
            ps.next()
        elif num == 3:
            ps.prev()
        elif num == 4:
            ps.stop()
        elif num == 5:
            break


if __name__ == "__main__":
    main()
```
