# TCP/IP 네트워크 실습
> 리눅스와 윈도우 환경에 차이가 있음. 구분해 실습 진행

## 네트워크 환경
*네트워크 인터페이스 이름과 MAC 주소 확인*
- Linux
```sh
ip link
```

- Windows
```ps
getmac /v
```  

*연결 이름에 부여된 IP 및 서브넷 마스크 확인*
- Linux
```sh
ip address
```

- Windows
```sh
ipconfig /all
```

*윈도우에서 IP 네트워크 테스트*
```sh
ping <wsl linux ip>
ping www.google.co.kr
```

*ARP 테이블 확인*
```sh
arp -a
```

*라우터(게이트웨이) 설정 확인*
- Linux
```sh
ip route
```

- Windows
```ps
route PRINT -4
```

*라우팅 경로 확인*
- Linux
```sh
sudo apt install traceroute
traceroute www.google.co.kr
```

- Window
```ps
tracert www.google.co.kr
```

<br/>

# 소켓 인터페이스

## RAW 소켓
> 관리되지 않은(raw) 소켓으로 데이터 링크 서비스 구현
>> 먼저 대상의 MAC 주소를 파악해야 합니다. 코드 상의 dst와 src 변수가 가리키는 값은 MAC 주소를 문자열로 표현한 것입니다.
>> 자신의 MAC 주소를 dst와 src에 대입해도 관계없습니다.

### sender.py
```python
from socket import socket, AF_PACKET, SOCK_RAW, htons

def send_link(dst, src, payload, type = "0800", interface="eth0"):
    s = socket(AF_PACKET, SOCK_RAW, htons(3)
    s.bind((interface, 3))

    frame = bytearray.fromhex(dst + src + type) + payload.encode()

    return s.send(frame)

def main():
    dst = "00155d11c9ca"
    src = "00155d11c9ca"
    payload = input("payload: ")
    
    send_link(dst, src, payload)

if __name__ == "__main__":
    main()
```

*반드시 관리자 권한으로 실행*
```sh
sudo python3 sender.py
```

### receiver.py
```python
from socket import socket, AF_PACKET, SOCK_RAW, htons

def ba2hs(ar, fmt=''):
    return fmt.join(f"{b:02x}" for b in ar)

def recv_link(interface="eth0"):
    s =socket(AF_PACKET, SOCK_RAW, htons(3))
    s.bind((interface, 0))
    
    frame = s.recv(1516)

    dst = ba2hs(frame[:6], ':')
    src = ba2hs(frame[6:12], ':')
    type = ba2hs(frame[12:14]) 

    try:
        payload = frame[14:].decode()
    except UnicodeDecodeError:
        return

    print(f"{dst = }")
    print(f"{src = }")
    print(f"{type = }")        
    print(f"{payload = }")

def main():
    while True:
        try:
            recv_link()
        except KeyboardInterrupt:
            break
        
if __name__ == "__main__":
    main()
```

## TCP 소켓
> raw 소켓이 아니라면 관리자 권한으로 실행할 필요가 없습니다.

### tcp_server.py

```python
from socket import socket, AF_INET, SOCK_STREAM,  SOL_SOCKET, SO_REUSEADDR
import struct

class SimpleTCPServer:
    def __init__(self, adapter="0.0.0.0", server_port=49001):       
        self._sock = socket(AF_INET, SOCK_STREAM)
        self._sock.setsockopt(SOL_SOCKET, SO_REUSEADDR, 1)
        self._sock.bind((adapter, server_port))
        self._sock.listen(5)

    def __del__(self):
        self._sock.close()

    def receive(self, buf_size=1500):
        conn_sock, addr = self._sock.accept()

        fmt = conn_sock.recv(buf_size)
        data = conn_sock.recv(buf_size)
        conn_sock.close()

        return addr, struct.unpack(fmt, data)

def main():
    srv = SimpleTCPServer()
    data = srv.receive()    
    print(f"{data[0]}, {data[1][0].decode()}, {data[1][1]}, {data[1][2]:.3}")

if __name__ == "__main__":
    main()

```

### tcp_client.py

