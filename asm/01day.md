# PC에 파이썬 IoT 개발환경 구축
> 윈도우 운영체제 기준으로 시스템 의존성과 저장소 낭비를 최소화해 설치.
>> IoT 뿐만 아니라 인공지능과 같은 다른 파이썬 개발환경에서도 사용.

[참고] [VSCode.zip 사전 설치 다운로드(2024.01.02)](https://1drv.ms/u/s!AtTAtBZJQ9JFlI8GyI66XPOQfrE2kA?e=L8fXtS)

## VSCode 포터블 설치
1. 윈도우용 최신 버전 다운로드:  https://code.visualstudio.com/docs/?dv=winzip
   - VSCode-win32-x64-x.y.z.zip (x, y, z는 버전 번호)
2. C 드라이버 루트 경로(C:\\)에 압축 해제
   - 바탕화면은 권장하지 않음.
3. 탐색기에서 C:\를 탐색한 후 폴더명을 **VSCode**로 변경 (이하 VSCode 루트)
4. VSCode 루트에 data 폴더 생성 (C:\VSCode\data)
   - data 폴더에는 사용자가 설치한 확장 기능 및 동적 데이터가 저장됨

## 파이썬3 임베디드 SDK 설치
> 파이썬 SDK는 파이썬 인터프리터와 표준 라이브러리로 구성
>> 임베디드 버전은 VSCode와 같은 개발환경을 위해 IDE나 pip, tkinter(GUI 라이브러리) 등은 생략하고 꼭 필요한 핵심 라이브러리만 제공함

1. 윈도우용 V3.11.x 버전 다운로드: https://www.python.org/ftp/python/3.11.7/python-3.11.7-embed-amd64.zip
   - python-3.11.7-embed-amd64.zip (embed는 Embeddable package의 약자로 꼭 필요한 기능만 제공)
   - 이 보다 최신 버전(예: 3.12.x)은 다른 라이브러리를 사용할 때 호환성 문제가 발생할 수 있음
2. VSCode 루트에 ext 폴더 생성 (C:\VSCode\ext) 
3. ext 폴더에 다운받은 파이썬 SDK 압축 해제
4. 탐색기를 이용해 폴더명을 **python**로 변경 (이하 python 루트)
   - C:\VSCode\ext\python 
5. 외부 패키지(라이브러리) 설치 경로를 지정하기 위해 메모장에서 python 루트의 python311._pth 파일 열기
6. 다음과 같이 열린 내용에 **Lib/site-packages** 추가 후 저장
  ```sh
  python311.zip
  .
  Lib/site-packages
  # Uncomment to run site.main() automatically
  #import site
  ```
  
## 파이썬 패키지 관리자(pip) 설치
> 패키지는 라이브러리의 일종으로 모듈로도 불리며, pip는 일반적으로 pypi.org를 통해 배포되는 외부 라이브러리

1. 부트스트립 최신 버전 얻기: https://bootstrap.pypa.io/
   - 부트스트립은 실행 파일 안에 실행 환경(운영체제 버전, 실행 경로)을 내장해 더 빠른 실행 보장
   - 시스템 의존성을 줄이려면 부트스트립된 pip.exe보다 pip 모듈 사용 권장 (python -m pip ...)
3. 목록에서 get-pip.py를 우클릭 후 컨텍스트 메뉴가 표시되면 **다른 이름으로 링크 저장** 선택
4. 다른 이름으로 저장 창이 표시되면 python 루트 선택
   - C:\VSCode\ext\python\get-pip.py
5. CLI(명령 프롬프트 또는 파워쉘)을 실행한 후 현재 경로를 python 루트로 변경한 후 pip 설치
   ```sh
   cd C:/VSCode/ext/python
   python ./get-pip.py
   ```
   - pip 및 wheel 패키지(라이브러리)와 실행 파일이 다운로드됨
     - 패키지는 python 루트의 Lib/site-packages 폴더에 위치
     - 실행 파일은 python 루트의 Scripts 폴더에 위치

## 필수 패키지 설치
> 파이썬은 표준 라이브러리 수준의 외부 패키지(라이브러리)가 다수 존재함

0. 환경변수 path에 python 루트 경로를 추가할 때까지는 python 루트에서 CLI 명령 실행
```sh
cd C:/VSCode/ext/python
```

1. 데이터 처리 및 시각화
```sh
python -m pip install numpy
python -m pip install matplotlib
python -m pip install pandas
```

2. PC 마우스/키보드 자동화
```sh
python -m pip install pyautogui
```

3. 마이크로파이썬
```sh
python -m pip install xnode
```

3. 영상처리
```sh
python -m pip install mediapipe
python -m pip install cvzone
```

4. 설치된 패키지를 최신 버전으로 업그레이드
  ```sh
  pip freeze | %{$_.split('==')[0]} | %{pip install --upgrade $_}
  ```

## 코딩 폰트 다운로드 및 설치
> 코딩에 최적화된 폰트를 사용하면 소스 코드를 편집할 때 가독성이 높아짐.

1. 달서힐링체: https://gongu.copyright.or.kr/gongu/wrt/wrt/view.do?wrtSn=13304361&menuNo=200023
   - DalseoHealingMedium.ttf
2. 젯브레인 모노 NF: https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip
   - JetBrainsMonoNerdFont-*.ttf만 압축 해제
3. 다운받은 모든 .ttf를 선택한 후 우클릭, 메뉴가 표시되면 **설치** 선택

## VSCode 실행 및 Extensions 설치
> VSCode는 Extensions을 통해 기능을 확장함.
>> MS는 VSCode Extensions 인터넷 저장소를 통해 전세계 개발자가 오픈소스로 개발한 Extensions 배포.
>> VSCode를 파이썬 통합개발환경으로 사용하려면 해당 Extensions 설치 필요.

1. 탐색기를 이용해 VSCode 루트에서 Code.exe 더블클릭
2. 왼쪽 Activity Bar에서 Extensions 선택
3. 상단 검색란에 해당 이름을 검색해 설치
   - Python
   - Jupyter
   - Python Indent
   - Remote - SSH
   - Tabnine
   - Error Lens
   - Bookmarks
   - Material Icon Theme
   - Project Manager
   - Outline Map
   - One Dark Pro
   - Ayu
   - Korean Language Pack
     - 언어 변경: F1 > configure display language 입력 후 선택 > 변경할 언어 선택
4. 단축키 \<Ctrl\>+, 를 눌러 Settings 표시
   - 파일 자동 저장: Commonly Used > Files: Auto Save > onFocusChange
   - 폰트 설정: Commonly Used > Editor:Font family > 'JetBrainsMono Nerd Font', DalseoHealing
   - 마우스 휠로 폰트 확대/축소: 상단 검색란에 "wheel" 입력 > Editor: Mouse Sheel Zoom 체크
5. 메뉴 > View > Appearance 클릭
   - Minimap 체크 해제
   - Secondary Side Bar 체크
   - 오른쪽 Secondary Side Bar에 Activity Bar의 Outline map Exension을 끌어다 놓기

## python 루트 및 외부 모듈 실행 파일 경로를 사용자 환경변수 path에 추가
> CLI에서 현재 경로가 어디든 관계없이 python 또는 pip 명령을 실행하려면 환경변수 path에 해당 프로그램의 경로가 등록되어 있어야 함
>> 환경변수 path를 수정하면 기존 CLI를 종료한 후 다시 실행해야 함
 
1. 제어판의 시스템 속성 애플릿을 실행하기 위해 CLI 또는 윈도우 검색 창에서 다음 명령 실행 
   ```sh
   sysdm.cpl
   ```
2. 시스템 속성 창이 표시되면 고급 탭을 선택한 후 **환경 변수** 선택
3. 상단 "<login>에 대한 사용자 변수" 목록에서 Path 항목을 찾아 더블클릭
4. 목록 아래 빈 칸을 더블클릭한 후 다음 내용을 차례로 입력
   ```sh 
   C:\VSCode\ext\python
   ```
   ```sh 
   C:\VSCode\ext\python\Scripts
   ```   
5. 추가한 2개 항목을 왼쪽 "위로 이동" 버튼을 이용해 목록 가장 앞으로 이동 
   ```sh
   C:\VSCode\ext\python
   C:\VSCode\ext\python\Scripts
   %USERPROFILE%\AppData\Local\Microsoft\WindowsApps
   ...
   ```
