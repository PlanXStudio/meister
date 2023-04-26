## 층별 고도 계산
- 4개층에 기압센서로 고도를 계산하는 라우터 노드 설치
- 코디 노드는 브로드캐스트로 해면기압 전송
- 해면기압을 수신한 각 노드는 고도를 계산해 코디 노드에 전송

### Coordinator
- client.py
```python
from pop import xnode
from pop import Tphg

import time

tphg = Tphg()
   
while True:
    p = xnode.receive()
    if p:
        sea = float(p['payload'])
        altitude, _ = tphg.altitude(sea) 
        xnode.transmit(p['sender_eui64'], str(altitude))
    else:
        time.sleep(0.1)
```

- xnode -p<com_port> run client.py

### Router
- server.py
```python
from pop import xnode
from time import sleep

flags = 4

while True:
    xnode.transmit(xnode.ADDR_BROADCAST, str(1012.9))
    while (flags):   
        p = xnode.receive()
        if p:
            flags -= 1
            print(p['sender_eui64'], str(p['payload']))
        else:
            sleep(0.1)
    sleep(10)
```

- xnode -p<com_port> put server.py main.py
