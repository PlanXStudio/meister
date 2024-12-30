# XNode Home
IoT 센서가 부착된 장비는 온도, 습도, 압력, 진동 등 다양한 데이터를 실시간으로 수집하여 전송하며, 이렇게 수집된 데이터를 분석함으로써 생산 공정의 효율성을 극대화하고 불량률을 감소시키며 생산량을 최적화할 수 있습니다. 또한, IoT 데이터 기반의 공정 자동화를 통해 특정 조건 충족 시 기계의 자동 작동 또는 정지 설정이 가능해져 인적 오류를 줄이고 생산 속도를 향상시킬 수 있습니다. 뿐만 아니라 장비 상태를 실시간으로 모니터링하여 고장을 사전에 예측하고 예방함으로써 장비 수명 연장 및 갑작스러운 고장으로 인한 생산 차질을 최소화할 수 있습니다.

산업별 IoT 기술 적용 사례는 다음과 같습니다.

- 제조업: 스마트 팩토리 구축을 통해 생산 공정의 효율성을 극대화하고, 불량률을 최소화하며, 생산성 향상
- 에너지 산업: 스마트 그리드를 구축하여 에너지 효율을 높이고, 전력 공급의 안정성 향상 
- 물류 산업: 물류 추적 및 관리를 자동화하여 물류 효율성을 높이고, 배송 시간 단축
- 농업: 스마트 팜을 구축하여 작물의 생육 환경을 최적화하고, 생산량 증대

XNode Home은 빌딩, 공장 자동화에 필요한 IoT 기술을 학습하기 위해 IoT 센서, 액추에이터, 통신 기술을 결합했습니다
XNode 모트 및 XNode 모듈이 내장된 Auto 제어기와 전공 공급기 및 주변장치로 구성됨

##  구성
### XNode 모트
- 대표적인 저전력 IoT 통신 기술인 Zigbee 칩이 내장된 Coretex-M 계열 MCU와 배터리, 기본 센서, 확장 포트로 구성
- 개발환경은 파이썬의 하위 집합인 마이크로파이썬 사용 

### Auto 제어기
- 배터리가 제거된 XNode 모듈 내장
  - 전원 스위치 조작 불필요. 리셋 버튼만 사용  
- PWM 컨트롤러 및 릴레이 내장
- 릴레이 및 전원이 포함된 터미널 IO 포트 제공
  - 주변장치의 신호선 또는 전원선을 '_'자 소형 드라이버로 개방해 결선
  - 다양한 전원 (3V3, 5V, 12V, GND) 포트 제공
    - **전원선은 잘못 연결하면 장비 파손 위험**이 있으므로 주의할 것!  

### 전원 공급기
- 12V DC 전원 입력을 최대 3개의 12V DC 전원 출력으로 공급
- 2x16 텍스트LED 내장
- 부가 기능으로 XNode의 하드웨어 인터페이스에 연결된 포트 제공
  - 다양한 전원 (3V3, 5V, 12V, GND) 포트 제공

### 확장 모듈
- XNode 모트의 확장 포트에 연결해 사용
- 관성 센서(IMU), 비접촉 적외선온도 센서(IRDA), 움직임감지 센서(PIR), 범지구측위 센서(GPS), 기본 IO 장치(LED, 버튼, 부저)  

### Auto 제어기 주변장치
- Auto 제어기의 릴레이 및 IO 포트에 연결해 사용
- 전원선(12V): 팬(FAN), 조명(Light), 가스 잠금 장치(Gas Circuit Breaker)
- 신호선: 도어락(DoorLock), 가스 감지기(Gas Detector)

## 실습 환경
PC에 xnode 툴을 설치한 후 XNode 모트 또는 Auto 제어기 (이하 실습장비)에서 실행할 마이크로파이썬 코드를 작성한 후 실습장치에서 실행  
시리얼 통신을 통해 실습장치와 협업하는 PC용 파이썬 코드 작성을 위해 PC에는 파이썬 SDK가 설치되어 있어야 함.  

실습장치(마이크로파이썬, xnode 라이브러리) <-----시리얼통신------> PC (VSCode, 파이썬 SDK, xnode 툴 등)

### XNode 모트
- 한 개의 XNode 모트 사용
  - XNode 모트의 Micro B 포트와 PC의 USB A 포토를 USB 케이블로 연결
    - 만약 PC에 Type C 포트만 제공하면 Type C to USB A 변환기를 별도 준비해야 함
  - PC에서 XNode 모트의 시리얼 포트 확인 
- 여러 개의 XNode 모트 사용
  - 5V USB 허브용 전원 어댑터를 USB 허브에 연결한 후 전용 케이블로 PC(USB 3.0 A 포트)와 USB 허브(USB 3.0 MicroB 포트) 연결.
    - USB 허브의 USB A 포트에 여러 개의 XNode 모트 연결  
  - PC에서 여러 Auto 제어기의 시리얼 포트 확인
    - XNode 모트를 하나씩 연결하면서 확인할 것

### Auto 제어기 
- 한 개의 Auto 제어기 사용
  - 12V DC 전원 입력을 Auto 제어기 전원 포트에 연결
  - Auto 제어기의 Micro B 포트와 PC의 USB A 포토를 USB 케이블로 연결
    - 만약 PC에 Type C 포트만 제공하면 Type C to USB A 변환기를 별도 준비해야 함
  - PC에서 Auto 제어기의 시리얼 포트 확인 
