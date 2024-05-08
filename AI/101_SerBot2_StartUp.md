# SerBot2
NVIDIA Orin NX 16G와 STM43F4로 운영되는 옴니휠 메커니즘 기반 서비스 로봇 개발장비  
> 가장 아래부터 옴니휠 메커니즘(3WD Block), 드라이빙 컨트롤러(Hidden), 터치 스크린 + 적재함, AI 엣지 컴퓨팅 모듈(Main Processor) + 센서 컨트롤러
  
![serbot2](https://github.com/PlanXStudio/meister/assets/8893544/56dc6169-b0bc-4297-a38c-de6e58c9203f)

## 기본 구조
![serbot2_block](https://github.com/PlanXStudio/meister/assets/8893544/18896b8e-4cf9-40f3-a8d4-a79c2fa36b3c)

**AI 엣지 컴퓨팅 모듈 (AP)**  
- NVIDIA Orin NX 16G, 100TOPS
- Ubuntu Linux 22.04
- Camera, Tourch Screen, Audio(Array-Mic, Speaker), Lidar 제어
- CAN 프로토콜로 드라이빙 및 센서 컨트롤러 제어

**드라이빙 컨트롤러 (MCU0)**  
- STM32F4
- FreeRTOS
- 전원 관리 및 옴니휠 메커니즘 제어
- CAN 프로토콜 제공

**센서 컨트롤러 (MCU1)**  
- STM32F4
- FreeRTOS
- 9-axis IMU, Light Sensor, IoT 응용 모듈 제어
- CAN 프로토콜 제공

**옴니휠 메커니즘**  
- 인코더가 내장된 3개의 12V-DC Motor를 120도 간격으로 배치한 후 옴니휠 장착
- 6면에 6개의 Ultra-sonic와 3개의 PSD 센서 배치
- 14.8V/7000mA 배터리와 배터리 온도 센서 포함

**CAN FD**
- AP와 MCU 사이 통신 버스
- AP <---> CAN FD <---> MCU

### 파워 블록
![power](https://github.com/PlanXStudio/meister/assets/8893544/f31a6e5a-adf0-4bff-a086-ea1b7e8b3a5e)  

- 파워 매니저에 의해 DC JACK 전원 또는 배터리 전원을 시스템에 메인 전원으로 공급
  - 시스템 파트 별로 메인 전원을 12V, 5V, 3.3V로 변환해 사용
  - Voltage Meter에서 현재 전압 표시
- DC JACK 전원
  - 19V DC Adapter를 통해 배터리 충전 및 시스템에 메인 전원 공급
- 배터리 전원
  - DC JACK 전원이 연결되지 않으면 시스템에 메인 전원 공급
  - 공칭 전압: +14.8V
  - 최대 전압 +16.8V
  - 배터리 상태 체크 LED: Normal, Low
    - Low ON: 충전이 필요한 상태로 반드시 DC JACK에 19V DC Adapter 연결

### 시스템 부팅
1. 옴니휠과 적재함 사이 파워 스위치 ON
2. 시스템 상단의 Voltage Meter에는 현재 공급되는 메인 전원 전압이 표시됨
3. 약 5초 후 드라이빙 및 센서 컨트롤러가 초기화됨
5. 약 30초 후 AI 엣지 컴퓨팅 모듈이 초기화됨
6. 약 50초 후 터치 스크린에 부팅 화면이 표시됨

---

## PC에서 Serbot2에 원격 접속
- PC와 Serbot2(엣지 컴퓨팅 모듈) 사이 Wi-Fi 또는 Ethernet 연결
  - Ethernet
    - Serbot2에는 IP 주소 192.168.101.101가 할당되어 있음
    - PC에서 ncpa.cpl 명령으로 네트워크 설정을 실행한 후 해당 이더넷 어댑터의 IP 주소를 192.168.101.120로 설정
  - Wi-Fi
    - PC와 Serbot2를 같은 공유기(AP)에 연결해야 함
    - Serbot 화면의 작업 표시줄 오른쪽 끝에 있는 Wi-Fi 설정 애플릿을 통해 해당 AP에 연결
  - Serbot2의 화면 오른쪽 하단에 어댑터 별 현재 IP 주소가 표시됨
    - eth0: Ethernet 어댑터에 할당된 개발용 IP (192.168.101.101)
    - eth1: Ethernet 어댑터에 할당된 IP (예: a.b.c.d)
    - wlan0: Wi-Fi 어댑터에 할당된 IP (예: 192.168.x.y)     
- 명령 프롬프트를 실행한 후 serbot2 IP 주소가 유효한지 확인
  ```sh
  ping 192.168.x.y
  ```
- ssh 명령으로 serbot2 IP 주소에 접속 (id: soda, pw: soda)
  ```sh
  ssh soda@192.168.x.y
  ```
  
### 사용자 계정 생성 (최초 1회)
> XField를 구축된 환경에서 Serbot2가 XField-Network에 연결되어 있음
>> PC를 XField_network에 연결한 후 진행 (비밀번호는 xfield123!)

기본 제공하는 soda 대신 별도 사용자 계정 생성 및 사용

- soda 계정으로 원격 접속
  ```sh 
  ssh soda@<serbot2_ip>
  ```

- 새 계정 생성 (예: mini)
  ```sh
  sudo adduser mini
    passwd: <mini_pw>
    이하 <Enter>
  ```
- sudo 그룹에 추가
  ```sh
  sudo gpasswd -a mini sudo
  ```
- soda의 설정 폴더 및 파일을 새 계정에 복사 및 소유권 변경
  ```sh
  sudo cp -R .* /home/mini
  sudo cp -R * /home/mini
  ```
- 새 계정에 복사 파일 및 폴더 소유권 변경
  ```sh
  sudo chown -R mini.mini /home/mini
  ```
- 원격 연결 종료
  ```sh
  exit
  ```
- 새 계정으로 원격 접속
  ```sh 
  ssh mini@<serbot2_ip>
  ```
- 새 계정의 쉘을 bash에서 zsh로 변경
  ```sh
  chsh -s /bin/zsh
  ```

### SSH 키
> 비밀번호 없이 원격 접속

- 명령 프롬프트를 실행한 후 SSH 키 생성 
  ```sh
  ssh-keygen -t rsa -b 4096
  이하 <ENTER> 
  ```
  
- 홈 폴더 아래 .ssh 폴더에 생성된 공개키를 Serbot2에 복사
  ```sh 
  scp ~\.ssh\id_rsa.pub <your_id>@<serbot2_ip>:~/.ssh/authorized_keys
  ```

### VSCode에서 원격 접속
- SSH Remote 확장 설치
- Remote Explorer > SSH > open ssh config file 선택
- ~/.ssh/config 생성
  ```sh
  Host serbot2_<serbot2_ip>
      HostName <serbot2_ip>
      User <your_id>
      IdentityFile ~/.ssh/id_rsa
  ```
- REMOTES(TUNNELS/SSH) > Reflash
- 목록의 serbot2_<serbot2_ip>에서 Connect in current window... 선택  
- Platform select 목록이 표시되면 Linux 선택 
- 최초 접속 시 VSCode Server를 인터넷에서 다운받아 Serbot2에 설치 함

**VSCode에서 원격 접속 문제 해결**
- 명령 프롬프트를 통해 Serbot2에 원격 접속
- Serbot2에서 SSH 키 재 생성 
  ```sh
  sudo ssh-keygen -A
  ```

## 기본 제어
```python
import sys
import time
import signal

def setup():
  pass

def loop():
  pass

def cleanup(*args):
  sys.exit(0)

if __name__ == "__main__":
  signal.signal(signal.SIGINT, cleanup)
  setup()
  while True:
    loop()
```

### Serbot2 제어 API
**pop.driving**  
Class Driving : 옴니휠 메커니즘 제어관련 클래스, 조향 및 이동 기능을 포함 
-	steering : -1 ~ 1 사이값으로 좌/우로 조향
-	throttle : 0 ~ 99 사이값으로 속력 제어
-	stop() : 정지
-	forward(throttle=None) : 전진 
  -	throttle : 속력 
-	backward(throttle=None) : 후진
  -	throttle : 속력 

```python
from pop.driving import Driving

drv = None

def basic_driving():
  drv.forward(20)
  time.sleep(3)

  drv.backward(20)
  time.sleep(3)

  drv.stop()

def steering_driving():
  throttle = 30
  steering = -0.3

  drv.forward()
  time.sleep(3)

  drv.backward()
  time.sleep(3)

  steering = 0.3

  drv.forward()
  time.sleep(3)

  drv.backward()
  time.sleep(3)

  drv.stop()  

def setup():
  global drv

  drv = Driving()

  basic_driving()
  steering_driving
```

**pop.Encoder**  
Class Encoder : 모터 회전수
-	callback(func,repeat=1,param=None) : 콜백 등록
  -	func : 콜백 호출시 호출될 메소드 
    - 매개변수는 모터 동작 방향, 좌측 모터 엔코더 데이터, 우측 모터 엔코더 데이터 
  -	repeat : 반복 주기 설정, repeat * 100ms
  -	param : 콜백 메소드에 전달할 인자 
-	stop() : 콜백 중단 

**pop.Ultrasonic**  
Class Ultrasonic : 초음파 센서 
-	read() : 센서값 읽기 
-	callback(func,repeat=1,param=None) : 콜백 등록 
  -	func : 콜백 호출시 호출될 메소드 
  -	repeat : 반복 주기 설정, repeat * 10ms
  -	param : 콜백 메소드에 전달할 인자 
-	stop() : 콜백 중단 

**pop.Psd**  
Class Psd: Psd 센서 
-	read() : 센서값 읽기 
-	callback(func,repeat=1,param=None) : 콜백 등록 
  -	func : 콜백 호출시 호출될 메소드 
  -	repeat : 반복 주기 설정, repeat * 10ms
  -	param : 콜백 메소드에 전달할 인자 
-	stop() : 콜백 중단 

**pop.Battery**  
Class Battery : 베터리 상태 
-	read() : 상태값 읽기, 순서대로 전압, 온도 
-	callback(func,repeat=1,param=None) : 콜백 등록 
  -	func : 콜백 호출시 호출될 메소드 
  -	repeat : 반복 주기 설정, repeat * 1s
  -	param : 콜백 메소드에 전달할 인자 
-	stop() : 콜백 중단 

**pop.Light**  
Class Light : 빛 센서 
-	read() : 센서값 읽기 
-	callback(func,repeat=1,param=None) : 콜백 등록 
  -	func : 콜백 호출시 호출될 메소드 
  -	repeat : 반복 주기 설정, repeat * 100ms
  -	param : 콜백 메소드에 전달할 인자 
-	stop() : 콜백 중단

**pop.Imu**  
Class Imu : Imu 센서 
-	accel() : 가속도 센서값 읽기. (x,y,z) 형태로 반환
-	magnetic() : 지자기 센서값 읽기, (x,y,z) 형태로 반환 
-	gyro() : 자이로 센서값 읽기, (x,y,z) 형태로 반환 
-	euler() : 오일러 센서값 읽기, (yaw,roll,pitch) 형태로 반환
-	quat() : 쿼터니언 센서값 읽기, (w,x,y,z) 형태로 반환  
-	callback(func,repeat=1,param=None) : 콜백 등록 
  -	func : 콜백 호출시 호출될 메소드 
  -	repeat : 반복 주기 설정, repeat * 10ms
  -	param : 콜백 메소드에 전달할 인자 
-	stop() : 콜백 중단
