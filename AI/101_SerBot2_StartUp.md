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

## 기본 제어
### PC에서 Serbot2에 원격 연결
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

### Serbot2 제어 API
**pop.driving**  
Class Driving : 구동 제어관련 클래스, 조향 및 이동관련 기능을 포함 
-	steering : 값을 -1 ~ 1 사이값으로 지정하면 로봇의 앞바퀴를 좌/우로 조향
-	throttle : 값을 0~99 사이값으로 지정하여 로봇의 속력을 제어
-	stop() : 로봇을 정지
-	forward(throttle=None) : 로봇을 전진, 
-	throttle : 로봇 속력을 제어, 입력이 없다면 throttle property를 활용 
-	backward(throttle=None) : 로봇을 후진
-	throttle : 로봇 속력을 제어, 입력이 없다면 throttle property를 활용 

**pop.Encoder**  
Class Encoder : 모터의 회전수를 확인
-	callback(func,repeat=1,param=None) : 콜백 등록, 수신되는 엔코더 데이터는 순서 대로 모터 동작 방향, 좌측 모터 엔코더 데이터, 우측 모터 엔코더 데이터 
-	func : 콜백 호출시 호출될 메소드 
-	repeat : 반복 주기 설정, repeat * 100ms
-	param : 콜백 메소드에 전달할 인자 
-	stop() : 콜백 중단 

**pop.Ultrasonic**  
Class Ultrasonic : 로봇에 장착된 초음파 센서 데이터 수신 
-	read() : 초음파 센서 데이터 수신, 순서대로 전방, 후방 
-	callback(func,repeat=1,param=None) : 콜백 등록 
-	func : 콜백 호출시 호출될 메소드 
-	repeat : 반복 주기 설정, repeat * 10ms
-	param : 콜백 메소드에 전달할 인자 
-	stop() : 콜백 중단 

**pop.Psd**  
Class Psd: 로봇에 장착된 Psd 센서 데이터 수신 
-	read() : Psd 센서 데이터 수신, 순서대로 전방, 후방 
-	callback(func,repeat=1,param=None) : 콜백 등록 
-	func : 콜백 호출시 호출될 메소드 
-	repeat : 반복 주기 설정, repeat * 10ms
-	param : 콜백 메소드에 전달할 인자 
-	stop() : 콜백 중단 

**pop.Battery**  
Class Battery : 로봇의 베터리 데이터 수신 
-	read() : 베터리 데이터 수신, 순서대로 전압, 온도 
-	callback(func,repeat=1,param=None) : 콜백 등록 
-	func : 콜백 호출시 호출될 메소드 
-	repeat : 반복 주기 설정, repeat * 1s
-	param : 콜백 메소드에 전달할 인자 
-	stop() : 콜백 중단 

**pop.Light**  
Class Light : 로봇에 장착된 Light 센서 데이터 수신 
-	read() : Light 센서 데이터 수신 
-	callback(func,repeat=1,param=None) : 콜백 등록 
-	func : 콜백 호출시 호출될 메소드 
-	repeat : 반복 주기 설정, repeat * 100ms
-	param : 콜백 메소드에 전달할 인자 
-	stop() : 콜백 중단

**pop.Imu**  
Class Imu : 로봇에 장착된 Imu 센서 데이터 수신 
-	accel() : 가속도 센서값 반환, (x,y,z) 형태로 반환
-	magnetic() : 지자기 센서값 반환, (x,y,z) 형태로 반환 
-	gyro() : 자이로 센서값 반환, (x,y,z) 형태로 반환 
-	euler() : 오일러 센서값 반환, (yaw,roll,pitch) 형태로 반환
-	quat() : 쿼터니언 센서값 반환, (w,x,y,z) 형태로 반환  
-	callback(func,repeat=1,param=None) : 콜백 등록 
-	func : 콜백 호출시 호출될 메소드 
-	repeat : 반복 주기 설정, repeat * 10ms
-	param : 콜백 메소드에 전달할 인자 
-	stop() : 콜백 중단
