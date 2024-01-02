# PC에 파이썬 IoT 개발환경 구축
- 기존 VSCode (특히 Setup으로 설치한)는 삭제할 것

## VSCode는 포터블 모드 설치
최신 버전(https://code.visualstudio.com/docs/?dv=winzip)
> .zip x64
- unzip to C:\VSCode
- make to C:\VSCode\data

## 파이썬 SDK(V3.xx) 설치
최신 버전(https://www.python.org/downloads/windows/)
>  Windows embeddable package (64-bit)
- unzip to C:\VSCode\ext\python

## 파이썬 패키지 경로(Lib/site-packages) 추가
- edit to C:\VSCode\ext\python\python3xx._pth
  ```sh
  python3xx.zip
  .
  Lib/site-packages
  # Uncomment to run site.main() automatically
  #import site
  ```
  
## 파이썬 패키지 관리자(pip) 설치
부트스트립 최신 버전(https://bootstrap.pypa.io/get-pip.py)
- download **get-pip.py** to C:\VSCode\ext\python 
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

## 파이썬 패키지(라이브러리) 설치
```sh
pip install numpy
pip install matplotlib
pip install paho-mqtt
```

- 모든 파이썬 패키지를 최신 버전으로 업그레이드 (PowerShell)
  ```sh
  pip freeze | %{$_.split('==')[0]} | %{pip install --upgrade $_}
  ```

## VSCode 확장 설치
### 확장
- python, jupyter, Remote - SSH
- Tabnine, Error Lens, indent-rainbow
- vscode-icons, Ayu, One Dark Pro
