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
- 인터넷 통신을 위한 운영체제에서 지원하는 표준 API
- IP 주소와 포트 번호를 이용해 장치 및 응용 구분

## UDP 소켓 
- 클라이언트-서버 구조보다는 Peer-to-Peer 구조에 가까움.
- 데이터그림 소켓으로 불리며, 연결없이 데이터 송수신
- 전송한 데이터는 수신을 보장하지 않음
  
### 1st
**udp_server.py**
- socket 클래스에 AF_INET과 SOCK_DGRAM 인자를 전달해 UDP 소켓 객체 생성
- bind를 통해 운영체제에 데이터를 수신할 소켓 주소쌍 등록
  - IP 주소가 '0.0.0.0'이면 모든 네트워크 어댑터로 수신되는 연결 요청 허용
  - 포트 번호는 인터넷 할당 번호 관리기관(IANA)에서 관리
    - 0번 ~ 1023번: 잘 알려진 포트 (well-known port). 인터넷 공식 서버에서 사용하며, 관리자 권한 필요
    - 1024번 ~ 49151번: 등록된 포트 (registered port). 일반 서버에서 사용
    - 49152번 ~ 65535번: 동적 포트 (dynamic port). 클라이언트에서 사용
- sendto와 recvfrom으로 데이터 송수신
- 수신한 데이터보다 더 작게 읽으면 나머지 데이터는 버려짐
  
```python
from socket import socket
from socket import AF_INET, SOCK_DGRAM

IP = "0.0.0.0"
PORT = 5001

def main():
    sock = socket(AF_INET, SOCK_DGRAM)
    sock.bind((IP, PORT))

    while True:
        data, addr_pair = sock.recvfrom(1500)
        sock.sendto(data, addr_pair)    
        print(f"{addr_pair}: {data.decode()}")

if __name__ == "__main__":
    main()
```

**udp_client.py**
- socket 클래스에 AF_INET과 SOCK_DGRAM 인자를 전달해 UDP 소켓 객체 생성
- sendto와 recvfrom으로 데이터 송수신

```python
from socket import socket
from socket import AF_INET, SOCK_DGRAM

IP = '192.168.1.0' #서버 IP로 수정
PORT = 5001

def main():
    sock = socket(AF_INET, SOCK_DGRAM)

    data = input("data: ").encode()
    sock.sendto(data, (IP, PORT))
    recv_data = sock.recv(1500).decode()
    print(f"{recv_data}")

    sock.close()

if __name__ == "__main__":
    main()
```
### 2nd
**udp_server.py**
- 클라이언트가 전달한 명령을 popen()으로 실행

```python
from socket import socket 
from socket import AF_INET, SOCK_DGRAM 
from os import popen 

IP = "0.0.0.0"
PORT = 5001 

def main():
    sock = socket(AF_INET, SOCK_DGRAM)
    sock.bind((IP, PORT))
    
    while True:
        data, addr_pair = sock.recvfrom(1500)
        data = data.decode()
        print(addr_pair, data)
        popen(data)
        
if __name__ == "__main__":
    main()
```

**udp_client.py**
- 서버 주소와 함께 실행할 명령을 입력하면 이를 해당 서버에 전달
- 예
  - notepad: 메노장 실행
  - explorer: 탐색기 실행
  - ncpa.cpl: 제어판의 네트워크 설정 실행
  - start chrome https://naver.com: 네이버 실행
    
```python
from socket import socket 
from socket import AF_INET, SOCK_DGRAM 

PORT = 5001 

def main():
    sock = socket(AF_INET, SOCK_DGRAM)
    
    while True:
        IP = input("IP: ")
        cmd = input("CMD: ")
        sock.sendto(cmd.encode(), (IP, PORT))

if __name__ == "__main__":
    main()
```

## TCP 소켓
- 클라이언트-서버 구조로 가장 보편적인 인터넷 통신
- 스트림 소켓으로 불리며, 연결된 상태에서 데이터 송수신
- 전송한 데이터는 수신을 보장함

### 1st 
**tcp_server.py**
- socket 클래스에 AF_INET과 SOCK_STREAM 인자를 전달해 TCP 소켓 객체 생성
- setsockopt로 소켓 주소쌍(IP 주소와 TCP 포트 번호)을 재사용하도록 설정
- bind를 통해 운영체제에 연결 요청을 수락할 소켓 주소쌍 등록
- 클라이언트로부터 연결 요청이 수신되면 accept로 연결 허용
  - 클라이언트 연결 소켓과 주소쌍이 반환됨
  - 클라이언트 연결 소켓은 해당 클라이언트와 데이터를 주소 받을 때 사용

```python
from socket import socket
from socket import AF_INET, SOCK_STREAM
from socket import SOL_SOCKET, SO_REUSEADDR

IP = "0.0.0.0"
PORT = 5001

def main():
    sock = socket(AF_INET, SOCK_STREAM)
    sock.setsockopt(SOL_SOCKET, SO_REUSEADDR, 1)
    sock.bind((IP, PORT))
    sock.listen(5)

    conn_sock, addr_pair = sock.accept()
    print(addr_pair)

if __name__ == '__main__':
    main()
```

**tcp_client.py**
- socket 클래스에 AF_INET과 SOCK_STREAM 인자를 전달해 TCP 소켓 객체 생성
- 서버 소켓 주소쌍을 이용해 connect로 서버에 연결 요청
  - 서버 IP 주소는 서버 프로그램이 실행 중인 컴퓨터 IP
