# 스마트홈 주변장치 제어

## XNode 제어기
- XNode 모듈 내장
- Auto
  - PWM 컨트롤러 및 릴레이 내장
  - XNode의 하드웨어 인터페이스에 연결된 포트 제공
  - 다양한 전원 (3V3, 5V, 12V, GND) 포트 제공
- Power
  - 12V DC 전원 입력을 최대 3개의 12V DC 전원 출력으로 공급
  - 2x16 텍스트LED 내장
  - XNode의 하드웨어 인터페이스에 연결된 포트 제공
  - 다양한 전원 (3V3, 5V, 12V, GND) 포트 제공

## 스마트홈 주변장치
- Auto 제어기에 연결
- 팬(FAN)
- 조명(Light) 
- 가스 잠금 장치(Gas Circuit Breaker)
- 가스 감지기(Gas Detector)
- 도어락(DoorLock)

## 시스템 구성(케이블링)
- 5V 어댑터는 USB 허브, 12V 어댑터는 Power 제어기에 전원 공급
  - Power 제어기는 Auto 제어기와 엣지 서버에 12V 전원 공급
- USB 허브의 메인 USB는 PC에 연결
  - Zigbee 모듈 및 제어기의 USB를 USB 허브의 확장 USB 포트에 연결
    - 각 장치의 COM 포트 확인

##  소프트웨어 개발환경 구성
- VSCode의 압축 파일을 C:/에 압축해제 후 그 아래 data 및 ext 폴더 생성
  - https://www.python.org/downloads/windows/   Windows embeddable package (64-bit)
- Python SDK의 압축 파일을 C:/VSCode/ext에 압축해제
  - Windows embeddable package (64-bit)
  - 메모장으로 C:/VSCode/ext/python/python<버전>._pth 파일을 열고 확장 라이브러리 경로 추가
    - Lib/site-packages
- Pip 설치 파일을 C:/VSCode/ext/python 경로에 저장
  - https://bootstrap.pypa.io/get-pip.py
  - 명령 프롬프트에서 저장 경로로 이동한 후 파이썬 인터프리터로 설치 파일 실행
    - cd c:/VSCode/ext/python
    - python get-pip.py
- 계정 환경 변수 Path에 python 및 pip 경로 추가 (목록 가장 위에 배치)
  - C:/VSCode/ext/python 및 C:/VSCode/ext/python/Scripts
- 새 명령 프롬프트에서 xnode 라이브러리 설치
  - pip install xnode

## 작업공간
- 홈 폴더(C:/Users/<계정>)에 iot 폴더 생성
  - 하위 폴더에 pc 및 xnode 폴더 생성
- Pop 라이브러리를 작업공간으로 복사
  - 제공된 USB의 Library 폴더를 작업공간 아래 xnode 폴더으로 복사
    - CORE/lib/pop.py: Zigbee 모듈 제어
      - 확장 모듈(EXT) 및 제어기(HOME)에서 공통으로 사용
    - EXT/lib/EXT_<확장모듈>.py: Zigbee 모듈용 확장 모듈 제어
      - EXT_Basic.py, EXT_GPS.py, EXT_IMU.py, EXT_IRThermo.py, EXT_PIR.py
    - HOME/HOME_<주변장치>.py: Auto 제어기에 연결된 주변장치 제어
      - HOME_Actuator.py, HOME_Door.py, HOME_Kitchen.py

## xnode 툴로 XNode 파일 시스템 관리 및 스크립트 실행
- VSCode 터미널에서 실행
  - xnode scan: XNode 포트 확인
  - xnode -p<포트> ls <경로>
    - /flash: 마이크로파이썬 응용 루트 폴더. 이곳에 영구 실행 스크립트(main.py) 설치
    - /flash/lib: 응용 스크립트용 라이브러리 위치
  - xnode -p<포트> put <설치 파일 또는 폴더>
    - 라이브리 설치는 lib 폴더에 설치할 라이브러리 파일을 넣은 후 xnode –p<포트> put lib
    - My.py를 영구 실행 스크립트로 설치할 때는 xnode -p<포트> put my.app main.py
  - xnode -p<포트> run <스크립트>
    - 스크립트에 기술된 명령을 한 줄씩 XNode로 전송하면서 실행
    - XNode의 실행 결과를 기다리지 않으려면 xnode –p<포트> run –n <스크립트>
    - 스크립트 실행 과정에서 PC의 키 입력을 XNode에 전달하려면 xnode –p<포트> run –i <스크립트>