```python
from socket import socket, AF_INET, SOCK_STREAM
import struct
import time

class SimpleTCPClient:
    def __init__(self, server_ip="127.0.0.1", server_port=49001):
        self._conn_sock = socket(AF_INET, SOCK_STREAM)
        self._conn_sock.connect((server_ip, server_port))

    def send(self, fmt, *data):
        self._conn_sock.send(fmt.encode())
        time.sleep(0.1)
        self._conn_sock.send(struct.pack(fmt, *data))
        self._conn_sock.close()

def main():
    fmt = "11sIf"
    msg = ["hi, Python!", 1024, 3.14]
    
    client = SimpleTCPClient()

    msg[0] = msg[0].encode()
    client.send(fmt, *msg)

if __name__ == "__main__":
    main()
```

### tcp_echo_server.py

```python
from socket import socket, AF_INET, SOCK_STREAM,  SOL_SOCKET, SO_REUSEADDR
from threading import Thread
import struct
import time

class SimpleEchoServer(Thread):
    def __init__(self, ip="0.0.0.0", port=49001):
        super(SimpleEchoServer, self).__init__()

        self._sock = socket(AF_INET, SOCK_STREAM)
        
        self._sock.setsockopt(SOL_SOCKET, SO_REUSEADDR, 1)
        self._sock.bind((ip, port))
        self._sock.listen(5)
        self._sock.setblocking(False)

        self.start()
    
    def terminate(self):
        self._sock.close()

    def __work_thread(self, sock):
        data = sock.recv(1500)
        t = time.time()
        data = struct.pack("d", t) + data
        print(t, data[8:].decode())
        sock.send(data)
        sock.close()

    def run(self):
        while True:
            try:
                conn_sock, addr = self._sock.accept()
                print(f"Client IP: {addr[0]}, Port: {addr[1]}")
            except BlockingIOError:
                continue
            except OSError:
                break

            Thread(target=self.__work_thread, args=(conn_sock,)).start()

def main():
    echo_srv = SimpleEchoServer()
    input("Press the Enter key to exit.\n")
    echo_srv.terminate()
    
if __name__ == "__main__":
    main()

```

### tcp_echo_client.py
```python
from socket import socket, AF_INET, SOCK_STREAM
import struct
import time

class SimpleEchoClient:
    ECHO_DATA = "0123456789"

    def __init__(self, server_ip="127.0.0.1", server_port=49001):
        conn_sock = socket(AF_INET, SOCK_STREAM)
        
        conn_sock.connect((server_ip, server_port))

        conn_sock.send(self.ECHO_DATA.encode())
        data = conn_sock.recv(1500)

        t = struct.unpack("d", data[:8])[0]
        data = data[8:].decode()

        if (self.ECHO_DATA == data):
            print(f"{time.ctime(t)}: ECHO OK")
        else:
            print("ECHO FAIL")

        conn_sock.close()

def main():
    SimpleEchoClient()

if __name__ == "__main__":
    main()
```

<br/>

### Work1
* 파이썬 공식 매뉴얼을 통해 struct 모듈의 pack()와 unpack()에 대해 좀 더 학습하세요.
  * https://docs.python.org/ko/3/library/struct.html
* 네트워크는 바이트 단위로 데이터를 보내고 받습니다. 파이썬에서 네트워크로 데이터를 보내고 받으려면 꼭 pack(), unpack()이 필요합니다.

### Work2
* tcp_echo_server와 tcp_echo_client를 클래스 대신 함수 중심으로 변환해 보세요.
  * 속성을 전역 변수로 바뀝니다.
  * 메서드는 함수로 바뀌며 첫 번째 인자가 사라집니다.
  * __init__() 메서드는 전역 변수를 초기화하는 다른 함수로 바꿔야 합니다.

<br/><br/>

## UDP 소켓 
> 원래 TCP 프로토콜은 매우 복잡합니다. TCP에서 최소 기능만 남겨 둔 것이 UDP이므로 TCP 소켓보다 UDP 소켓이 좀 더 쉽습니다.

### udp_echo_server.py

```python
from socket import socket, AF_INET, SOCK_DGRAM

ADAPTER = "0.0.0.0"
ECHO_SERVER_PORT = 49002

def main():
    sock = socket(AF_INET, SOCK_DGRAM)
    sock.bind((ADAPTER, ECHO_SERVER_PORT))

    data, addr = sock.recvfrom(1500)
    sock.sendto(data, addr)
    
    print(f"{addr = }, data = {data.decode()}")

    sock.close()

if __name__ == "__main__":
    main()

```

### udp_echo_client.py