- 연결이 성공하면 데이터를 주소 받을 수 있음
  - 네트워크 장애, 서버 프로그램이 실행 중이 아님, 서버 주소 또는 포트 번호가 틀림 등으로 연결이 실패하면 예외 발생

```python
from socket import socket
from socket import AF_INET, SOCK_STREAM

IP = '192.168.1.0' #서버 IP로 수정
PORT = 5001

def main():
    sock = socket(AF_INET, SOCK_STREAM)

    try:
        sock.connect((IP, PORT))
    except:
        print("Fail connection")
        return

    print("Ok connection")
    sock.close()
    
if __name__ == '__main__':
    main()
```

### 2nd
**tcp_server.py**
- 클라이언트 연결 소켓을 이용해 데이터 송수신(send/recv)

```python
from socket import socket
from socket import AF_INET, SOCK_STREAM
from socket import SOL_SOCKET, SO_REUSEADDR

IP = "0.0.0.0"
PORT = 5001

def main():
    sock = socket(AF_INET, SOCK_STREAM)
    sock.setsockopt(SOL_SOCKET, SO_REUSEADDR, 1)
    sock.bind((IP, PORT))
    sock.listen(5)

    conn_sock, addr_pair = sock.accept()
    print(addr_pair)

    data = conn_sock.recv(1024)
    conn_sock.send(data)
    print(data.decode())
    conn_sock.close()

if __name__ == '__main__':
    main()
```

**tcp_client.py**
- 연결이 성공하면 소켓을 이용해 데이터 송수신(send/recv)

```python
from socket import socket
from socket import AF_INET, SOCK_STREAM

IP = '192.168.1.0' #서버 IP로 수정
PORT = 5001

def main():
    sock = socket(AF_INET, SOCK_STREAM)

    try:
        sock.connect((IP, PORT))
    except:
        print("Fail connection")
        return

    print("Ok connection")

    send_data = input("data: ")
    sock.send(send_data.encode())
    recv_data = sock.recv(1024).decode()
    if send_data == recv_data:
        print("Ok ECHO")
    else:
        print("Fail ECHO")

    sock.close()
    
if __name__ == '__main__':
    main()
```

### 3th
**tcp_server.py**
- 새로운 클라이언트가 연결될 때마다 해당 클라이언트 연결 소켓이 반환되므로 리스트나 딕셔너리로 이를 관리해야 함.

```python
from socket import socket
from socket import AF_INET, SOCK_STREAM
from socket import SOL_SOCKET, SO_REUSEADDR

IP = "0.0.0.0"
PORT = 5001

def main():
    sock = socket(AF_INET, SOCK_STREAM)
    sock.setsockopt(SOL_SOCKET, SO_REUSEADDR, 1)
    sock.bind((IP, PORT))
    sock.listen(5)

    conn_sock_mng = {}
    while True:    
        conn_sock_t, addr_pair = sock.accept()
        conn_sock_mng[addr_info] = conn_sock_t        
        print(f"Total connection: {len(conn_sock_mng)}, New connection: {addr_pair}")

if __name__ == '__main__':
    main()
```

### 4th
**tcp_server.py**
- 모든 클라이언트 연결 소켓에 대한 데이터 송수신 처리를 위해 스레드 사용

```python
from socket import socket
from socket import AF_INET, SOCK_STREAM
from socket import SOL_SOCKET, SO_REUSEADDR
from threading import Thread

IP = "0.0.0.0"
PORT = 5001

conn_sock_mng = {}

def do_communication(conn_sock, addr_pair):
    print("do_communication")
    while True:
        try:
            data = conn_sock.recv(1024)
            print(f"{addr_pair}: {data.decode()}")
            for a, s in conn_sock_mng.items():
                if s != conn_sock:
                    s.send(f"{a}: {data.decode()}".encode())
        except:
            del conn_sock_mng[addr_pair]
            break
        
def main():
    sock = socket(AF_INET, SOCK_STREAM)
    sock.setsockopt(SOL_SOCKET, SO_REUSEADDR, 1)
    sock.bind((IP, PORT))
    sock.listen(5)
    
    while True:
        try:
            conn_sock_t, addr_pair = sock.accept()
        except KeyboardInterrupt:
            break
        conn_sock_mng[addr_pair] = conn_sock_t
        print(f"Total connection: {len(conn_sock_mng)}, New connection: {addr_pair}")
        th = Thread(target=do_communication, args=(conn_sock_t,addr_pair))
        th.daemon = True
        th.start()
        
if __name__ == "__main__":
    main()
```

**tcp_client.py**
- 송신과 수신을 동시에 처리하기 위해 스레드 사용
```python
from socket import socket
from socket import AF_INET, SOCK_STREAM
from threading import Thread

IP = '192.168.1.0' #서버 IP로 수정
PORT = 5001

def do_recv(sock):
    while True:
        data = sock.recv(1024).decode()
        print(data)

def main():
    sock = socket(AF_INET, SOCK_STREAM)

    try:
        sock.connect((IP, PORT))
    except:
        print("Fail connection")
        return

    print("Ok connection")
    th = Thread(target=do_recv, args=(sock,))
    th.daemon = True
    th.start()
    
    while True:
        data = input()
        sock.send(data.encode())
    
if __name__ == '__main__':
    main()
```