## Auto 제어
- Library/CORE/lib와 Library/HOME/lib 폴더에 저장된 Pop 라이브러리를 XNode로 복사
- 현재 위치가 작업공간(C:/Users/<계정>/iot) 일 때, 아래와 같이 설치
  ```sh
  cd ./xnode/Library/CORE
  xnode -p<포트> put lib
  cd ../
  cd ./HOME
  xnode -p<포트> put lib
  cd ../../
  ```

### 릴레이
- 입력(Pole) 하나, 출력 하나인 SPST(Single Pole Single Throw) 타입
- C(공용), O(A접점)로 구성된 3개 채널 포트 제공
  - 입력은 내부 전원(5V, 12V) 또는 외부 라인 중 선택
  - 출력은 A 접점

### FAN
- FAN은 12V DC 모터 내장
- 검정선은 GND, 빨강선은 릴레이 채널2 또는 3의 O 포트에 연결
  - 입력은 내부 전원 12V 선택(기본값)
  - XNode의 D6(CH2) 또는 D5(CH3) 포트로 릴레이 ON/OFF
  - FAN 객체(기본값은 채널3)의 on(), off() 메소드로 제어
    ```python
    fan = FAN() #기본값은 채널3(D5)
    fan.on()
    fan.off()
    ```

### 조명
- 조명은 12V LED 등
- 검정선은 GND, 빨강선은 릴레이 채널2 또는 3의 O 포트에 연결
  - 입력은 내부 전원 12V 선택(기본값)
  - XNode의 D6(CH2) 또는 D5(CH3) 포트로 릴레이 ON/OFF
  - Light 객체의 on(), off() 메소드로 제어
  ```python
  light = Light() #기본값은 채널2 (D6)
  light.on()
  light.off()
  ```

### 도어락
- 도어락은 자체 전원으로 동작하며, 내부에서는 이벤트 버튼으로 열고 닫음
- 이벤트 선 중 하나는 릴레이 채널1의 C 나머지 하나는 O 포트에 연결
  - 입력은 외부 전원 선택(기본값)
  - XNode D0 포트로 채널 ON/OFF
  - DoorLock 객체의 work() 메소드로 제어
  ```python
  dl = DoorLock() #기본값은 채널1(D0)
  dl.work()
  ```

### PWM 컨트롤러
- ON, OFF 또는 PWM 값으로 LED의 밝기나 모터의 회전 방향 및 속도 제어
- Auto 제어기에 I2C 타입의 12비트 PWM 컨트롤러 내장
- 모터 제어를 위해 A(CH0), /A(CH1)와 B(CH2), /B(CH3)로 구성된 포트 제공
  - 입력은 내부 전원 5V, 12V 중 선택 (기본값은 12V)
  - 출력은 PWM 듀티비 0%(OFF) ~ 100%(ON)

### 가스 잠금 장치 제어
- 가스 잠금장치는 모터 드라이버로 제어
- 검정선은 PWM 컨트롤러의 B, 빨강선은 /B 포트에 연결
  - PWM 컨트롤러의 채널3, 채널2의 배타적인 ON(100%), OFF(0%) 신호로 열고 닫기
  - GasBreaker 객체의 open(), close() 메소드로 제어
  ```python
  gb = GasBreaker()
  gb.open() #시계방향  
  #현재 동작 완료는 약 6초
  gb.close() #반시계방향
  ```

### 디지털 입출력
- 디지털 입출력 장치 연결을 위해 범용 입출력(GPIO) 포트 제공
- 4개 디지털 입출력 포트 제공 (P8, P17, P18, P23)
  - XNode의 GPIO 포트에 연결되며, 운영 전압은 3V3 ~ 5V
  - 다양한 전원 포트 제공 (3V3, 5V, 12V, G(GND))

### 가스 감지기 제어
- 가스 감지기는 단순한 디지털 입력
- 검정선은 GND, 빨강선은 12V, 흰선(입력 신호)은 P18 포트에 연결
  - 가스가 감지되면 경보가 울리며 흰선(P18)이 높은 상태(HIGH)가 됨
  - GasDetect 객체의 read() 메소드로 상태 읽기
  ```python
  gd = GasDetect()
  ret = gd.read() #ret가 1이면 가수 누출, 0이면 정상
  ```
