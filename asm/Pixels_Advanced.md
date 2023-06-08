## Manual Mode
```python
from pop import Pixels

pixel = None

def draw_line(y, color):
    for x in range(0, 16, 1):
        pixel.drawPixel(x, y, color)
    pixel.update()

def main():
    global pixel

    pixel = Pixels()
    pixel.setMode(False)

    draw_line(5, (0,0,255))
    draw_line(7, (0,255,255))
    draw_line(9, (255,0,255))

    try:
        while True:
            pass
    except KeyboardInterrupt:
        pass
```
