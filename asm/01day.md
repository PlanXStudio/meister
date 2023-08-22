# PC에 파이썬 IoT 개발환경 구축
- 기존 VSCode (특히 Setup으로 설치한)는 삭제할 것

## VSCode는 포터블 모드 설치
최신 버전(https://code.visualstudio.com/)
> .zip x64
- unzip to C:\VSCode
- make to C:\VSCode\data

## 파이썬 SDK(V3.11) 설치
최신 버전(https://www.python.org/downloads/windows/)
>  Windows embeddable package (64-bit)
- unzip to C:\VSCode\ext\python
- edit python311._pth
```sh
python311.zip
.
Lib/site-packages
# Uncomment to run site.main() automatically
#import site
```

## pip 설치
최신 버전(https://bootstrap.pypa.io/get-pip.py)
- download get-pip.py
```sh
python get-pip.py
```
- (옵션) 업그레이드
```sh
python -m pip install --upgrade pip
```

## 시스템 환경변수 path 추가
```sh
sysdm.cpl ,3
```

- C:\VSCode\ext\python
- C:\VSCode\ext\python\Scripts

## 라이브러리 설치
```sh
pip install numpy
pip install matplotlib
pip install paho-mqtt
```

## VSCode 확장 설치
### 확장
- python
- jupyter
- 
### 사전 설치
- [다운로드](https://koreaoffice-my.sharepoint.com/:u:/g/personal/devcamp_korea_ac_kr/EZFiLtxjxUNPnU_BpYpcMb8B6HjtxIytgNjTA1Tw6eP0eA?e=Uyv6br)
