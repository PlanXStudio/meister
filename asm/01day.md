# PC에 파이썬 IoT 개발환경 구축
> 시스템 의존성과 저장소 낭비를 최소화해 설치.
>> IoT 뿐만 아니라 인공지능과 같은 다른 파이썬 개발환경에서도 사용.

## VSCode 포터블 설치
1. 윈도우용 최신 버전 다운로드:  https://code.visualstudio.com/docs/?dv=winzip
   - VSCode-win32-x64-x.y.z.zip (x, y, z는 버전 번호)
2. C 드라이버 루트 경로(C:\)에 압축 해제
   - 바탕화면은 권장하지 않음.
3. 탐색기에서 C:\를 탐색한 후 폴더명을 **VSCode**로 변경 (이하 VSCode 루트)
4. VSCode 루트 경로에 data 폴더 생성 (C:\VSCode\data)
   - data 폴더에는 사용자가 설치한 확장 기능 및동적 데이터가 저장됨

## 파이썬3 SDK 설치
1. 최신 버전(https://www.python.org/downloads/windows/)
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
