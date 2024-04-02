## AIoT TestBed 장치 연결
실습은 MQTT 프로토콜을 활용하여 파이썬 프로그래밍을 통해 이루어집니다. 이를 활용하기 위해서는 MQTT Broker에 접속되어야 합니다. MQTT Broker는 AIoT TestBed의 Edge Computer에 미리 설치되어 있어 개인이 활용하는 PC 또는 랩탑이 TestBed 장치와 유선 또는 무선으로 연결하여 Broker에 연결하는 방식입니다. 여기서는 TestBed에 연결하는 방법에 대해 소개합니다. 

### 전원
실습 장비의 전원은 다음과 같이 장비 좌측 하단(아랫면)에 있습니다. 장비를 사용하기에 앞서 전원을 on 시켜 사용하시기 바랍니다

### 유선 연결
유선 연결 단자는 전원 단자옆에 있습니다.
네트워크 케이블을 PC와 AIoT TestBed의 유선 네트워크포트에 연결할 때에는 다음과 같은 USB이더넷 어댑터를 PC의 USB포트에 연결하여 사용합니다.

PC에 USB 이더넷 어댑터를 연결하면 자동으로 새로운 네트워크 장치가 추가되므로 엣지 디바이스와 통신하기 위해 새 IP 주소를 부여합니다. 이 과정은 새로운 USB 이더넷 어댑터를 사용할 때마다 진행해야 합니다.

```sh
ncpa.cpl
```
- IP: 192.168.5.120
- 서브넷마스크: 255.255.255.0
 
###	무선 연결
AIoT TestBed 내부에는 유/무선 공유기가 설치되어 있습니다. 이를 통해 장비에 장착된 Edge Computer 및 Controller 들이 내부 통신이 가능하고 외부에서 접속한 PC 또는 랩탑이 Edge Computer와 통신이 가능합니다. 공유기의 Wi-Fi SSID는 ‘<학교이름>-TB<번호>’와 같이 표시됩니다. 

### TestBed 내부 장치 IP 
AIoT TestBed에는 유/무선 공유기를 비롯하여 Edge Computer 등 다양한 장치가 장착되어 있고 내부 내트워크를 구성하고 있습니다. 이들은 SSH 등을 통해 접속이 가능하며 각각의 IP 정보는 고정된 IP가 할당되어 있어 언제 접속을 하더라도 동일한 정보를 통해 접속하여 활용이 가능합니다. TestBed에 장착된 각 장치의 IP 주소는 다음과 같습니다. 

장치 |	내부 IP주소  
-----|----------------|  
유선공유기 | 192.168.5.1  
Edge Computer |	192.168.5.201 (MQTT Broker)  
Controller 1 |	192.168.5.202   
Controller 2 |	192.168.5.203   
Pixel Display |	192.168.5.204  

---
## AIoT TestBed MQTT 
AIoT TestBed의 Edge Computer에는 OS 가 부팅되며 Base Node를 관리해주는 프로그램이 자동으로 동작되도록 되어 있습니다. Base Node 관리 프로그램은 실행과 동시에 자동으로 Edge Computer내부의 MQTT Broker와 연결되고, 센서 데이터를 수집하여 송신하거나 제어 데이터를 수신하여 액추에이터를 동작할 수 있도록 하는 역할을 합니다. 
 

### AIoT TestBed Topic List
Edge Computer 내부의 Broker와 통신하여 TestBed의 센서의 값을 확인하거나 액추에이터를 제어할때는 토픽을 활용합니다. 각각의 토픽들은 미리 정의되어 있으며 정해진 토픽을 활용하는 형태로 TestBed를 활용합니다. 

최상위 토픽은 각 TestBed의 고유 번호로 설정되어있습니다. 설치된 장소 및 장비미다 고유번호가 다른데, 아산스마트팩토리마이스터고는 5대가 설치되어 있으므로 다음과 같은 고유번호가 하나씩 할당됩니다. 

```sh
ASM01
ASM02
ASM03 
ASM04
```

다음 절의 각각의 토픽 리스트 소개에서는 편의상 최상위 토픽을 (고유번호)라고 표기하겠습니다. 

### 액추에이터 제어(/actuator)
**조명 제어**
- Data: 0(끄기) or 1(켜기)
- Topic: (고유번호)/actuator/light
- 하위 노드
  - /kitchen: 부엌 조명 제어
  -	/living: 거실 조명 제어
  -	/door: 현관 조명 제어

**팬 제어**
- Data: 0(끄기) or 1(켜기)
- Topic: (고유번호)/actuator/fan
- 하위 노드
  -	/kitchen: 부엌 팬 제어
  -	/living: 거실 팬 제어

**커튼 제어**
- Data: 0(올리기) or 1(내리기)
- Topic: (고유번호)/actuator/curtain

**도어락 제어**
- Data: 0(잠금) or 1(열림)
- Topic: (고유번호)/actuator/lock

**가스브레이크 제어**
- Data: 0(잠금) or 1(열림)
- Topic: (고유번호)/actuator/gasbreaker

### Pixel Display 제어(/display)

**텍스트 표시**
- Data: 문자열(ex: Hello)
- Topic: (고유번호)/display

**백그라운드 색상 제어**
- Data: 문자열(색상코드 ex: FFFFFF)
- Topic: (고유번호)/display/bgc

**텍스트 색상 제어**
- Data: 문자열(색상코드 ex: FFFFFF)
- Topic: (고유번호)/display/tc

**텍스트 시프팅 방향 설정**
- Data: ‘left’(왼쪽) or ‘right’(오른쪽) or ‘off’(비활성화)
- Topic: (고유번호)/display/shifting_dir

**텍스트 시프팅 딜레이 설정**
- Data: 정수(ms 단위 ex: 10)
- Topic: (고유번호)/display/shifting_delay

**Display 점멸 주기 설정**
- Data: 정수(활성화 및 주기 설정 ms  ex: 10) or ‘off’ (비활성화)
- Topic: (고유번호)/display/blink

### 센서 데이터 수집(/sensor)
센서 데이터 토픽 설명 중 ‘하위 노드’ 라고 적혀져 있을 경우, 해당 하위 노드까지 합쳐진 토픽을 구독해야 관련 데이터가 표시됩니다.

**습도 데이터**
- Data: 0~100
- Topic: (고유번호)/sensor/humi
- 하위 노드
  - /kitchen: 부엌 습도 데이터
  -	/living: 거실 습도 데이터
  -	/door: 현관 습도 데이터

**온도 데이터**
- Data: 온도 정수값
- Topic: (고유번호)/sensor/temp
- 하위 노드
  -	/kitchen: 부엌 온도 데이터
  -	/living: 거실 온도 데이터
  - /door: 현관 온도 데이터

**조도 데이터**
- Data: 정수값
- Topic: (고유번호)/sensor/light
- 하위 노드
  -	/living: 거실 조도 데이터

**가스 데이터**
- Data: 0(미감지) or 1(감지)
- Topic: (고유번호)/sensor/gasdata

**먼지 데이터**
- Data: 정수값
- Topic: (고유번호)/sensor/dust

**PIR 데이터**
- Data: 0(미감지) or 1(감지)
- Topic: (고유번호)/sensor/pir

