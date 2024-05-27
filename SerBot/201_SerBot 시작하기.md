# SerBot 시작하기
Serbot은 한백전자에서 개발한 머신러닝 기반 서비스로봇 실습 장비입니다.  
사용자가 머신러닝을 접목한 자율주행 기술 습득에 집중할 수 있도록 한백전자에서 개발한 Pop을 비롯해 다양한 머신러닝 모델 및 라이브러리가 내장되어 있습니다.  

<details>
<summary>개요</summary>

## SerBot 구조
SerBot에는 옴니췰이나 DC모터, 프레임 같은 기구물 외에 많은 전자장치가 포함되어 있습니다.  
- 전원부: 동작에 필요한 전원을 안정적으로 공급
- 메인 모듈: 각종 센서와 액추에이터에 제어 명령을 내리고 인공지능 학습 및 예측 실행
  - DC모터, IMU 센서, 빛 센서, 링 픽셀 제어 
  - 카메라, 오디오, 커넥티비티(이더넷, Wi-Fi, 블루투스), 라이다(옵션) 제어
  - 엔비디아의 Jetson Nano(또는 Xavier NX) 사용. 우분투 리눅스로 운영

제공되는 USB 이더넷 어댑터를 PC에 연결 ① 한 후 이더넷 케이블로 양쪽 이더넷 포트를 연결 ②,③ 합니다.  
> PC가 랩톱이라면 이더넷 포트가 없는 경우가 많고, 데스크톱이라면 인터넷에 연결되어 있으므로 별도의 USB 타입 이더넷 어댑터 제공 

## SerBot 부팅
처음 시작하거나 내장된 배터리 전원이 충분치 않으면 전원 어댑터에 콘센트 연결선 ① 을 꼽고 콘센트에 연결 ② 합니다.  
반대쪽을 SerBot의 전원 포트 ③ 에 연결한 후 전원 스위치를 ON ④ 시킵니다.

SerBot에 전원이 공급되면 메인 모듈은 범용 리눅스 운영체제를 시작합니다.  
전원이 공급된 후 약 1분 정도 지나면 부팅이 완료되어 센서 및 액추에이터를 제어할 수 있습니다.  
- IMU(가속도, 각속도) 및 빛 센서값 읽기
- 라이다 센서값 읽기
- 옴니휠 기반 이동체 3축 DC 모터 구동
- 터치 스크린, 오디오(마이크, 스피커) 사용 가능

메인 모듈에서 실행되는 리눅스의 주요 기능은 다음과 같습니다.
- **우분투** 리눅스를 수정해 인공지능 자율주행 교육에 최적화한 환경 제공
  - zsh(Oh-my-zsh 포함)과 tmux로 현대적인 CLI 환경 사용
  - SSH Server, Jupyter Server 활성화
- 엔비디아의 임베디드 GPU 개발환경인 **JetPack(CUDA, CuDNN, TensorRT, Tensorflow, Pytorch 등)** 포함
  - 객체 분류 및 탐지를 위해 사전 학습된 ResNet, Yolo 모델 제공
  - Pop.AI를 통해 좀 더 쉬운 머신러닝 실습 환경 제공
- 좀 더 쉽게 SerBot을 제어하고 간편하게 인공지능 기술을 자율주행에 적용하는 **Pop 라이브러리** 포함
  - Pop을 통해 서브 모듈 기능 사용
  - numpy, matplotlib, pyqt5, opencv-python 등 파이썬 라이브러리 사전 설치

## SerBot 전원
SerBot의 전자 장치는 상시 또는 배터리 전원로 움직이며, 전원부는 이를 각 부품이 요구하는 전압으로 변환해 공급합니다.

- 상시 전원
  - 상시 전원 어댑터로 220V AC를 12V DC로 변환해 SerBot에 공급
- 배터리 충전 전원
  - 배터리를 충전하기 위한 전원
  - 충전 전압, 충전 종지 전압: 12.6V 
  - 정격 전압: 11.6V
  - 방전 종지 전압: 10.6V  

> 충전 전압은 배터리를 충전하는 데 필요한 전압, 충전 종지 전압은 배터리가 완충되었을 때 전압.  
> 정격 전압은 배터리를 처음 생산해 출고할 때 전압, SerBot은 메인 모듈의 소모 전력이 높아 이 값보다 작으면 배터리 충전에 대비해야 함.  
> 방전 종지 전압은 충전에 필요한 최소 전압으로 이보다 작으면 더 이상 충전되지 않으므로 주의해야 함.

**전원 선택 스위치**  
SerBot은 상시 또는 배터리 전원을 선택하는 스위치가 있습니다. 중립은 전원 차단 상태이며 위 또는 아래로 스위칭하면 상시 또는 배터리 전원을 통해 SerBot이 부팅됩니다.
> 선택 스위치는 회전할 수 있어, 사용자 확인 필요

**전원 상태 확인**  
SerBot에는 사용자가 현재 전압을 확인할 수 있도록 상시 전원 ① 또는 배터리 전원 ② 에 대한 전압 상태를 전압 표시기가 있습니다.
> SerBot에 연결된 어댑터 및 배터리 출고값에 따라 0.1V ~ 0.3 정도의 편차 발생

### 배터리 방전 주의 
SerBot이 방전 종지 전압에 도달하면 SerBot의 사용을 멈추고 외부 전원을 연결해 배터리를 충전합니다.

- 전원 스위치를 OFF 시키고, 전원 어댑터를 SerBot에 연결한 후 2시간 이상 충전할 것  
- 완충까지는 5시간 이상 소요 (외부 온도에 따라 다름)
</details>

<details>
<summary>Serbot OS 업그레이드</summary>

## nano에 우분투 20.04 설치
NVIDIA는 nano에 대해 우분투 20.04 이상을 지원하지 않으므로, 이를 사용하려면 전문가의 도움이 필요합니다.  
임베디드 분야 전문 SW 기업인 Qengineering은 NVIDIA를 대신해 깃허브에 nano용 우분투 20.04 이미지를 공개했습니다.
Serbot에 이를 설치하면 pop 라이브러리를 비롯해 사전 설치한 파이썬 패키지를 다시 설치해야 합니다.

### 준비물
작업에 필요한 PC 준비물은 다음과 같습니다.

