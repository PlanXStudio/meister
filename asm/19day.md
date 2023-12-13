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

## TCP 소켓
- 클라이언트-서버 구조로 가장 보편적인 인터넷 통신
- IP 주소와 포트 번호를 이용해 장치 및 응용 구분

### tcp_server.py
- bind를 통해 운영체제에 연결 요청을 수락할 IP 주소와 포트 번호 등록
- 클라이언트로부터 연결 요청이 수신되면 accept로 허용 후 데이터 교환을 위한 새로운 소켓 생성
- 새로운 소켓으로 클라이언트와 데이터 교환(send/recv)  

```python
from socket import socket, AF_INET, SOCK_STREAM, SOL_SOCKET, SO_REUSEADDR

def main():
    sock = socket(AF_INET, SOCK_STREAM)
    sock.setsockopt(SOL_SOCKET, SO_REUSEADDR, 1)
    sock.bind(('0.0.0.0', 49001))
    sock.listen(5)
    
    client_sock, addr_info = sock.accept()
    
    while True:
        data = client_sock.recv(1024).decode()
        print(data)
        if data == '종료':
            break
    
    client_sock.close()
    sock.close()

if __name__ == '__main__':
    main()
```

### tcp_client.py
- 서버 IP 주소와 포트 번호를 이용해 connect로 서버에 연결
- 연결이 성공하면 소켓으로 서버와 통신(send/recv)

```python
from socket import socket, AF_INET, SOCK_STREAM, SOL_SOCKET, SO_REUSEADDR
import struct

def main():
    sock = socket(AF_INET, SOCK_STREAM)
    sock.connect(('192.168.1.5', 49001))
        
    while True:
        data = input()
        sock.send(data.encode())
        if data == '종료':
            break
    
    sock.close()
    
if __name__ == '__main__':
    main()
```

### 클래스 캡슐화
**tcp_server2.py**
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

**tcp_client.py**
  
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
- 여러 클라이언트와 동시에 데이터를 교환하려면 쓰레드 필요

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
- TCP 소켓에 빌해 간결함
- 클라이언트-서버 구조보다는 Peer-to-Peer 구조에 가까움.
  
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

## 범용 UDP 소켓 클래스 정의와 상속을 통해 재사용성 향상

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
```
