## Settings
> **[AT commands](https://www.digi.com/resources/documentation/Digidocs/90002002/Containers/cont_at_cmds.htm?tocpath=AT%20commands%7C_____0)**

**get/set Extended PAN ID(EPID) :) 8Byte (0x00 ~ 0xFFFFFFFF_FFFFFFFF)***
```python
from pop import xnode

id = xnode.atcmd("ID")
print(id)

xnode.atcmd("ID", 0x06)
xnode.atcmd("WR")

id = xnode.atcmd("ID")
print(id)
```

**Coordinator for Node_1**
```python
from pop import xnode

xnode.atcmd("CE", 1) #Coordinator Enable
xnode.atcmd("ID", 0) #Automatic selection from PAN Network
xnode.atcmd("NI", "Coordinator_X2") #Node Identifier
xnode.atcmd("SC", 0b0000_0000_0000_0001) #Scan Channel Mask. CH11(0x0B):0bit ~ CH26(0x1A):15bit
xnode.atcmd("WR")
xnode.atcmd("FR") #Software Reset 
```
> *xnode -pcom<port_num> run -n <file_name>.py*

**Router for Node_2**
```python
from pop import xnode

xnode.atcmd("CE", 0)
xnode.atcmd("ID", 0)
xnode.atcmd("NI", "Router_X01")
xnode.atcmd("SC", 0b0000_0000_0000_0001)
xnode.atcmd("JV", 1) #Coordinator Join Verification
xnode.atcmd("WR")
xnode.atcmd("FR")
```
> *xnode -pcom<port_num> run -n <file_name>.py*

**Router for Node_3**
```python
from pop import xnode

xnode.atcmd("CE", 0)
xnode.atcmd("ID", 0)
xnode.atcmd("NI", "Router_X02")
xnode.atcmd("SC", 0b0000_0000_0000_0001)
xnode.atcmd("JV", 1) #Coordinator Join Verification
xnode.atcmd("WR")
xnode.atcmd("FR")
```
> *xnode -pcom<port_num> run -n <file_name>.py*

**Get Information**
```python
from pop import xnode

print("Association Indication: 0x%02X"%(xnode.atcmd("AI")))
print("Node Identifier: %s"%(xnode.atcmd("NI")))
print("PAN ID: %s"%(xnode.atcmd("ID")))
print("Channel: %d"%(xnode.atcmd("CH")))
```

## Communication  

**Discovery**
> **[discover()](https://www.digi.com/resources/documentation/digidocs/90002219/reference/r_function_discover.htm?tocpath=XBee%20module%7CXBee%20MicroPython%20module%20on%20the%20XBee%203%20RF%C2%A0Modules%7C_____2)**
```python
from pop import xnode

scan = xnode.discover()
for i in scan:
    print(i)
```

**Receiver for Node_1 or Node_2**
> **[receive()](https://www.digi.com/resources/documentation/digidocs/90002219/reference/r_function_receive.htm?tocpath=XBee%20module%7CXBee%20MicroPython%20module%20on%20the%20XBee%203%20RF%C2%A0Modules%7C_____3)**
```python
from pop import xnode
import time

while True:
    p = xnode.receive()
    print('.', end='')
    if p:
        print('\n',p)
    else:
        time.sleep(0.1)
```

**Sender for Node_2 or Node_3**
> **[transmit()](https://www.digi.com/resources/documentation/digidocs/90002219/reference/r_function_transmit.htm?tocpath=XBee%20module%7CXBee%20MicroPython%20module%20on%20the%20XBee%203%20RF%C2%A0Modules%7C_____5)**
```python
from pop import xnode

xnode.transmit(xnode.ADDR_BROADCAST, "hello")

xnode.transmit(xnode.ADDR_COORDINATOR, "good-bye")
```

**Sender for Node_3**
```python
from pop import xnode

dist_eui64 = None
scan = xnode.discover()
for info in scan:
    if info['node_id']=='Router_X01':
        dist_eui64 = info['sender_eui64'] 

if dist_eui64:
    print(dist_eui64)
    xnode.transmit(dist_eui64, "hi, i am Route_X02!!!")
```

**Tx Power**
```python
from pop import xnode
import time

pl = 0x00

while True:
    if pl <= 0x04:
        xnode.atcmd('PL',pl) #Power Level (default 0x04(max))
        print('PL' + str(pl))
        pl += 0x01
        time.sleep(5)
    else:
        pl = 0x00 
```

**Rx Power**
```python
from pop import xnode

while True:
    try:
        for device in xnode.discover():
            print("NI : ", device['node_id'], ", rssi : ",device['rssi'],", DB : ", xnode.atcmd('DB'))
    except:
        pass
```