```python
from socket import socket, AF_INET, SOCK_DGRAM

ECHO_SERVER_IP = "127.0.0.1"
ECHO_SERVER_PORT = 49002

def main():
    sock = socket(AF_INET, SOCK_DGRAM)

    data = input("payload: ").encode()
    sock.sendto(data, (ECHO_SERVER_IP, ECHO_SERVER_PORT))
    recv_data = sock.recv(1500).decode()
    print(f"{recv_data = }")

    sock.close()

if __name__ == "__main__":
    main()

```

<br/>

> 범용 UDP 소켓 클래스 정의와 상속을 통해 재사용성을 높이는 방법에 대해 알아봅니다.

### simple_udp.py
```python
"""simple_udp.py"""
from threading import Thread
from socket import socket, AF_INET, SOCK_DGRAM

class SimpleUDP(Thread):
    def __init__(self, recv_adapter="0.0.0.0", port=0):
        super(SimpleUDP, self).__init__()
        self._stop = False

        self.sock = socket(AF_INET, SOCK_DGRAM)
        if port:
            self.sock.bind((recv_adapter, port))
            self.sock.setblocking(False)

        self.sendto = self.sock.sendto
        self.recvfrom = self.sock.recvfrom

    def terminate(self):
        self._stop = True
        self.sock.close()

    def callback(self, func, *args, **kwargs):
        self._func = func
        self._args = args
        self._kwargs = kwargs

        self.start()

    def run(self):
        while not self._stop:
            try:
                self._func(*self._args, **self._kwargs)
            except BlockingIOError:
                continue
            except OSError:
                break
```

### udp_echo_server2.py

```python
from simple_udp import SimpleUDP

class UDPEchoServer(SimpleUDP):
    def __init__(self):
        super(UDPEchoServer, self).__init__(port=49002)
        self.callback(self.echo, 1500)

    def echo(self, buf_size):
        data, addr = self.recvfrom(buf_size)
        self.sendto(data, addr)
        print(f"{addr = }, data = {data.decode()}")

def main():
    echo = UDPEchoServer()
    input("Press the Enter key to exit.\n")
    echo.terminate()

if __name__ == "__main__":
    main()

```

### udp_echo_client2.py

```python
from simple_udp import SimpleUDP

class UDPEchoClient(SimpleUDP):
    def __init__(self, server_ip="127.0.0.1", server_port=49002):
        super(UDPEchoClient, self).__init__()
        self.callback(self.echo, server_ip, server_port, 1500)

    def echo(self, server_ip, server_port, buf_size):
        data = input("data: ").encode()
        self.sendto(data, (server_ip, server_port))
        recv_data, addr = self.recvfrom(buf_size)
        print(f"recv data: {recv_data.decode()}")

        self.terminate()

def main():
    echo = UDPEchoClient()

if __name__ == "__main__":
    main()

```

<br/>

### Work1
* SimpleUDP의 상속에 대해 다음 질문에 답해 보세요.
  * 부모 메서드와 속성을 자식 쪽에서 호출할 수 있습니까?
  * 자식 쪽에 부모와 이름이 같은 메서드나 속성이 있다면 어떻게 됩니까?
  * SimpleUDP처럼 부모 클래스와 이를 상속한 자식 클래스의 장점은 무엇입니까?

### Work2
  * 클래스 속성과 클래스 메서드에 대해 조사해 보세요.
    * 인스턴스 속성과 클래스 속성의 차이점은 무엇입니까? 
    * 인스턴스 메서드와 클래스 메서드의 차이점을 무엇입니까?

### Work3
* 윈도와 WSL 리눅스에서 UDP 소켓 프로그램을 테스트해 보세요.
  * WSL 리눅스에서 서버를 실행한 후 윈도우에서 클라이언트를 실행합니다.
    * 클라이언트에서 사용하는 서버 IP는 WSL 리눅스 IP로 변경해야 합니다.
  * 역할을 바꿔서 실행해 보세요.

### Work4
* TCP와 UDP 소켓의 차이점에 대해 답해 보세요.
  * TCP 서버에서 accept의 역할은 무엇입니까?
  * TCP 클라이언트에서 connect의 역할은 무엇입니까?
  * send(), recv()와 sendto(), recvfrom()의 차이는 무엇입니까?

<br/><br/>

## UDP 소켓과 멀티캐스트 통신

> 멀티캐스트 통신은 UDP 소켓으로 구현하며, 멀티캐스트 그룹에 가입해야 합니다.

