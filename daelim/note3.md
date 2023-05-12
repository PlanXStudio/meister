# QT5 for python3

## Overview
![Event loop](https://www.pythonguis.com/tutorials/pyqt6-creating-your-first-window/event-loop.png)

```python3
from PyQt5.QtCore import QSize, Qt
from PyQt5.QtWidgets import QApplication, QMainWindow, QPushButton
from PyQt5.QtCore import QCoreApplication

import sys

class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()

        self.setWindowTitle("My App")
        
        button = QPushButton("Press Me!")
        button.clicked.connect(QCoreApplication.instance().quit)

        self.setFixedSize(QSize(400, 300))
        self.setCentralWidget(button)

def main():
    app = QApplication(sys.argv)

    window = MainWindow()
    window.show()

    app.exec()

if __name__ == '__main__':
    main()    
```

## Install
- Install nomachine on your PC
[Nomachine Client](https://www.nomachine.com/)

  - [gettting started](https://www.nomachine.com/getting-started-with-nomachine)

- Install pyqt5 on Mavin
> preinstall
```sh
sudo apt install python3-pyqt5
```
> append 
  - for Multimedia
```
sudo apt install python3-pyqt5.qtmultimedia
```

  - for Designer
```sh
sudo apt install pyqt5-dev-tools
```

  - for GTK style (hold)
```sh
sudo apt-get build-dep qt5-default
sudo apt install libcanberra-gtk-module
sudo apt install qt5-style-plugins 
echo "export QT_QPA_PLATFORMTHEME=gtk2" >> ~/.profile
```

## Tutorials
[Official](https://doc.qt.io/qtforpython-6/tutorials/index.html#)  
[Blog](https://wikidocs.net/21923)
