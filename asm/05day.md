# CLI 기반 실습을 위한 명령프롬프트(쉘) 명령 이해

## 윈도우,리눅스 명령어 비교
|구분|Windows (cmd)| Windows (pwsh) | Linux|
|----|-------|-------|-----|
|파일 분류 이름공| 폴더 | 폴더 | 디렉토리|
|파일복사|	copy|	cp | cp|
|파일 이동|	move|	mv | mv|
|파일 목록보기|	dir|	ls | ls|
|파일 삭제|	del, erase|	rm | rm|
|이름 변경|	move|	mv | mv|
|디렉토리 이동|	cd|	cd | cd|
|현재 디렉토리|	cd|	pwd | pwd|
|화면 정리|	cls|	clear | clear|
|명령어 해석기|	command.com|	pwsh.exe | sh, csh, bash, zsh|
|파일 내용 표시|	type|	cat | cat|
|도움말, 메뉴얼|	help|	help | man|
|종료|	exit|	exit | exit|
|시간 표시|	time|	date | date|
|환경변수 표시|	set| set, env | set, env|
|파일 문자열 찾기|	find|	find | find|
|2개 파일 비교|	fc, comp|	diff | diff|
|문자열, 라인별 정력|	sort|	sort | sort|
|하위 디렉토리 복사|	xcopy|	cp -Recurse | cp -r|
|호스트 명|	hostname|	hostname | hostname|
|프로세스 정보|	taskmgr|	ps | ps, top|
|프로세스 종료|	tskill|	kill | kill, killall|
|시스템 종료|	shutdown|	shutdown | shutdown, halt, init 0|
|ip표시|	ipconfig|	ipconfig | ifconfig|
|ping| ping|	ping  | ping|

## 실습 과제
### 파일 유형
- 텍스트 파일
- 바이너리 파일

### 파일 구분
- 일반
- 폴더/디렉토리
- 숨김
- 특수 파일(리눅스)

### 파일 권한(리눅스)
- 읽기(r)
- 쓰기(w)
- 실행(x)

### 파일 소유자/그룹/기타
- 관리자
- 일반

### 경로
- 경로 구분 문자: /
- 절대 경로
- 상대 경로
  - .
  - ..
- 기타
  - 루트 폴더/디렉토리
  - 홈 폴더/디렉토리
  - 현재 폴더/디렉토리
  - 작업 폴더/디렉토리/작업공간
    
### 폴더/디렉토리 생성 및 변경, 이동, 삭제
- mkdir
- cd
- mv
- rm

### VSCode의 터미널 연계
- 작업공간
- 하위 폴더 생성
- 하위 폴더에 파이썬 소스 생성
- 파이썬 코드 실행

## Tutorial
[Linux 101 학습 문서 다운로드](https://koreaoffice-my.sharepoint.com/:b:/g/personal/devcamp_korea_ac_kr/EdckMnQG59VNqr1iV954x9cBx_KDmaFLW0Kpf7qNUal7ag?e=YpWWku)

## Work Linux
- WSL2 V2.0(https://github.com/microsoft/WSL/releases/download/2.0.0/wsl.2.0.0.0.x64.msi)
  - 다운받은 wsl.x.y.z.msi 설치
  - WSL 하위 시스템 설치 (온라인 리눅스 배포판 제외) 
  ```sh
  wsl --install --no-distribution
  ```
  
- [Ubuntu-22.04 커스텀 버전 다운로드](https://koreaoffice-my.sharepoint.com/:u:/g/personal/devcamp_korea_ac_kr/EYBrZMC3uEJBqirmRD1inBsBvNz6N3-prbNWJ114N6XMOQ?e=hgEO7M)
  - 다운받은 Tos2의 압축을 해제한 후 홈 디렉토리로 복사
  - 홈 디렉토리에서 배포판 설치
    ```sh
    mkdir WSL/Tos2
    wsl --import Tos2 WSL/Tos2 Tos2.tar
    ```
  - 기본 설정된 ID와 Password는 각각 tos, tos    