1. 윈도우 PC에서 진행한다고 가정합니다.
2. win32diskimager를 다운받아 설치합니다.  
  [win32diskimager 다운로드](https://sourceforge.net/projects/win32diskimager/files/latest/download)

3. JetsonNanoUb20_3b.img.xz를 다운받아 압축 해제합니다. (20GB 이상 여유 공간 필요)  
  [JetsonNanoUb20_3b.img.xz 다운로드](https://ln5.sync.com/dl/403a73c60/bqppm39m-mh4qippt-u5mhyyfi-nnma8c4t/view/default/14418794280004)
  > 이 링크는 시간이 지나면 사라질 수 있습니다. 다운받은 파일은 안전한 곳에 별도 보관해 둡니다.

4. PC에 자체 T-Flash 리더기가 없으면 USB 타입 T-Flash 리더기를 준비합니다.

**nerd 폰트 설치**  
nerd 폰트는 공개용 코딩 폰트에 수 많은 그래픽 문자를 추가한 특별한 폰트로 텍스트 화면을 멋지게 꾸밀 때 사용합니다.

1. 배포 사이트에서 마음에 드는 nerd 폰트 하나를 고릅니다.   
   [Nerd 폰트 다운로드](https://www.nerdfonts.com/font-downloads)

2. **Download** 링크를 눌러 다운로드한 후 압축을 해제합니다.

3. *.ttf 파일을 모두 선택한 후 컨텍스트 메뉴(마우스 오른쪽 클릭)에서 **설치** 를 선택합니다.

**파워 쉘 설치**  
MS에서 오픈소스로 배포하는 파워 쉘은 고전적인 윈도용 cmd를 대체하는 새로운 멀티 플랫폼용 쉘입니다.

1. 명령 프롬프트를 실행한 후 winget으로 파워 쉘을 설치합니다.  
```sh
winget install Microsoft.PowerShell -s winget
```

2. pwsh 명령으로 파워 쉘을 실행합니다.
```sh
pwsh
```

**윈도우 터미널 설치**  
윈도우 터미널은 CLI 디스플레이 관리자로 윈도우 터미널은 설치하면 명령 프롬프트를 비롯해 파워 쉘은 더 향상된 CLI 환경에서 실행됩니다.

1. winget으로 윈도우 터미널을 설치합니다.  
```sh
winget install Microsoft.WindowsTerminal -s winget
```

2. 윈도우 터미널 설치가 끝나면 wt 명령으로 실행합니다.
```sh
wt
```

3. <Ctrl>+<,>를 눌러 설정을 표시합니다.

4. 시작에서 기본 프로필을 **PowerShell** 로 변경합니다.

5. 시작에서 기본 터미널 프로그램 항목을 **Windows 터미널** 로 변경합니다.

6. 프로필 아래 기본값에서 모양을 선택하고 색 구성 표를 **Tango Dark**, 글꼴은 앞서 설치한 **\<nerd 폰트>**를 선택합니다.

7. 프로필 아래 기본값에서 고급을 선택하고 프로필 종료 동작을 **프로세스가 종료, 실패 또는 충돌 시 닫기**로 변경합니다.

8. 저장 버튼을 눌러 설정을 종료합니다.


### nano 모듈에 연결된 T-Flash 빼내기
Serbot의 nano 모듈에 연결된 T-Flash는 64GB용량이므로 이를 재사용합니다. 단, Serbot은 구조 상 nano 모듈의 T-Flash 슬롯 접근이 조금 어렵습니다.
T-Flash는 nano 캐리어 보드의 SO-DIMM 컨넥터에 연결된 nano 모듈 아래에 T-Flash 슬롯에 꼽혀 있으므로 드라이버를 이용해 다음과 같이 캐리어 보드에서 nano 모듈의 고정 나사 및 걸쇠를 풀고 T-Flash 슬롯에서 T-Flash를 빼냅니다.

- 드라이버로 nano 모듈 고정 나사 2개 풀기 (나사 파손 및 분실 주의)
- 드라이버로 nano 모듈 잠금 걸쇠 2개를 바깥으로 밀기
- nano 모듈이 약 30도 정도 비스듬하게 위로 올라옴
- nano 모듈 아래에 T-Flash 슬롯에서 완전히 삽입된 T-Flash를 살짝 누름
- T-Flash가 10mm 정도 튀어 나오면 이를 뽑음

### T-Flash에 Ubuntu 20.04 이미지 설치
T-Flash를 리더기에 연결하면 새로운 드라이버 문자가 할당됩니다. win32diskimager를 이용해 압축 해제한 이미지 파일을 다음과 같이 설치합니다.
- win32diskimager 실행
- Image File 선택 버튼을 누르고 압축 해제한 경로에서 JetsonNanoUb20_3b.img 선택
- Device에서 T-Flash가 연결된 드라이버 문자 선택
- Write 버튼을 눌러 이미지 설치 (약 25 ~ 35분 정도 소요)
- 설치가 완료되면 리더기에서 T-Flash를 뽑아 다시 jetson nano에 연결

### T-Flash를 nano 모듈에 다시 넣기
T-Flash를 nano 모듈에 다시 넣는 것은 빼내기의 역순입니다. 이미지 설치가 끝나면 다음과 같이 진행합니다.
- T-Flash를 nano 모듈 아래 T-Flash 슬롯에 완전히 밀어 넣음
- 비스듬하게 세워진 nano 모듈을 아래로 눌러 2개의 잠금 걸쇠에 고정
- 드라이버로 2개의 nano 모듈 고정 나사를 조임

## 원격 터미널 연결
Serbot에 전원을 넣고 스위치를 켜면 Qengineering에서 배포한 우분투 20.04가 부팅되며, 초기 사용자 id와 pw는 둘 다 jetsno입니다.
PC에서 Serbot의 우분투 20.04 리눅스 쉘에 접근하려면 TCP/IP 기반 SSH 원격 터미널 기능을 사용합니다.  

PC와 Serbot을 Wi-Fi나 이더넷 또는 USB 케이블 중 하나로 연결한 후 Serbot에 부여된 IP 주소를 이용해 원격 터미널 연결을 시작합니다.

### Wi-Fi 연결
PC와 Serbot은 같은 네트워크에 속해야 하며 다음과 같이 해당 공유기에 연결한 후 자동 할당된 IP 주소를 확인합니다.

- Serbot 화면 왼쪽 런처에서 Settings 아이콘 클릭
- 설정창 왼쪽 항목에서 Wi-Fi 선택
- 오른쪽 연결 가능한 공유기 목록에서 연결할 공유기 선택
- 패스워드 입력창이 표시되면 가상 키보드를 이용해 공유기 비밀번호 입력 (처음 가상 키보드가 표시되면 인식이 안될 수 있으므로 30초 간 대기 후 입력 시작)
- 연결된 공유기 항목 끝의 설정 아이콘을 눌러 할당된 IP 주소 확인

### 이더넷 연결
> 기존 Serbot에서 제공하던 이더넷 IP 192.168.101.101을 사용하려면 사용자 작업이 필요합니다.

PC와 Serbot은 같은 네트워크에 속해야 하며 일반적으로 DHCP 서버로부터 자동으로 IP 주소를 할당받아야 합니다. 자동 할당된 IP 주소는 다음과 같이 확인합니다.

- Serbot의 이더넷 포트에 이더넷 케이블 연결
- Serbot 화면 왼쪽 런처에서 Settings 아이콘 클릭
- 설정창 왼쪽 항목에서 Network 선택
- 연결된 이더넷 항목 끝의 설정 아이콘을 눌러 할당된 IP 주소 확인

### USB 연결
USB 케이블로 PC와 Serbot을 연결하면 이더넷 연결과 같으나 PC와 Serbot 사이 1:1 로컬 통신만 허용하므로 인터넷을 통한 시스템 업데이트가 필요하면 추가로 Wi-Fi나 이더넷 연결이 필요합니다.

PC와 Serbot에는 다음과 같이 미리 설정한 IP가 자동 할당됩니다. 

- PC와 Serbot에는 가상 이더넷 어댑터가 자동 추가됨
- PC의 가상 이더넷 어댑터에는 IP 주소 192.168.55.100이 자동 할당됨
- Serbotd의 가상 이더넷 어댑터에는 IP 주소 192.168.55.1이 자동 할당됨

### ping 테스트
> PC와 Serbot이 같은 AP에 연결되었고, Serbot의 IP 주소는 192.168.100.59로 가정합니다.

Serbot에 할당된 IP 주소로 ping 테스트를 수행합니다.

```sh
ping 192.168.100.59
```

### 원격 쉘 얻기
> 기존 Serbot 운영체제의 사용자 계정은 soda였으나 새로 설치한 운영체제의 사용자 계정은 jetson입니다.
ping 테스트가 성공하면 Serbot에 할당된 IP 주소와 사용자 계정으로 SSH 접속에 접속합니다.   
계정 id와 비밀번호는 모두 jetson입니다.

```sh
ssh jetson@192.168.100.59
```

- 처음 연결하면 암호화에 필요한 fingerprint 키 저장을 요청하는데 yes 입력
- 비밀번호는 jetson<ENTER> 입력 (화면에 표시되지 않음)
- bash이 실행됨


## T-Flash의 파이션1 크기 확장
T-Flash는 우분투 20.04 파일 시스템의 /dev/mmcblk0 포인터에 마운트되어 있으며, 우분투 20.04 파일 시스템 자체는 파티션1(p1)에 위치합니다.
Qengineering은 20GB 크기의 파티션에서 우분투 20.04 배포 이미지를 만들었으므로 T-Flash 크기가 32GB 이상이면, 나머지 공간에 대한 확장이 필요합니다.

### 파이션1 크기 변경
T-Flash 파티션 할당 정보는 lsblk 명령으로 확인합니다.

```sh
lsblk /dev/mmcblk0
```

T-Flash의 크기는 다음과 같이 59.6G이나 파티션1(/)은 29.1G만 사용하는 것을 알 수 있습니다.

```
NAME         MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
mmcblk0      179:0    0 59,5G  0 disk
├─mmcblk0p1  179:1    0 29,1G  0 part /
...
```

다음과 같이 fdisk 명령으로 기존 파이션1을 삭제한 후 새로 만듦니다.

1. T-Flash에 대해 fidks 명령을 실행합니다.
```
sudo fdisk /dev/mmcblk0
```

2. 모든 파티션 정보 출력합니다.
```
p
```

3. 파이션1을 삭제합니다.
```
d
1
```

4. 파티션1을 새로운 크기로 다시 만듦니다.
```
n
1
<ENTER>
<ENTER>
y<ENTER>
```

5. 저장 후 종료합니다.
```
w
```

### 파일 시스템에 반영

lsblk로 확인해 보면 파티션1의 크기가 바뀌었습니다.

```sh
lsblk /dev/mmcblk0
NAME         MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
mmcblk0      179:0    0 59,5G  0 disk
├─mmcblk0p1  179:1    0 59,5G  0 part /
...
```

하지만 df 명령으로 실제 파티션1의 할당 크기를 보면 변경되지 않았습니다.
```sh
df -h
```
```sh
Filesystem      Size  Used Avail Use% Mounted on
/dev/mmcblk0p1   26G   20G  4,2G  83% /
```

resize2fs 명령으로 변경한 파티션1 정보를 파일 시스템에 반영합니다.

```sh
sudo resize2fs /dev/mmcblk0p1
```

```sh
df -h
```
```sh
Filesystem      Size  Used Avail Use% Mounted on
/dev/mmcblk0p1   59G   20G   37G  36% /
```


## 우분투 20.04 최적화
> Serbot에 설치되었던 기존 우분투 18.04는 이 작업을 포함한 더 많은 최적화가 적용되어 있습니다.

우분투는 데스크탑을 위한 리눅스 운영체제로 nano와 같은 임베디드 환경에서는 다소 무겁습니다. 꼭 필요하지 않은 몇몇 패키지와 서비스를 제거하면 더 적은 메모리를 사용하고, 저장소를 절약할 수 있습니다.

### 시스템 업데이트
처음 우분투 20.04를 시작하면 인터넷 저장소 정보를 업데이트한 후 오래된 시스템 패키지를 업그레이드 합니다.

```sh
sudo apt update
sudo apt upgrade -y
```

### 시간을 한국 표준 시간(KST)로 변경
우분투는 기본적으로 로컬 타임 존이 미국 동부 시간으로 설정되어 있습니다. 우리나라 시간에 맞추기 위해 아시아 서울로 변경합니다.

```sh
date
sudo ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime
date
```

### 인터넷 연결 설정
기존 우분투 데스크탑 환경에서 Wi-Fi 또는 이더넷 연결 설정은 시스템 설정 툴을 사용합니다. 하지만 gnome 패키지를 제거하면 함께 삭제되므로 지금은 사용할 수 없습니다.
대신 우분투 네트워크 설정을 관리하는 NetworkManager는 CLI 환경을 위해 nmcli와 nmtui와 함께 제공하며 초보자라면 메뉴 형식의 nmtui가 좀 더 직관적입니다.
단, Serbot이 이미 인터넷에 연결된 공유기에 연결된 상태라면 넘어가도 됩니다. 즉, 다른 공유기를 사용할 때만 실행합니다.

1. nmtui을 실행합니다.
```sh
nmtui
```

2. 메뉴가 표시되면 방향 키와 <ENTER>로 Edit a connction을 선택합니다.

3. Wi-Fi 목록에서 연결할 공유기 이름을 확인한 후 이를 <ENTER>를 선택합니다. 

4. Password에 알맞는 비밀번호를 입력한 후 <OK>를 선택하면 설정이 완료됩니다.

### snap 제거
snap은 우분투의 패키지 관리자 중 하나로 모든 종속성을 포함한 패키지를 빠르고 쉽게 찾아 설치할 수 있지만, deb 패키지에 비해 성능이 느리고, 패키지 크기가 더 크다는 단점이 있습니다.

1. snap 설치 목록을 확인합니다.

```sh
snap list
```
```sh
Name               Version           Rev    Tracking         Publisher   Notes
bare               1.0               5      latest/stable    canonical✓  base
core18             20230703          2794   latest/stable    canonical✓  base
core20             20240227          2267   latest/stable    canonical✓  base
core22             20230801          867    latest/stable    canonical✓  base
gnome-3-34-1804    0+git.3556cb3     94     latest/stable/…  canonical✓  -
gnome-3-38-2004    0+git.cd626d1     88     latest/stable    canonical✓  -
gtk-common-themes  0.1-59-g7bca6ae   1519   latest/stable/…  canonical✓  -
snap-store         41.3-71-g709398e  963    latest/stable/…  canonical✓  -
snapd              2.60.3            20102  latest/stable    canonical✓  snapd
```

2. 목록에서 표시된 snap 패키지를 다음과 같이 하나씩 차례로 제거합니다.

```sh
sudo snap remove --purge snap-store
sudo snap remove --purge gnome-3-38-2004
sudo snap remove --purge gnome-3-34-1804
sudo snap remove --purge gtk-common-themes
sudo snap remove --purge bare
sudo snap remove --purge core18
sudo snap remove --purge core20
sudo snap remove --purge core22
sudo snap remove --purge snapd
```

3. snap 데몬을 제거 합니다.
```sh
sudo apt remove --autoremove snapd -y
```

4. snap이 시스템 업데이트 과정에서 다시 설치되지 않도록 트리거를 중단합니다.
- vi 편집기로 /etc/apt/preferences.d 경로에 nosnap.pref 파일을 만듧니다.
```sh
sudo -H vi /etc/apt/preferences.d/nosnap.pref
```

- 빈 파일이 열리면 \<i>를 눌려 입력 모드로 바꿉니다.
- 다음 내용을 입력합니다.
```sh
Package: snapd
Pin: release a=*
Pin-Priority: -10
```
- \<ESC>를 눌러 명령 모드로 바꿉니다.
- \<:> \<x> \<ENTER>를 차례로 눌러 저장한 후 종료합니다.

5. gnome 소프트웨어를 apt로 설치할 때 snap이 다시 설치되지 않도록 다음 명령을 실행합니다.
```sh
sudo apt install --install-suggests gnome-software -y
```

**snap 다시 되돌리기**
만약 snap이 필요하면 다음 명령을 실행합니다.
```sh
sudo rm /etc/apt/preferences.d/nosnap.pref
sudo apt update && sudo apt upgrade
sudo snap install snap-store
```

### X.org 관련 상위 패키지 변경
리눅스 GUI 환경은 윈도우 운영체제와 달리 X.org(X-Server의 구현 중 하나)와 같은 디스플레이 서버 위에 디스플레이 괸리자와 창 관리자 또는 데스크톱 환경이 목적에 따라 다양한 조합으로 실행됩니다.  
디스플레이 서버는 GUI 환경을 위한 표준 서비스이고, 나머지는 디스플레이 서버가 제공하는 서비스를 이용하는 응용프로그램입니다.
그 중 디스플레이 관리자는 부팅 프로세스가 끝나면 기본 쉘 대신 표시되는 그래픽 인터페이스로 로그인 및 세션을 관리하고, 창 관리자는 창의 생성, 조작, 배치 및 표시를 관리하는 프로그램입니다.
디스크탑 환경은 사용자를 위해 테마와 창 효과를 비롯해, GUI 환경에서 시스템 설정 및 업데이트와 작업 표시 줄, 런처 같은 다양한 부가 가능을 제공합니다.

우분투 20.04는 디스플레이 관리자로 gdm3을, 데스크톱 환경은 창 관리자인 unity가 결합된 gnome을 사용합니다. 하지만 교체를 희망하는 사용자를 위해 lightdm과 openbox도 함께 설치되어 있습니다.
lightdm은 gdm3를 대체하는 디스플레이 관리자이고, openbox는 gnome을 대체하는 창 관리자입니다. gdm3나 gnone+unity 조합에 비해 부가 기능이나 화려함은 떨어지지만 더 적은 메모리와 저장소를 사용하므로 좀 더 쾌적한 환경에서 인공지능 로봇 개발을 진행할 수 있습니다.

1. gdm3 및 gnome, unity를 제거합니다.
```sh
bash
sudo apt purge gnome* -y
sudo apt autoremove -y

rm -rf ~/.config/*
exit
```

2. lightdm을 디스플레이 관리자로 설정합니다.
```sh
sudo dpkg-reconfigure lightdm
cat /etc/X11/default-display-manager
```

3. openbox을 창 관리자로 설정합니다.
- vi 편집기로 /etc/lightdm/lightdm.conf.d/ 경로의 50-nvidia.conf 파일을 엶니다.
```sh
sudo vi /etc/lightdm/lightdm.conf.d/50-nvidia.conf
```

- 커서를 **user-session=**로 옮긴 후 <DEL>를 차례로 눌러 ux-LXDM을 삭제합니다. 
- \<i>를 눌려 입력 모드로 바꾼 다음 삭제한 문자열 대신 ux-openbox를 입력합니다.
```sh
user-session=ux-openbox
```
- \<ESC>를 눌러 명령 모드로 바꿉니다.
- \<:> \<x> \<ENTER>를 차례로 눌러 저장한 후 종료합니다.

4. Serbot을 재 시작해 openbox를 실행합니다.
- Serbot을 다시 시작하면 jetson 계정으로 자동 로그인합니다.
```sh
sudo reboot
```

### 배경 이미지나 색 설정
openbox는 바탕 화면에 대한 지원이 없습니다. 따라서 배경 색이나 이미지를 설정하려면 다른 툴의 도움을 받아야 합니다.
SSH 원격 접속 터미널에서 X 응용프로그램을 실행할 때는 DISPLAY 환경변수 설정이 필요합니다.

1. 배경 이미지를 설정하려면 nitrogen보다 빠른 feh를 설치합니다.
```sh
sudo apt install feh
```

2. 배경 이미지를 출력해 봅니다.
```sh
DISPLAY=:0 feh --bg-fill /usr/share/backgrounds/NVIDIA_Wallpaper.jpg
```

3. openbox가 실행될 때 배경 이미지 설정 명령도 함께 실행되도록 합니다.
- vi 편집기로 ~/.config/openbox 경로에 autostart 파일을 만듦니다.
```sh
vi ~/.config/openbox/autostart
```
- 빈 파일이 열리면 \<i>를 눌려 입력 모드로 바꾼 다음 다음 내용을 입력합니다.
```sh
feh --bg-fill /usr/share/backgrounds/NVIDIA_Wallpaper.jpg
```
- \<ESC>를 눌러 명령 모드로 바꾼 후 \<:> \<x> \<ENTER>를 차례로 눌러 저장한 후 종료합니다.

4. 배경색 설정은 다음 명령을 사용합니다. (단 배경 이미지는 사용할 수 없습니다.)
```sh
DISPLAY=:0 xsetroot -solid "#006666"
```

5. ~/.config/openbox/autostart를 수정해 openbox가 실행될 때 배경색 설정 명령도 함께 실행되도록 합니다.
```sh
xsetroot -solid "#006666"
```

### 윈도우 패널 설치
openbox는 단순한 창 관리자이므로 패널(시작 메뉴, 현재 실행 중인 프로그램 목록, 트레이 등)나 배경화면과 같은 데스크탑 환경은 제공하지 않습니다.  
lxpanel, xface panel, tint2 등 다양한 다양한 패널 프로그램이 있는데, 그 중 openbox와 어울리는 패널은 tint2입니다.

1. tint2를 설치합니다.
```sh
sudo apt install tint2
```

2. tint2 테마를 설치합니다.
```sh
git clone https://github.com/addy-dclxvi/tint2-theme-collections ~/.config/tint2 --depth 1
```

3. tint2를 해당 테마로 실행해 봅니다. <Ctrl>+c를 누르면 종료합니다.
```sh
DISPLAY=:0 tint2 -c ~/.config/tint2/raven/raven-cyan.tint2rc
```

4. openbox가 실행될 때 tint2도 함께 실행되도록 설정합니다.
- vi 편집기로 ~/.config/openbox 경로의 autostart 파일을 엶니다.
```sh
vi ~/.config/openbox/autostart
```
- 파일이 열리면 끝 줄로 이동한 후 \<o>를 눌려 아랫 줄을 추가한 후 입력 모드에서 다음 내용을 입력합니다. (줄 끝 &는 백그라운드 실행을 의미합니다.)
```sh
tint2 -c ~/.config/tint2/raven/raven-cyan.tint2rc &
```
- \<ESC>를 눌러 명령 모드로 바꾼 후 \<:> \<x> \<ENTER>를 차례로 눌러 저장한 후 종료합니다.


### GUI 원격 데스크탑 환경
PC에서 원격으로 Serbot의 GUI 환경을 사용할 때는 VNC를 비롯해 RDP등 다양한 솔루션이 있지만, 네트워크 환경에 따라 가변 압축을 지원하는 nomachine을 권장합니다.
nomachine은 상업, 비상업 버전으로 나뉘는데, 두 버전의 기본적인 기능은 같고 비상업 버전은 세션당 한명의 사용자만 연결할 수 있습니다.

1. Serbot에 nomachine 서버를 설치합니다.
```sh
wget https://www.nomachine.com/free/arm/v8/deb -O nomachine.deb
sudo dpkg -i nomachine.deb
rm nomachine.deb
```

2. PC에서 nomachine 클라이언트를 설치합니다.
```sh
winget install NoMachine.NoMachineClient -s winget
```

3. PC에서 namachine 클라이언트를 실행한 후 Serbot의 IP 주소를 이용해 원격 접속합니다.
- Search 창에 SerBot IP 주소를 입력한 후 목록에서 <connect to new host ...> 선택
- 연결 창에 Username과 Password에 모두 jetson을 입력 한 후 Login 선택
- Serbot에 연결되면 마우스로 openbox 화면 오른쪽 상단 끝을 클릭해 설정 화면으로 이동
- 하단 아이콘 목록에서 Change settins(오른쪽 끝) 선택
- Resolution을 1280x720으로 변경 후 Modify 선택
- 하단 아이콘 목록에서 Resize remote display(가운데) 선택
- 상단 뒤로 가기 버튼을 눌러 원래 openbox 화면으로 복귀


### 파이썬2 제거
일반적으로 파이썬3를 사용하므로 오래된 파이썬2 패키지를 제거합니다.

```sh
sudo apt remove --purge python2* -y
```

### zsh
zsh은 재귀 경로 확장을 비롯해 플러그인과 테마를 지원하는 현대적인 쉘입니다.

1. apt 명령으로 zsh을 설치합니다.
```sh
sudo apt install zsh -y
```

2. zsh을 설치했으면, 기본 쉘을 zsh로 변경합니다.
```sh
chsh -s $(which zsh) 
```

3. zsh을 실행합니다. 
```sh
zsh
```

4. 쉘 스크립트 선택 메시지가 출력되면 <2>를 눌러 범용 설정으로 자동 생성합니다. 
```
...
You can:

(q)  Quit and do nothing.  The function will be run again next time.

(0)  Exit, creating the file ~/.zshrc containing just a comment.
     That will prevent this function being run again.

(1)  Continue to the main menu.

(2)  Populate your ~/.zshrc with the configuration recommended
     by the system administrator and exit (you will need to edit
     the file by hand, if so desired).

--- Type one of the keys in parentheses --- 
```

### oh-my-zsh
oh-my-zsh은 zsh을 위한 테마 관리자입니다. oh-my-zsh을 설치하면 zsh 기능을 확장하는 유용한 플러그인을 설치하고 내장된 테마 중 하나를 선택할 수 있습니다.

1. wget으로 oh-my-zsh 설치 스크립트를 다운받아 실행합니다.
```sh
sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
```

2. 만약 기본 쉘로 zsh을 사용할지 묻는 메시지가 표시되면 <y> 또는 <ENTER>를 누릅니다.
```
Looking for an existing zsh config...
Found /home/jetson/.zshrc. Backing up to /home/jetson/.zshrc.pre-oh-my-zsh
Using the Oh My Zsh template file and adding it to /home/jetson/.zshrc.

Time to change your default shell to zsh:
Do you want to change your default shell to zsh? [Y/n]
```

3. 기본 테마가 자동 선택된 후 설치가 종료합니다.
```sh
...
         __                                     __   
  ____  / /_     ____ ___  __  __   ____  _____/ /_  
 / __ \/ __ \   / __ `__ \/ / / /  /_  / / ___/ __ \ 
/ /_/ / / / /  / / / / / / /_/ /    / /_(__  ) / / / 
\____/_/ /_/  /_/ /_/ /_/\__, /    /___/____/_/ /_/  
                        /____/                       ....is now installed!


Before you scream Oh My Zsh! look over the `.zshrc` file to select plugins, themes, and options.

• Follow us on Twitter: @ohmyzsh
• Join our Discord community: Discord server
• Get stickers, t-shirts, coffee mugs and more: Planet Argon Shop
```

### powerlevel10k
powerlevel10k는 zsh 테마 중 하나로 oh-my-zsh에 포함된 테마보다 더 보기 좋습니다. 

1. git으로 powerlevel10k을 설치합니다.
```sh
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

2. vi 편집기로 ~/.zshrc 파일을 엶니다.
```sh
vi ~/.zshrc
```

3. 방향 키로 커서를 ZSH_THEME 변수 위치(11번 줄)로 옮깁니다.
```sh
ZSH_THEME="ZSH_THEME="robbyrussell""
```

4. 문자열을 <DEL>로 삭제하고, <i>를 눌러 입력 모드로 바꾼 후 다음과 같이 입력합니다.  
```sh
ZSH_THEME="powerlevel10k/powerlevel10k"
```

5. <ECS>와 <:><x><ENTER>를 차례로 눌러 저장한 후 종료합니다.

6. exit 명령으로 터미널 연결을 종료합니다. 
```sh
exit
```

7. 윈도우에서 ssh 명령으로 다시 Serbot IP 주소를 이용해 접속합니다. 
```sh
ssh jetson@192.168.100.59
```

8. powerlevel10k 설정을 시작합니다.
```
diamond: y (Yes)
lock: y (Yes)
upwards arrow y (Yes)
fit between the crosses: y (Yes)
Prompt Style: 3 (Rainbow)
Character Set: 1 (Unicode)
Show current time: 2 (24-hour format)
Prompt Separators: 4 (Round)
Prompt Heads: 4 (Slanted)
Prompt Tails: 5 (Round)
Prompt Height: 2 (Two lines)
Prompt Connection: 3 (Dotted)
Prompt Frame: 3 (Right)
Connection & Frame Color: 3 (Dark)
Prompt Spacing: 2 (Sparse)
Icons: 2 (Many icons)
Prompt Flow: 2 (Fluent)
Enable Transient Prompt: y (Yes)
Instant Prompt Mode: 2 (Quiet)
Apply changes to ~/.zshrc: y (Yes)
```

9. powerlevel10k를 다시 설정하려면 다음 명령을 실행합니다.
```sh
 p10k configure 
```
</details>
  
<details>
<summary>SerBot 프로젝트 생성</summary>
  
## SerBot 설정
SerBot의 메인 모듈은 우분투 리눅스로 운영되며 미리 기본적인 설정이 되어 있습니다.  

### Wi-Fi로 인터넷 연결
SerBot은 이더넷과 Wi-Fi를 지원합니다. 이더넷은 PC와 연결되어 있으므로 인터넷 연결은 Wi-Fi를 권장합니다.  
또한 주행 실습은 대부분 배터리 전원을 사용하므로 공유기가 준비되어 있다면 PC와도 Wi-Fi로 연결할 필요가 있습니다.   
SerBot을 Wi-Fi 공유기에 연결하면 VSCode가 SerBot에 원격 접속되어 있어야 하고, 관리자에게 Wi-Fi 공유기 이름(SSID)과 패스워드를 확인해야 합니다.  

사전 준비가 끝나면 다음과 같이 SerBot의 리눅스 쉘을 실행합니다.
> 쉘은 사용자의 표준 입력을 해석해 운영체제의 핵심 영역인 커널로 전달하고, 응답을 표준 출력으로 사용자에게 돌려줍니다.  
>> 표준 입력은 키보드, 표준 출력은 모니터의 텍스트 모드 영역을 가리키며, 이를 명령 라인 인터페이스(CLI)라 합니다.  
>> SerBot의 기본 쉘은 현대적인 zsh이며, oh-my-zsh이 함께 설정되어 있습니다.

- VSCode 메뉴의 **Terminal** ① 에서 **New Terminal** ② 을 선택합니다.
- 터미널창 ③ 이 표시되면, 리눅스 명령을 실행할 수 있습니다.
- 터미널창에 포함된 **Maximize Panel Size** ④ 을 선택하면 창 크기가 최대화됩니다.

네트워크 관리자인 nmcli 명령을 이용해 SerBot을 다음과 같이 해당 공유기에 연결합니다.
> sudo는 root(관리자) 권한으로 해당 명령을 실행할 때 사용합니다.  
>> 리눅스는 시스템 설정을 변경하려면 root 권한이 필요합니다.  
>> 처음 sudo가 포함된 명령을 실행하면 패스워드를 요구하는데, soda 계정의 패스워드인 soda를 입력합니다.  

- SerBot의 Wi-Fi 어댑터 이름은 **wlan0**이며, **device** 옵션으로 확인합니다.
  ```sh 
  nmcli device
  ```
- 연결 가능한 Wi-Fi 공유기를 찾을 때는 **wifi list** 옵션을 추가합니다.
  ```sh
  nmcli device wifi list
  ```
- **list** 대신 **connect \<이름\>** 및 **password \<패스워드\>** 옵션으로 해당 Wi-Fi 공유기에 연결합니다.
  ```sh
  sudo nmcli device wifi connect HBE_RSP password hanback91!
  ```
  > Wi-Fi 공유기 이름이 HBE_RSP, 패스워드는 hanback91!로 가정. (연결을 완료하는데 약간의 시간 필요)

- 성공적으로 공유기에 연결되면 ping 명령으로 인터넷에 연결되는지 확인합니다.
  ```sh
  ping www.google.co.kr
  ```  

최대화된 터미널창 크기를 원래 크기로 되돌리면 **Restore Panel Size** ① 를 선택합니다.
- **Kill Terminal** ② 은 현재 터미널을 종료합니다.
- **Splite Terminal** ③ 은 현재 터미널 창을 2개로 분할합니다.
- **Close Panel** ④ 은 터미널을 종료하지 않고 터미널 창을 포함한 패널을 닫습니다. 
  - 다시 터미널 창을 표시하려면 메뉴에서 **View > Terminal** ⑤ 을 선택합니다.

### 기존 패키지를 최신 버전으로 업그레이드
많은 오픈소스 패키지(라이브러리, 응용프로그램 등)가 미리 설치되어 있지만 시간이 지나면 이들의 업그레이드가 필요합니다.

패키지 관리자인 apt 명령을 이용해 다음과 같이 설치된 패키지들의 최신 버전이 있다면 업그레이드합니다.
- 배포 서버로부터 패키지 목록 업데이트
  ```sh
  sudo apt update
  ...
  Reading package lists... Done
  Building dependency tree       
  Reading state information... Done
  1 package can be upgraded. Run 'apt list --upgradable' to see it.
  ```
- 패키지 목록 업데이트 과정에서 업그레이드된 패키지가 있다면 최신 버전으로 업그레이드
  ```sh
  sudo apt -y upgrade
  ```

만약 패키지를 업그레이드할 때 마지막에 다음 오류가 표시되면 무시합니다.  
데비안 패키지와 엔비디아 L4T 패키지 사이 호환성 문제로 사용에는 문제가 없습니다.
> Errors were encountered while processing:  
>  nvidia-l4t-bootloader  
> E: Sub-process /usr/bin/dpkg returned an error code (1)  

### 파이썬 및 주피터 확장 설치
우리의 작업은 새로운 파이썬 또는 노트북 파일을 만든 후 SerBot에 내장된 파이썬 인터프리터나 주피터랩의 파이썬 커널을 통해 이를 실행합니다.
이때 원격 접속한 VSCode를 위해 SerBot에 파이썬과 주피터 확장을 설치하면 다음과 같은 장점이 있습니다.
- 파이썬 확장
  - 미리 파이썬 구문의 유효성 검사(Linting) 및 필요한 키워드나 함수, 클래스 또는 메소드 추천(InteliSense)을 지원합니다.
  - 코드 탐색(Navigation) 및 형식 맞춤(Formatting), 구조 변경(Refactoring) 지원합니다.
  - 실행 및 실시간 디버깅 지원합니다.
- 주피터 확장
  - 셀 단위로 구문을 작성하고 실행하는 주피터 환경 지원합니다.
    - 파이썬 확장 기능 포함합니다.
    - 이미지, 멀티미디어 렌더링 지원합니다.
    - 간단한 GUI 환경인 Widgets 지원합니다.
  - 파이썬 코드에서 직접 주피터 노트북처럼 셀 단위로 구분해 실행하는 환경 지원합니다.
    - 특별한 주석(#%%)으로 노트북 셀 구분합니다.
  
<br>

파이썬 및 주피터를 비롯해 파이썬 개발자들이 선호하는 다음 확장을 **Extensions**의 검색 상자를 통해 설치합니다.
> 현재 VSCode는 SerBot에 원격 접속된 상태이므로 대부분의 확장은 SerBot에 설치되지만 일부 확장은 PC에 설치됨

- **ms-python.python** 
  - Microsoft에서 배포하는 Python 공식 확장으로 상황에 따른 구문 추천 도우미인 Pylance도 함께 설치됩니다.
- **ms-toolsai.jupyter**
  - Microsoft에서 배포하는 Jupyter 공식 확장으로 Notebook Renderers, Slide Show, Cell Tags도 함께 설치됩니다.
  - Keymap은 PC에 설치되어 주피터 노트북의 단축키 정보를 VSCode에 연결합니다.
- **TabNine.tabnine-vscode**
  - 머신러닝 기반 코드 도우미로 서명을 하면 무료 사용이 가능합니다.
- **usernamehw.errorlens**
  - PC에 설치되며, 구문 오류가 발행한 줄 옆에 자세한 설명을 표시합니다.
- **KevinRose.vsc-python-indent**
  - PC에 설치되며, 파이썬 들여쓰기 시각화를 지원합니다.
- **PKief.material-icon-theme**
  - PC에 설치되며, 인기 있는 아이콘 테마 중 하나입니다.

TabNine 확장을 설치한 후 인증 창이 표시되면 **Sign In**  버튼 ① 을 누른 후 다음과 같이 진행합니다.
- 웹 브라우저에 TabNine 인증 페이지 ② 가 표시됩니다.
- 하단에서 본인과 관계된 계정 링크 ③ 중 하나를 선택해 인증합니다.
- 선택한 계정으로 인증이 끝나면 완료 페이지 ④ 가 표시됩니다.
</details>

<br>  

## 새 프로젝트
원격 접속한 VSCode와 SerBot에 설치한 확장을 이용해 SerBot 제어용 프로젝트를 만든 후 실행해 봅니다.

### 작업공간 선택
작업공간(Workspace)은 사용자가 프로젝트를 진행할 때 관련된 여러 소스 코드 파일과 리소스를 한데 모아 놓은 폴더입니다.  
파이썬 또는 노트북 파일로 SerBot 제어 프로그램을 작성하려면 먼저 작업공간을 선택해야 합니다.

VSCode에서 SerBot의 작업공간을 선택하는 방법은 다음과 같습니다.
- 사이드 바에서 **Explorer** ① 를 실행합니다.
- **Open Folder** ② 를 선택합니다.
- 폴더 선택창이 표시되면 /home/soda/Project/python 폴더 ③ 를 선택합니다.
  - 현재 VSCode는 SerBot에 원격 접속된 상태이므로 선택 경로는 SerBot의 리눅스 파일시스템 경로입니다.
- 패스워드 입력창이 표시되면 **soda** ④ 를 입력합니다.
- 선택한 폴더에 대한 신뢰성 확인이 표시되면 **Trust the authors of all files**와 **Yes, I trust the authors** ⑤ 을 선택합니다.

VSCode는 종료했다가 다시 시작해도 이전 작업공간을 자동으로 선택합니다. 만약 작업공간을 변경하려면 다시 새로운 폴더를 열어야 합니다.  
단, 작업공간이 선택된 상태에서는 **Explorer > Open Folder**를 사용할 수 없으므로 메뉴 **File** ① 에서 다음과 같이 선택합니다.
- **Open Folder** ② 로 새 폴더를 선택합니다.
  - 기존 폴더를 닫고 새 폴더를 작업공간으로 사용합니다.
- **Add Folder to Workspace** ③ 로 새 폴더를 추가합니다.
  - 기존 폴더를 닫지 않고 새로운 폴더를 추가하는 것으로 여러 폴더를 하나의 작업공간에 둘 수 있습니다.

### 새 파일 만들기
작업공간이 선택되면 파이썬 코드 작성을 위해 새 파일을 만드는데, 작업공간 루트 또는 새로 만든 하위 폴더 모두 가능합니다.  
확장자 **.py**는 파이썬 스크립트를, **.ipynb**는 주피터 노트북 파일을 의미합니다.  

**Explorer**에서 도구 모음 또는 팝업 메뉴(마우스 오른쪽 클릭)를 통해 다음과 같이 새 파일을 만들어 봅니다.
- **New Folder**를 선택한 후 폴더 이름으로 **basic** ① 을 입력합니다.
- basic 폴더를 선택한 상태에서 **New File**을 통해 **hello.py** 와 **hello.ipynb** ② 를 차례로 만듭니다. 
- 편집 영역에서 두 번째 만든 hello.ipynb의 탭을 마우스로 끌어 오른쪽 끝에 최대한 가깝게 놓으면 편집창이 분할 ③ 됩니다.
- hello.ipynb의 첫 번째 셀에 파이썬 구문을 입력하면 자동으로 코드를 추천 ④ 하며, 구문 오류가 있으면 설명 ⑤ 이 표시됩니다.
- hello.py도 동일하게 자동 코드 추천 및 구문 오류 설명 표시 기능을 사용할 수 있습니다.
  
편집창을 넓게 사용하기 위해 **Side bar**를 닫은 후 다음과 같이 앞서 만든 파일에 SerBot 주행과 관련된 구문을 추가합니다. 

```python
from pop.Pilot import SerBot
from time import sleep

bot = SerBot()

bot.setSpeed(80)
bot.forward()
bot.steering = 1.0
sleep(2)
bot.backward()
bot.steering = -1.0
sleep(2)
bot.steering = 0.0
bot.stop()
```
- 먼저 pop.Pilot 모듈의 SerBot 클래스와 time 모듈의 sleep 함수를 로드 ① 합니다.
  - pop에 포함된 모든 모듈은 한백전자에서 제공하며, time 모듈은 파이썬 표준입니다.
- SerBot 클래스로 Serbot 객체(인스턴스) ② 를 만듭니다.
- setSpeed()와 forward() 메소드로 속도는 80, SerBot을 전진 상태로 만든 후 steering 프로퍼티로 최대 오른쪽 회전 ③-1 시킵니다.
- time() 함수로 2초 대기합니다.
  - time() 함수에 소수점 인자를 사용하면 밀리초 단위 지연이 가능합니다.
- backward()로 SerBot을 후진 상태로 바꾸고, steering 프로퍼티로 SerBot을 최대 왼쪽으로 회전 ③-2 시킵니다.
- time() 함수로 2초 대기합니다.
- steering 프로퍼티로 SerBot 이동 방향을 중앙에 맞추고 stop() 메소드로 정지 ③-3 시킵니다.

주피터 노트북은 셀을 편집하는 셀 선택 모드와 해당 셀에 코드를 입력하는 코드 입력으로 나눠집니다.
- 주피터에서 셀 추가는 상단의 **+ Code** ⑥ 를 누릅니다.
  - 셀 제거는 **Del** 키를 누릅니다.

### 실행
코드 작성이 완료되었으면 파이썬 인터프리터 또는 주피터 커널을 이용해 실행합니다.
> SerBot 바퀴가 지면에 닫지 않도록 거치대(사각형 모양 박스) 위에 올려 놓고 실행할 것  

파이썬 스크립트(.py) 실행은 다음과 같습니다.
- 터미널을 실행(메뉴 > Terminal > New Terminal) 합니다.
- 자동 실행
  - 메뉴의 **Run** ① 에서 **Run Without Debugging** ② 또는 도구 모음의 **Run Python File** ③ 을 선택합니다.
  - 터미널에 자동으로 파이썬 인터프리터와 스크립트 파일 경로가 자동으로 입력되어 실행됨.
- 수동 실행 (권장)
  - 터미널에서 사용자가 직접 **파이썬 인터프리터와 스크립트 파일 경로를 입력** ④ 해 실행합니다.
  - 현재 폴더와 파이썬 스크립트 파일 위치를 고려해 경로를 입력합니다.

주피터 노트북(.ipynb)은 다음과 같이 창에 표시된 도구를 이용해 실행합니다.
- 셀 왼쪽 옆의 **Excute cell** ① 을 누르면 현재 셀이 실행됩니다.
- 헤더의 **Run All** ② 를 누르면 전체 셀이 실행됩니다.
- 셀 오른쪽 도구 모음에서 **Excute Above Cells** 또는 **Excute Cell and Below**** ③ 를 선택하면 현재 셀과 위 또는 아래 모든 셀을 실행합니다.
  - **Excute Above Cells**는 첫 번째 셀부터 현재 셀 전까지 차례로 실행합니다.
  - **Excute Cell and Below****는 현재 셀부터 마지막 셀까지 차례로 실행합니다.
- 오랜 시간 실행되는 셀을 강제 종료하려면 헤더의 **Restart** ② 를 눌러 파이썬 커널을 다시 시작합니다.
  - 실행과 관련된 셀을 처음부터 다시 시작해야 합니다.
  
주피터 노트북은 셀을 관리하는 선택모드와 코드를 입력하는 입력모드로 나눠지는데, 다음은 주피터 노트북의 유용한 단축키 모음입니다.
- 공통
  - \<Ctrl\> + \<Enter\>: 현재 셀을 실행합니다.
  - \<Shift\> + \<Enter\>: 현재 셀을 실행하고, 다음 셀로 커서를 옮깁니다. 만약 다음 셀이 없다면 새로 추가합니다.
- 선택모드
  - A: 현재 셀 위에 새로운 셀을 추가합니다.
  - B: 현재 셀 아래에 새로운 셀을 추가합니다.
  - DD: 현재 셀을 삭제합니다.
  - M: 현재 셀을 코드에서 마크다운으로 변경합니다.
  - Y: 현재 셀을 마크다운에서 코드로 변경합니다.
  - C: 현재 셀을 복사합니다.
  - V: 복사한 셀을 붙여 넣습니다.
  - X: 현재 셀을 잘라냅니다.
- 입력모드
  - VScode의 편집 단축키를 그대로 사용합니다.
<br>  
  
### VSCode 원격 실행 정리
지금까지 PC와 SerBot을 TCP/IP 네트워크로 연결한 후 VSCode 원격 개발환경을 통해 코드를 작성하는 과정을 알아보았습니다.  
이런 원격 개발환경을 사용하면 실제 모든 작업은 SerBot에서 이뤄지고, PC는 SerBot의 터미널(원격 표준 입출력) 역할만 수행합니다.  
물론 VSCode 자체는 PC에서 실행되지만, SerBot에 설치된 VS Code Server를 통해 VSCode에서 수행하는 모든 작업이 SerBot에서 반영됩니다.  
따라서 PC 성능은 VSCode를 실행할 정도면 충분합니다.  

다음은 VSCode의 원격 실행 과정입니다.
- PC에는 ssh 클라이언트가 설치되어 있어야 합니다.
  - Mac과 리눅는 기본 설치되어 있습니다.
  - 윈도우 10 이상(22H2)부터 C:/Windows/System32/OpenSSH 폴더에 ssh.exe가 위치합니다.
- VSCode에 ssh 확장을 설치합니다.
  - VSCode에서 PC의 ssh 클라이언트를 사용하는데 필요합니다.
- SerBot의 SSH 연결 정보 파일을 만든 후 이를 이용해 SerBot에 접속합니다.
  - PC의 홈 폴더에는 SSH 연결을 관리하는 .ssh 폴더가 위치하며 이 곳에 .config 파일이 만들어 집니다.
  - .config 파일에 포함되는 내용은 레이블 및 SerBot의 IP 주소와 계정 ID입니다.
- 처음 SerBot에 원격 접속하면 자동으로 VSCode 버전에 맞는 VSCode Server를 인터넷에서 PC로 다운로드해 SerBot에 설치합니다.
  - VSCode 버전이 바뀔 때마다 자동으로 VSCode Server가 설치됩니다.

</details>

## SerBot API

### 기본 제어
```python
from pop.Pilot import SerBot

bot = SerBot()
```

**전/후진 및 조향**
```python
bot.setSpeed(speed)   # 0 ~ 99 사이 속도 설정
bot.forward([speed])  # 전진 (속도 옵션)
bot.backward([speed]) # 후진 (속도 옵션)
bot.steering = value  # 왼쪽(-1.0) ~ 오른쪽(1.0) 방향 전환
```

**해당 방향으로 이동**
```python
bot.move(degree, speed)
```

**정지**
```python
bot.stop()
```
```python
bot.setSpeed(0)
```

### IMU 센서 
**라이브러리 수정**
TODO

**Jupyter에서 센서값 읽기 테스트**
---
```python
import time
import ipywidgets as widgets
from threading import Thread
```
---
```python
delay = widgets.IntSlider(max=1000, value=1, description='delay')
gyro = [widgets.FloatSlider(min=-90, max=90, description='gyro_'+s) for s in ('x', 'y', 'z')] #degree/s
accel = [widgets.FloatSlider(min=-12, max=12, step=0.01, description='accel_'+s) for s in ('x', 'y', 'z')] #m/s^2
display(delay)
for i in range(3):
    display(gyro[i])
for i in range(3):   
    display(accel[i])
```
---
```python
is_imu_thread = True

from pop.Pilot import IMU
imu = IMU()

def onReadIMU():
    while is_imu_thread:
        gyro[0].value, gyro[1].value, gyro[2].value = imu.getGyro().values()
        accel[0].value, accel[1].value, accel[2].value = imu.getAccel().values()

        time.sleep(delay.value/1000)

Thread(target=onReadIMU).start()
```
---
```python
is_imu_thread = False
```

### 라이다

```python
from pop.LiDAR import Rplidar

lidar = Rplidar()
```

**시작**
```python
lidar.connect()
lidar.startMotor()
```

**포인터 프레임을 벡터로 읽기 읽기**
```python
vectors = lidar.getVectors()
for v in vectors:
    print(v)
```

**포인터 프레임을 코디네이터로 읽기**
```python
coords = lidar.getXY()
for c in coords:
    print(c)
```

**종료**
```
lidar.stopMotor()
```

**시각화**
- 윈도우용 X-Server 설치
  - [Vcxsrv](https://sourceforge.net/projects/vcxsrv/files/latest/download)
  - 설정
    - `Extra settings > Disable access control (Check)`
- 원격 실행
  -  DISPLAY=192.168.101.120:0 ***GUI_Program***  

```python
from pop.LiDAR import Rplidar
import matplotlib.pyplot as plt
import numpy as np
import cv2

lidar = Rplidar()
lidar.connect()
lidar.startMotor()

fig = plt.figure(figsize=(12.8, 7.2), dpi=100)
ax = fig.add_subplot(111, projection='polar')
fig.tight_layout()

dist = 5000 #5m

while True:
    V = np.array(lidar.getVectors(True))
    V = np.where(V <= dist, V, 0)
    ax.plot(np.deg2rad(V[:,0]), V[:,1])
    fig.canvas.draw()

    cv2.imshow("lidar", np.array(fig.canvas.renderer._renderer))
    plt.cla()
    ax.set_theta_zero_location("N")

    if cv2.waitKey(10) == 27:
        break

lidar.stopMotor()
cv2.destroyAllWindows()
```