### multicast_receiver.py
```python
from socket import socket, inet_aton, AF_INET, SOCK_DGRAM, SOL_SOCKET, SO_REUSEADDR, INADDR_ANY, IPPROTO_IP, IP_ADD_MEMBERSHIP
import struct

MCAST_GROUP = '224.1.1.1'
SERVER_ADDR = ('', 49003)

def main():
    sock = socket(AF_INET, SOCK_DGRAM)

    sock.setsockopt(SOL_SOCKET, SO_REUSEADDR, 1)
    sock.bind(SERVER_ADDR)

    mreq = struct.pack("4sL", inet_aton(MCAST_GROUP), INADDR_ANY)
    sock.setsockopt(IPPROTO_IP, IP_ADD_MEMBERSHIP, mreq)

    while True:
        data, addr = sock.recvfrom(10240)
        print(f"{addr =}, {data = }")

        sock.sendto("ack".encode(), addr)
        
if __name__ == "__main__":
    main()
```

### multicast_sender.py
```python
from socket import socket, timeout, AF_INET, SOCK_DGRAM, IP_MULTICAST_TTL, IPPROTO_IP
import struct

MCAST_GROUP = ('224.1.1.1', 49003)

def main():
    sock = socket(AF_INET, SOCK_DGRAM)
    sock.settimeout(0.2)
    
    ttl = struct.pack('b', 2)
    sock.setsockopt(IPPROTO_IP, IP_MULTICAST_TTL, ttl)

    data = "echo data".encode()
    sock.sendto(data, MCAST_GROUP)

    while True:
        try:
            data, addr = sock.recvfrom(32)
        except timeout:
            break
        else:
            print(f"{addr =}, {data = }")
    
    sock.close()

if __name__ == "__main__":
    main()
```

<br/>

> 클래스 상속을 통해 좀 더 범용적이며, 확장성이 뛰어난 멀티캐스트 클래스를 정의합니다.

### simple_multicast.py

```python
from socket import socket, inet_aton, timeout
from socket import AF_INET, SOCK_DGRAM
from socket import SOL_SOCKET, SO_REUSEADDR, INADDR_ANY
from socket import IPPROTO_IP, IP_ADD_MEMBERSHIP, IP_MULTICAST_TTL
import struct

class SimpleMulticast:
    def __init__(self, mcast_group, timeout=0.2):
        self.sock = socket(AF_INET, SOCK_DGRAM)
        self.sock.settimeout(timeout)

        self._mcast_group = mcast_group

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.sock.close()

    def send(self, data, addr=()):
        self.sock.sendto(data, addr if addr else self._mcast_group)

    def recv(self, buf_size=1500):
        try:
            return self.sock.recvfrom(buf_size)
        except timeout:
            return (None, None)

class SimpleMulticastReceiver(SimpleMulticast):
    def __init__(self, mcast_group=('224.1.1.1', 49003), timeout=0.2):
        super(SimpleMulticastReceiver, self).__init__(mcast_group, timeout)

        self.sock.setsockopt(SOL_SOCKET, SO_REUSEADDR, 1)
        self.sock.bind(('', mcast_group[1]))
        mreq = struct.pack("4sL", inet_aton(mcast_group[0]), INADDR_ANY)
        self.sock.setsockopt(IPPROTO_IP, IP_ADD_MEMBERSHIP, mreq)

class SimpleMulticastSender(SimpleMulticast):
    def __init__(self, mcast_group=('224.1.1.1', 49003), timeout=0.2, ttl=2):
        super(SimpleMulticastSender, self).__init__(mcast_group, timeout)

        ttl = struct.pack('b', ttl)
        self.sock.setsockopt(IPPROTO_IP, IP_MULTICAST_TTL, ttl)
```

### multicast_echo_server.py

```python
from simple_multicast import SimpleMulticastReceiver

def main():
    with SimpleMulticastReceiver() as mrecv:
        while True:
            try:
                data, addr = mrecv.recv()
                if data:
                    print(f"{addr =}, {data = }")
                    mrecv.send("ack".encode(), addr)
            except KeyboardInterrupt:
                break

if __name__ == "__main__":
    main()
```

### multicast_echo_client.py

```python
"""ex03_08_2.py"""
from simple_multicast import SimpleMulticastSender

def main():   
    with SimpleMulticastSender() as msnd:
        msnd.send("echo data".encode())

        while True:
            try:
                data, addr = msnd.recv()
                if data:
                    print(f"{addr =}, {data = }")
            except KeyboardInterrupt:
                break
            
if __name__ == "__main__":
    main()
```