- 여러 개의 Auto 제어기 사용
  - 5V USB 허브용 전원 어댑터를 USB 허브에 연결한 후 전용 케이블로 PC(USB 3.0 A 포트)와 USB 허브(USB 3.0 MicroB 포트) 연결.
    - USB 허브의 USB A 포트에 여러 개의 Auto 제어기 연결  
  - 12V DC 전원 입력을 전공 공급기에 연결한 후 전용 케이블을 각각의 Auto 제어기 전원 포트에 연결
  - PC에서 여러 Auto 제어기의 시리얼 포트 확인
    - Auto 제어기를 하나씩 연결하면서 확인할 것

### 개발 툴 설치
xnode와 micropython-magic을 비롯해 실습에 필요한 툴 설치.

**xnode**
xnode는 실습장치 초기화를 비롯해 PC에서 작성한 마이크로파이썬 파일을 실습장치로 전송해 실행하거, 실행 중인 프로그램과 시리얼 통신을 수행하며, 실습장치의 파일 관리 같은 부가 기능 수행.  

```sh
pip install -U xnode
pip install -U genlib s2u quat3d smon
```

**micropython-magic** 
micropython-magic은 주피터 노트북 환경에서 실시간으로 마이크로파이썬 코드를 셀 단위로 실습장치로 전송해 실행해 줌.
주로 실습장비를 테스트하거나 특정 함수나 클래스의 사용법을 익힐 때 사용

```sh
pip install -U micropython-magic
```

## 시작하기
실습장비를 PC에 연결한 후 VSCode와 xnote 툴을 이용해 실습 진행

1. scan 명령으로 PC에 연결된 실습장비의 시리얼 포트 확인
   > - **실습 장비가 바뀔 때마다 확인**할 것! (com4로 가정)
```sh
xnode scan
```

- 만약 시리얼 포트가 여러개 출력되면 다음과 같이 장치 관리자를 실행한 후 **포트(COM & LPT) > USB Serial PortI(COMx)** 확인
```
devmgmt.msc 
```

2. init 명령으로 처음 사용하는 실습장비 초기화(포맷 및 전용 라이브러리 설치)
   > 해당 장비당 한 번만 수행하며,약 2분정도 소요됨
```sh
xnode --sport com4 init
```

3. ls 명령으로 전용 라이브러리(xnode/pop) 설치 확인
   > /flash/lib 경로에 라이브러리 위치  
```sh
xnode --sport com4 ls /flash/lib/xnode/pop
```

4. VSCode에서 새 파이썬 파일(my.py)을 만든 후 코드 작성
   > PC에서 계산 가능한 식을 시리얼 통신으로 실습장비에 전달하면 실습장비는 이를 계산한 결과를 다시 PC로 전송 
```python
def setup():
    print("Start...")

def loop():
    exp = input("> ")
    try:
        ret = eval(exp)
        print(ret)
    except:
        print("Syntax Error")

if __name__ == "__main__":
    setup()
    while True:
        loop()
```

- 마이크로파이썬에서 input()은 시리얼로부터 문자열 데이터 읽기, print()는 출력할 문자열을 시리얼로 전송

5. 작성한 코드는 run 명령으로 실습장비에 전송해 실행
   > xnode 툴이 실습장비와 시리얼 통신 수행.  
   >> 사용자가 PC 터미널에서 입력한 문자열을 실습장비로 전송하고, 실습장비가 전송한 문자열을 읽어 화면에 표시

```sh
xnode --sport com4 run my.py
```
- 프로그램이 무한 루프일 때 터미널에서 Ctrl+c를 누르면 xnode 툴은 종료하지만, 프로그램은 계속 실행됨.
  - 실습장비의 리셋 버튼을 누르면, 실행 중인 프로그램 강제 종료

6. run과 함께 -ni(또는 -in)을 사용하면 에코 기능이 꺼지므로 입력 문자가 중복 출력되지 않음
```sh
xnode --sport com4 run -ni my.py
```

7. run과 함께 -n을 사용하면 파이썬 코드를 실습장비에서 실행한 후 바로 xnode 툴 종료
```sh
xnode --sport com4 run -n my.py
```

8. xnode 툴 대신 PuTTY와 같은 시리얼 응용프로그램 사용
   > 앞서 실행한 프로그램 테스트 진행
```py
winget install PuTTY.PuTTY
```
- [주의] **xnode 툴과 putty는 동시에 실행할 수 없으므로** 반드시 xnode 툴은 종료 상태여야 함
- 설치가 완료되면 putty를 실행한 후 다음과 같이 설정
  - Connection type: Serial
  - Serial line: COMx,
  - Speed는 115200
  - Open 버튼 클릭

9. put 명령으로 PC에서 작성한 my.py를 main.py란 이름으로 바꿔 실습장비에 옮기기
   > 실습장비에 전원이 공급(또는 리셋)되면, /flash 폴더에 main.py가 있는지 검사 후 있으면 자동으로 실행

```sh
xnode --sport com4 put my.py /flash/main.py
xnode --sport com4 ls /flash
```  

- 앞서 설치한 PuTTY로 결과 확인

10. 실습장치의 파일시스템에 위치한 파일을 rm 명령으로 삭제하기
    > 앞서 옮긴 /flash/main.py 삭제
```sh
xnode --sport com4 rm /flash/main.py
xnode --sport com4 ls /flash
```
