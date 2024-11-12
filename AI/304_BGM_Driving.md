# 배경 음악과 함께 로봇 이동

## 절전 모드 비활성화
절전 모드에서는 화면 꺼짐이나 **오디오 출력 멈춤**, 네트워크 연결 해제와 같은 문제가 발생할 수 있습니다.
또한 x 서버에는 에너지 절약(DPMS), 화면 보호기, 비디오 장치 비우기 같은 기능이 제공되어 일정 시간이 지나면 빈 화면으로 바뀜니다.
따라서 절전 모드 서비스 제거와 함께 다음과 같이 X 서버의 해당 기능도 비활성해야 합니다.

- xset -dpms: X.org의 에너지 절약(DPMS) 기능 비활성화
- xset s off: X.org의 화면 보호기 비활성화
- xset s noblank: X.org의 비디오 장치를 빈 상태로 만들지 못하도록 함

1. 절전 모드와 관련된 서비스를 비활성화합니다.
```sh
sudo systemctl disable sleep.target suspend.target hibernate.target hybrid-sleep.target
sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
```

2. vi로 /etc/X11/openbox 경로의 autostart를 엶니다.
```sh
sudo vi /etc/X11/openbox/autostart 
```

3. 맨 앞의 #을 지우고 다음 내용을 입력합니다.
```sh
xset -dpms s off s noblank
```

4. vi를 종료한 후 시스템을 다시 시작합니다.
```sh
sudo shutdown -r now
```

## 오디오
오디오 인터페이스에서 출력을 싱크(sink), 입력을 소스(source)라 하는데, 일반적으로 싱크에는 스피커가, 소스는 마이크가 연결됩니다. 
소스 데이터를 바로 싱크로 내보내는 것을 loopback이라 하며, 소스 데이터는 아날로그 신호이므로 이를 디지털로 변환하는 절차가 필요한다. 가장 기본적인 형식 중 하나가 PCM(Pulse Code Modulation)입니다.  

PCM은 오디오 데이터를 일정한 시간 간격으로 샘플링하고 양자화한 후, 각 샘플의 진폭을 디지털 값으로 변환합니다. 이 과정에서 압축을 하지 않기 때문에 원래의 음질을 유지하지만, 파일 크기가 큽니다. PCM 데이터의 품질은 샘플링 주파수(1초당 샘플 수)와 비트 깊이(샘플당 비트 수)에 따라 결정되며, CD 품질의 오디오는 44.1kHz 샘플링 주파수와 16비트 깊이를 사용합니다. PCM 데이터는 다양한 파일 형식으로 저장될 수 있으며, 대표적인 형식으로는 WAV와 AIFF가 있습니다.  
MP3는 PCM 데이터를 손실 압축하는 방법 중 하나로 불필요하거나 인간의 귀에 잘 들리지 않는 주파수를 제거하여 데이터 크기를 줄입니다. 하지만 손실된 데이터 때문에 음질에 영향을 미칠 수 있습니다. 

### ALSA와 사용자 계층 패키지
리눅스는 커널 수준에서 오디오 하드웨어를 직접 제어하고 관리하는 ALSA(Advanced Linux Sound Architecture)를 저수준 인터페이스로 제공합니다.

커널에서 인식한 오디오 카드는 다음 명령으로 확인합니다.

```sh
cat /proc/asound/cards
```
```out
 0 [tegrahda       ]: tegra-hda - tegra-hda
                      tegra-hda at 0x70038000 irq 83
 1 [tegrasndt210ref]: tegra-snd-t210r - tegra-snd-t210ref-mobile-rt565x
                      tegra-snd-t210ref-mobile-rt565x
 2 [ArrayUAC10     ]: USB-Audio - ReSpeaker 4 Mic Array (UAC1.0)
                      SEEED ReSpeaker 4 Mic Array (UAC1.0) at usb-70090000.xusb-2.4.4, full speed
```

리눅스는 사용자 공간에서 ALSA를 좀 더 쉽게 사용할 수 있도록 alsa-lib과 alsa-utils 패키지를 제공합니다.  
alsa-lib는 ALSA 시스템 호출을 추상화한 ALSA 라이브러리가 포함되어 있고, alsa-utils은 alsa-restore 서비스와 오디오 장치 정보 확인, 볼륨 조절, 재생, 녹음 등을 위한 명령줄 도구인 alsamixer, aplay, arecord 등이 포함되어 있습니다.

다음은 ALSA와 관련된 폴더와 파일입니다.

- /etc/alsa: ALSA 전역 설정 파일 위치
  - alsa.conf: 오디오 장치의 기본 설정, 샘플 레이트, 버퍼 크기 등을 지정
  - conf.d: 다양한 오디오 장치 및 설정에 대한 추가적인 설정 파일 위치
- /usr/lib/aarch64-linux-gnu: ALSA 라이브러리 파일 위치
  - libasound.so.2.0.0: 기본 ALSA 라이브러리로 응용프로그램에서 ALSA API를 사용할 수 있도록 지원 
  - libasound.so, libasound.so.2: libasound.so 파일의 심볼릭 링크
- /usr/lib/aarch64-linux-gnu/alsa-lib: ALSA 플러그인 파일 위치
  - libasound_module_pcm_upmix.so: 스테레오(2채널) 오디오를 5.1채널 서라운드 사운드로 변환하는 것과 같은 업믹싱 기능 적용
  - libasound_module_rate_samplerate.so: 서로 다른 샘플 레이트를 가진 오디오 신호를 변환하는 데 사용
  - libasound_module_pcm_pulse.so: ALSA가 PulseAudio를 통해 오디오를 출력하고 입력할 수 있도록 연결 해줌
  - libasound_module_conf_pulse.so: ALSA 설정 파일(/etc/asound.conf)에서 PulseAudio 서버의 주소, 포트 번호 등을 지정하여 ALSA가 PulseAudio에 연결하도록 설정
  - libasound_module_ctl_pulse.so: alsamixer와 같은 ALSA 제어 도구를 사용하여 PulseAudio의 볼륨, 음소거 등을 조절

### PulseAudio 설정
PulseAudio는 사용자 공간에서 ALSA 라이브러리를 이용해 커널의 ALSA와 통신하면서 여러 응용프로그램의 오디오 스트림을 믹싱하고, 볼륨 조절, 오디오 장치 전환 등을 수행하는 범용 오디오 서버입니다.  
PulseAudio 서버는 사용자가 직접 실행하거나 systemd 서비스로 실행 가능한 상태를 만든 후 응용프로그램의 요청을 받으면(소켓 활성화) 자동으로 실행되도록 할 수 있습니다.  
serbot은 pulseaudio 패키지의 기본값인 드 번째 방법을 사용합니다.  

**유닛 파일**
pulseaudio 패키지에는 systemd를 위한 유닛 파일이 포함되어 있습니다.

- pulseaudio.service
```sh
[Unit]
Description=Sound Service
Requires=pulseaudio.socket
ConditionUser=!root

[Service]
ExecStart=/usr/bin/pulseaudio --daemonize=no --log-target=journal
LockPersonality=yes
MemoryDenyWriteExecute=yes
NoNewPrivileges=yes
Restart=on-failure
RestrictNamespaces=yes
SystemCallArchitectures=native
SystemCallFilter=@system-service
# Note that notify will only work if --daemonize=no
Type=notify
UMask=0077

[Install]
Also=pulseaudio.socket
WantedBy=default.target
```

- pulseaudio.socket
```sh
Description=Sound System
ConditionUser=!root

[Socket]
Priority=6
Backlog=5
ListenStream=%t/pulse/native

[Install]
WantedBy=sockets.target
```

해당 유닛 파일의 ConditionUser=!root 항목을 통해 root가 아닌 일반 사용자 권한으로 PulseAudio 서비스를 시작하고, 응용프로그램이 사용하려고 소켓이 활성화되면서 자동으로 PulseAudio 서버가 시작됩니다.

**오디오 설정**
사용자는 설정 파일을 통해 PulseAudio 서버의 시작을 제어합니다. /etc/pulse에는 시스템 전체 설정이, ~/.config/pulse에는 현재 사용자에 대한 설정이 위치하는데, 만약 두 위치에 같은 설정 파일이 있고 해당 항목에 대해 값이 다르면 ~/.config/pulse에 위치한 파일 내용을 따릅니다.  

다음은 설정 파일과 주요 내용입니다. 

- client.conf: 클라이언트가 PulseAudio를 요청할 때 동작 설정
  - autospawn: 클라이언트 요청에 따라 오디오 서버 자동 실행. no는 자동 실행 안함 (디폴트는 yes로 자동 실행)
  - default-sink, default-source: 기본 오디오 출력, 입력 장치 지정
- daemon.conf: PulseAudio 동작 설정
  - resample-method: 오디오 리샘플링 알고리즘 지정
  - deafult-sample-format, default-sample-rate: 기본 오디오 샘플 형식, 샘플링 속도 지정
  - realtime-scheduling: 실시간 스케쥴링 활성화 유무 지정
- default.pa: PulseAudio가 시작될 때 로드되는 기본 설정 스크립트
  - 모듈 로드, 소스 및 싱크 설정, 오디오 라우팅 규칙 정의 등 PulseAudio의 전반적인 동작 지정
_ system.pa: default.pa 다음에 로드되는 설정 스크립트
  - 시스템 관리자는 PulseAudio의 동작을 전역적으로 제어하기 위해 사용
  - 일반적으로 시스템 수준의 오디오 설정을 정의하거나 특정 하드웨어에 대한 설정을 추가하는 데 사용

serbot2는 HDMI 오디오를 기본 싱크로, ReSpeaker를 기본 소스로 설정합니다. 따라서 default.pa의 마지막 줄은 다음과 같이 설정되어 있습니다.
```sh
tail -n2 /etc/pulse/default.pa
```
```out
set-default-sink alsa_output.platform-3510000.hda.hdmi-stereo
set-default-source alsa_input.usb-SEEED_ReSpeaker_4_Mic_Array__UAC1.0_-00.multichannel-input
```

만약 오디오 설정을 변경했다면, 시스템을 다시 시작합니다.
```sh
sudo shutdown -r now
```

**~/.config/pulse**
사용자가 오디오 응용프로그램을 실행하면, ~/.config/pulse에 포함된 다음과 같은 파일을 통해 PulseAudio에 접근합니다.

- cookie: 바이너리 파일로 응용프로그램(클라이언트)이 PulseAudio(서버)에 접근할 때 필요한 권한 포함
- \<instance_id>-card-database.tdb: 바이너리 파일로 사운드 카드 및 오디오 장치에 대한 정보
  - 사운드 카드의 이름, 프로파일, 지원하는 샘플 레이트, 입출력 포트 등의 정보가 포함됨
  - PulseAudio는 이 정보를 사용하여 오디오 장치를 인식하고 설정
- \<instance_id>-default-sink: 텍스트 파일로 기본 오디오 출력 장치 정보
  - default.pa 또는 system.pa에 저장된 set-default-sink 값
- \<instance_id>-default-source: 텍스트 파일로 기본 오디오 입력 장치 정보
  - default.pa 또는 system.pa에 저장된 set-default-source 값
- \<instance_id>-device-volumes.tdb: 바이너리 파일로 각 오디오 장치의 매스터 볼륨, 밸런스, 페이드 등 설정 정보가 포함됨
- \<instance_id>-stream-volumes.tdb: 바이너리 파일로 각 응용프로그램별 볼륨, 음소거 설정 정보가 포함됨

~/.config/pulse는 처음 응용프로그램이 PulseAudio에 연결될 때 자동으로 생성되며, 이후 설정에 따라 파일 내용이 변경됩니다.  
따라서 만약 이 폴더를 삭제하면, 모든 설정이 초기화 됩니다.

### 오디오 테스트
PluseAudio 설정이 완료되면 소스 데이터를 녹음하고, 오디오 파일 재생을 통해 오디오 입출력을 테스트합니다.   
앞서 alsa-utils 패키지를 제거했으므로 SoX 패키지를 설치한 후 진행합니다.  

**SoX 설치**
SoX(Sound eXchange)는 명령줄 기반의 다재다능한 오디오 처리 도구로 다양한 파일 형식 변환, 효과 적용, 오디오 분석 등의 작업을 수행할 수 있습니다.  

1. sox 패키지를 설치합니다.
```sh
sudo apt install sox
```

2. MP3 인코딩을 지원을 위해 libsox-fmt-mp3도 함께 설치합니다.  
```sh
sudo apt install libsox-fmt-mp3
```

3. AUDIODRIVER 환경 변수를 이용해 기본 드라이버를 ALSA로 지정합니다.
```sh
echo -e 'export AUDIODRIVER=alsa' | tee -a ~/.zshrc
```

4. zshrc를 소싱합니다.
```sh
source ~/.zshrc
```

**녹음하고 재생하기**
녹음은 오디오 장치에서 PCM 데이터를 읽어 WAV 파일로 저장하는 과정이고, 재생은 WAV 파일을 PCM 데이터로 변환하여 오디오 장치에 출력하는 과정입니다.
SoX는 WAV 외에 FLAC, MP3, Ogg Vorbis 등 다양한 오디오 파일 형식을 지원합니다. 파일 확장자를 변경하여 원하는 형식으로 저장할 수 있습니다.

1. 싱크와 소스 볼륨을 설정합니다. @DEFAULT_SINK@와 @DEFAULT_SOURCE@는 PulseAudio의 디폴트 싱크와 소스 이름입니다.
```sh
pactl set-sink-volume @DEFAULT_SINK@ 200%
pactl set-source-volume @DEFAULT_SOURCE@ 200%
```

2. sox의 심볼 링크인 rec로 녹음합니다. 녹음을 멈추고 싶으면 \<Ctrl>+\<c>를 누릅니다.
```sh
rec hello1.wav
```
```out
Input File     : 'default' (alsa)
Channels       : 2
Sample Rate    : 48000
Precision      : 16-bit
Sample Encoding: 16-bit Signed Integer PCM
```

3. 녹음할 때 --buffer과 -c 옵션으로 버퍼 크기와 채널 갯수를 설정할 수 있습니다. 각각의 기본값은 8192과 2입니다.
```sh
rec --buffer 1600 -c 1 hello2.wav
```
```out
Input File     : 'default' (alsa)
Channels       : 1
Sample Rate    : 48000
Precision      : 16-bit
Sample Encoding: 16-bit Signed Integer PCM
```

4. .mp3 확장자를 사용하면 MPEG audio 인코더가 적용된 MP3 파일로 녹음합니다.
```sh
rec hello.mp3
```

5. .ogg 확장자를 사용하면 Vorbis 인코더가 적용된 OGG 파일로 녹음합니다.
```sh
rec hello.ogg
```

6. 녹음된 파일 크기를 확인해 보면 압축 포맷인 MP3가 가장 작습니다.
```sh
ls -lh
```
```out
Permissions Size User Date Modified Name
.rw-rw-r--   46k soda 11 nov 17:43   hello.mp3
.rw-rw-r--   32k soda 11 nov 17:43   hello.ogg
.rw-rw-r--  508k soda 11 nov 17:37   hello1.wav
.rw-rw-r--  358k soda 11 nov 17:37   hello2.wav
```

7. 오디오 파일을 재생해 봅니다. play 역시 sox 명령의 싱크 전용 심볼링 링크입니다. 여러 개의 파일을 나열하면 차례대로 모두 재생 합니다.
```sh
play hello1.wav hello2.wav hello.mp3 hello.ogg
```

**잡음 제거와 녹음**
현재 환경의 잡음 프로파일을 미리 만들어두면, 녹음 시 이를 활용하여 잡음을 효과적으로 제거할 수 있습니다. 잡음 제거 과정에서 미세한 소리 왜곡이 발생할 수 있지만, 전반적으로 더욱 깔끔하고 선명한 녹음 결과를 얻을 수 있습니다.

1. 먼저, 주변 환경의 잡음을 3 ~ 5초 정도 녹음합니다. 이때, 녹음 중에는 음성이나 다른 소리가 포함되지 않도록 주의합니다. 채널은 기본값인 2채널을 사용합니다.
```sh
rec noise.wav
```

2. 녹음된 잡음 파일로부터 잡음 프로파일을 생성합니다.
```sh
sox noise.wav -n noiseprof noise.prof
```

3. OGG 포맷으로 20초 정도 목소리를 녹음합니다. 이 파일에는 주변 잡음이 포함되어 있습니다. 채널은 기본값인 2채널을 사용하는데, 반드시 잡음 프로파일을 만들 때 사용한 채널 개수와 같아야 합니다.
```sh
rec we.ogg
```

4. 잡음이 포함된 파일에 잡음 프로파일을 적용헤 잡음을 제거합니다. 잡음 제거 강도는 0~1 사잇값입니다.
```sh
sox we.ogg we_noisered.ogg noisered noise.prof 0.1
```

5. 잡음 프로파일을 적용한 상태에서 녹음하는 것도 가능합니다.
```sh
rec clean.mp3 noisered noise.prof 0.18
```

6. 녹음된 결과를 확인합니다.
```sh
play we.ogg we_noisered.ogg clean.mp3
```

**홥성음 출력**
SoX의 synth는 소리를 합성하는 데 사용되는 강력한 기능입니다. 다양한 파형, 주파수, 효과를 사용하여 원하는 소리를 만들어낼 수 있습니다.  

synth의 기본적인 사용법은 다음과 같습니다. 
```sh
sox -n [output.wav] synth [duration] <type> <frequency> [options]
```

타입은 만들 신호의 종류로 사인파(sine), 사각파(square), 삼각파(triangle), 톱니파(sawtooth), 사다리꼴파(trapezium), 지수파(exp), 백색잡음(noise), 분홍색잡음(tpdfnoise), 갈색잡음(brownnoise) 중 하나를 사용합니다. 옵션을 통해 볼륨을 조절하거나 주파수를 변조하며 페이드 인/아웃, 페이저, 트레몰로, 코로스와 같은 다양한 효과를 추가할 수 있습니다.

다음과 같이 합성음을 출력해 봅니다.

1. 사인파로 기본음인 라(A4)를 출력합니다. -n 옵션은 파일을 사용하지 않는다는 뜻이고, synth는 합성, 1은 지속 시간, sin 440은 사인파로 440Hz 음을 만듧니다.
```sh
play -n synth 1 sin 440
```

2. 주파수 대신 사용하는 %0는 440을 의미하며, 1 또는 -1씩 증감할 때마다 반음이 올라가거나 내려갑니다. fade는 페이드 효과로, t는 3차 곡선, 0.1은 페이드인, 1은 지속, 0.1은 페이드아웃 시간입니다.
```sh
play -n synth sin %0 fade t 0.1 1 0.1
```

fade는 오디오의 시작과 끝 부분에 페이드 인/아웃 효과를 적용하여 소리가 부드럽게 시작하고 끝나도록 만드는 데 h(half-logarithmic), q(2차 곡선, quadratic, t(3차 곡선, cubic) 중 하나를 추가하면 기본 곡선을 좀 더 부드럽게 만듦니다.

3. 사다리꼴파로 알파벳과 옥타브를 조합해 440Hz 음을 1초 동안 코러스 효과와 함께 출력합니다.
```sh
play -n synth 1 trapezium A4 chorus 0.7 0.9 50 0.4 0.25 6 -t 
```

코러스는 여러 개의 유사한 소리를 약간씩 다른 딜레이와 피치로 겹쳐 풍부하고 웅장한 효과를 주는 것으로 다음과 같은 순서로 인자를 사용합니다.
- 딜레이 시간의 변조 깊이 (0~1)
- 딜레이 시간의 변조 속도(Hz)
- 딜레이 시간(밀리초)
- 원본 신호와 딜레이된 신호의 혼합 비율(0~1)
- 딜레이된 신호의 패치 변화량(반음)
- 딜레이된 신호의 개수
- -t: 삼각파 LFO(Low Frequency Oscillator) 사용

4. 다음은 도, 미, 솔로 구성된 화음을 출력합니다.
```sh
play -n synth sin C4 sin E4 sin G4 fade q 0.1 0.8 0.1
```
```sh
play -n synth sin %-9 sin %-5 sin %-2 fade q 0.1 0.8 0.1
```
```sh
play -n synth sin 261.6256 sin 329.6276 sin 391.9954 fade q 0.1 0.8 0.1
```

5. 0.5초 간 2개 채널로 C4의 배음을 함께 출력합니다.
```sh
play -c 2 -n synth 0.5 pl C4 pl C5 pl G5 pl C6 pl E6 
```

### 파이썬으로 오디오 녹음/재생
일반적으로 파이썬으로 마이크에서 소리를 녹음하거나 스피커로 소리를 재생할 때는 PortAudio와 함께 PyAudio를 사용합니다. 
PluseAudio가 오디오 서버라면 PortAudio는 다양한 플랫폼에서 오디오 입출력을 처리하기 위한 오픈 소스, 크로스 플랫폼 오디오 입출력 라이브러리로 PluseAudio에 비해 기능은 제한적이지만 저수준으로 오디오를 처리를 통해 낮은 시연 시간을 갖습니다. 
serbot은 PluseAudio를 사용하므로 pysimple으로 소스 데이터를 녹음하고, 오디오 파일을 싱크로 재생할 수 있습니다.   
하지만 PortAudio처럼 MP3 포맷을 지원하지 않으므로 녹음과 재생은 sox과 lame로 처리하고 주변 소음 측정에 pysimple을 사용합니다.

```sh
sudo pip3 install pysimple
```

**하위 문자열이 포함된 문자열을 리스트로 변환**
문자열을 리스트로 변환할 때 str 객체의 split() 메소드는 공백을 기준으로 요소를 분할하므로, 문자열 안에 하위 문자열을 추가하면, 하위 문자열을 하나의 요소로 처리하지 않고 동일하게 분할합니다.  

예를 들어 다음과 같이 하위 문자열이 포함된 문자열이 주어질 때,
```sh
cmd = "sed -E 's/.* ([0-9]+)% .*/\\1/'" # 문자열에 포함된 역슬레쉬(\\)는 특수문자로 해석하므로 문자 표현은 2개(\\\\) 사용
```

cmd.split()의 결과는 다음을 기대하지만,
```
['sed', '-E', 's/.* ([0-9]+)% .*/\\1/']
```

실제는 다음과 같습니다.
```out
['sed', '-E', "'s/.*", '([0-9]+)%', ".*/\\1/'"]
```

따라서 하위 문자열 내부는 분할하지 않는 _split() 함수를 구현합니다.

```python
def _split(string):
  result = []
  current_word = ""
  in_quote = False

  for ch in string:
    if ch == " " and not in_quote:
      if current_word:
        result.append(current_word)
        current_word = ""
    elif ch == "'":
      in_quote = not in_quote
    else:
      current_word += ch

  if current_word:
    result.append(current_word)

  return result
```

**파이썬에서 리눅스 명령 실행**
파이썬에서 subprcess.Popen 클래스를 이용하면, 새로 만든 자식 프로세스에서 리눅스 명령을 실행하고, 프로세스의 입출력을 파이프로 연결하며, 표준 출력과 표준 오류를 통해 실행 결과를 가져올 수 있습니다.

```python
def _run_command(cmd, stdout=False):
    process = subprocess.Popen(_split(cmd), **{'stdout':subprocess.PIPE} if stdout else {'stdout':subprocess.DEVNULL, 'stderr':subprocess.DEVNULL})
    
    if stdout:
        output, _ = process.communicate()
        ret = output
    else:
        ret = process
        
    return ret
    
def _run_pipe_command(*cmds, stdout=False):
    process = []

    process.append(subprocess.Popen(_split(cmds[0]), stdout=subprocess.PIPE))
    for command in cmds[1:-1]:
        process.append(subprocess.Popen(_split(command), stdin=process[-1].stdout, stdout=subprocess.PIPE))
    
    process.append(subprocess.Popen(_split(cmds[-1]), stdin=process[-1].stdout, **{'stdout':subprocess.PIPE} if stdout else {'stdout':subprocess.DEVNULL, 'stderr':subprocess.DEVNULL}))
    
    if stdout:
        output, _ = process[-1].communicate()
        ret = output
    else:
        ret = process[-1]

    return ret
```

_run_command()는 하나의 자식 프로세스로 단일 명령을 실행하고, _run_pipe_command()는 여러 자식 프로세스의 입출력을 파이프로 연결해 여러 명령을 순차적으로 실행합니다. 두 함수의 반환값은 매개변수 stdout에 따라 다른데, 기본값인 False는 즉시 자식 프로세스를 반환하고 True는 자식 프로세스가 종료할 때까지 기다린 후 표준 출력 결과를 읽어 반환합니다.


**볼륨 조절**
set-<sink|source>-volume 옵션과 함께 pactl을 실행하면 소스와 싱크 볼륨을 설정할 수 있습니다. 볼륨 확인은 get-<sink|source>-volume 옵션을 사용하지만 pulseaudio V15.99 이상이 필요하므로 호환성을 높이기 위해 list <sinks|sources> 옵션 결과를 다른 리눅스 명령으로 걸러 확인합니다.

```python
class Volume:
    SINK_POS    = 3
    SOURCE_POS  = 5

    @staticmethod
    def version():
        command1 = "pactl --version"
        command2 = "head -n 1"
        command3 = "sed -E s/[^0-9.]//g"
        command4 = "sed -E 's/.[^.]*$//'"
        
        return float(_run_pipe_command(command1, command2, command3, command4, stdout=True).decode().strip())
        
    @staticmethod
    def __volume(target):
        if target == "sinks":
            pos = str(Volume.SINK_POS)
        elif target == "sources":
            pos = str(Volume.SOURCE_POS)
        else:
            return
        
        command1 = f"pactl list {target}"
        command2 = "grep ^[[:space:]]Volume:"
        command3 = f"head -n {pos}"
        command4 = "tail -n 1"
        command5 = "sed -E 's/.* ([0-9]+)% .*/\\1/'"
        
        return int(_run_pipe_command(command1, command2, command3, command4, command5, stdout=True).decode().strip())
       
    @staticmethod
    def sink():
        if Volume.version() >= 15.0:
            command = "pactl get-sink-volume @DEFAULT_SINK@"
            ret = int(_run_command(command, stdout=True))
        else:
            ret = Volume.__volume("sinks") 
        
        return ret

    @staticmethod
    def setSink(value):        
        command = f"pactl set-sink-volume @DEFAULT_SINK@ {value}%"
        _run_command(command)
    
    @staticmethod
    def source():
        if Volume.version() >= 15.0:
            command = "pactl get-source-volume @DEFAULT_SOURCE@"
            ret = int(_run_command(command, stdout=True))
        else:
            ret = Volume.__volume("sources")
        
        return ret
        
    @staticmethod
    def setSource(value):        
        command = f"pactl set-source-volume @DEFAULT_SOURCE@ {value}%"
        _run_command(command)
```

**녹음**
sox의 심볼 링크인 rec를 이용해 소스로부터 읽은 PCM 데이터를 확장자에 따라 WAV, MP3, OGG 포맷으로 저장합니다. 최초 1회 Record 객체를 만들 때 3초동안 잡음 제거 프로파일도 함께 만들어지며, 이후 start()의  noisered와 attenuation_factor 매개변수로 잡음 제거 효과를 사용 유무를 결정합니다. noisered의 기본값은 False로 잡은 제거 효과를 적용하지 않습니다.
만약 적용한 잡음 제거 효과가 만족스럽지 않다면 조용한 환경에서 updateNoiseProf()를 호출해 프로파일을 새로 만듧니다.

```python
class Record:    
    def __init__(self, channel=2):
        self.__rec_process = None
        self.__channel = channel
        
        home_dir = os.path.expanduser("~")
        self.__noise_path = os.path.join(home_dir, ".noise.wav")
        self.__prof_path = os.path.join(home_dir, ".noise.prof")
        
        if not os.path.exists(self.__prof_path):
            self.updateNoiseProf()
        
    def __del__(self):
        self.stop()
        
    def start(self, filename, noisered=False, attenuation_factor=0.18):
        command = f"rec -q -c {self.__channel} {filename}"
        
        if noisered:
            command += f" noisered {self.__prof_path} {attenuation_factor}"

        self.__rec_process = _run_command(command)
        
    def stop(self):
        if self.__rec_process:
            self.__rec_process.send_signal(signal.SIGINT)
            self.__rec_process.wait()    
            self.__rec_process = None

    def updateNoiseProf(self, timeout=3):
        self.start(self.__noise_path)
        time.sleep(timeout)
        self.stop()
        
        command = f"sox {self.__noise_path} -n noiseprof {self.__prof_path}"
        process = _run_command(command)
        process.wait()
        os.remove(self.__noise_path)
```

**재생**
sox의 심볼 링크인 play는 mp3 파일을 재생할 수 있습니다.

```python
class Play:    
    def __init__(self, *filename):
        self.__play_process = None
        self.__play_list = filename
        self.__length = len(filename)
        self.__index = 0

    def __play(self, filename):
        command = f"play {filename}"

        if self.__play_process:
            self.stop()

        self.__play_process = _run_command(command)
        
    def start(self):           
        self.__index = 0
        self.__play(self.__play_list[self.__index])
    
    def stop(self):
        if self.__play_process:
            self.__play_process.send_signal(signal.SIGINT)
            self.__play_process.wait()
            self.__play_process = None

    def next(self):
        self.__index = (self.__index + 1) % self.__length
        self.__play(self.__play_list[self.__index])

    def prev(self):
        self.__index = (self.__index - 1) % self.__length
        self.__play(self.__play_list[self.__index])
```

**톤 출력**
sox의 synth 기능을 이용해 음과 음표에 해당하는 소리를 출력합니다. play()에 전달하는 첫 번째 인자는 알파뱃 형식의 음과 오타브이고 두 번째 인자는 음표입니다. 그 외는 키워드 인자로 fade와 chorus를 설정할 수 있습니다.  
fade의 기본값은 False이지만 (0.1, 0.1) 형식으로 인/아웃 시간을 전달하면 음을 출력할 때 효과가 적용됩니다. chorus는 (0.7, 0.9, 60, 0.4, 0.25, 6) 형식의 기본값이  적용되어 있습니다.

```python
class Tone:
    TYPE_SIN = "sin"
    TYPE_SQUARE = "square"
    TYPE_TRIANGLE = "triangle"
    TYPE_SAWTOOTH = "sawtooth"
    TYPE_TRAPEZIUM = "trapezium"
    
    
    def __init__(self, tempo=120):
        self.__tempo = tempo
        self.notes = {("C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B")[n] : n+1 for n in range(12)}
        
    @property
    def tempo(self):
        return self.__tempo
    
    @tempo.setter
    def tempo(self, n):
        self.__tempo = n
   
    def play(self, pitch_octave, note, **kwargs):
        '''
        pitch: C, C#, D, D#, E, F, F#, G, G#, A, A#, B
        octave: 1 ~ 8
        note: 1, 2, 4, 8, 16, 32
        '''
        
        duration = 60 / self.tempo * (4 / note)
        
        if pitch_octave != "REST":
            synth_type = kwargs.get('type', Tone.TYPE_TRAPEZIUM)
            overtone = kwargs.get('overtone', 5)
            
            freq = []
            freq.append(2**(int(pitch_octave[-1])-1) * 55 * 2 ** ((self.notes[pitch_octave[:-1]]-10)/12))
            for i in range(overtone-1):
                freq.append(freq[0] * (i+2))
            
            command = ["play", "-c", "2", "-n", "synth", str(duration), *[item for f in freq for item in (synth_type, str(f))]]
            
            fade = kwargs.get('fade', False)
            if fade:
                del command[5] # remove duration
                command.append("fade")
                command.extend([fade[0], str(fade[1]), str(duration), str(fade[2])])
            
            chorus = kwargs.get('chorus', (0.7, 0.9, 60, 0.4, 0.25, 6))
            if chorus:
                command.append("chorus")
                command.extend([str(n) for n in chorus])
                command.append("-t")
                
            _run_command(command)
        
        time.sleep(duration)
        
    def rest(self, note):
        self.play("REST", note)
```

**audio.py**
 지금까지 구현한 내용을 serbot2 라이브러리 폴더(~/.local/lib/python3.8/site-packages/serbot2)에 audio.py란 이름으로 저장합니다.
 
```sh
import subprocess
import signal
import time
import os

def _split(data):
    if not isinstance(data, str):
        return data
    
    result = []
    current_word = ""
    in_quote = False

    for ch in data:
        if ch == " " and not in_quote:
            if current_word:
                result.append(current_word)
                current_word = ""
        elif ch == "'":
            in_quote = not in_quote
        else:
            current_word += ch

    if current_word:
        result.append(current_word)

    return result

def _run_command(cmd, stdout=False):
    process = subprocess.Popen(_split(cmd), **{'stdout':subprocess.PIPE} if stdout else {'stdout':subprocess.DEVNULL, 'stderr':subprocess.DEVNULL})
    
    if stdout:
        output, _ = process.communicate()
        ret = output
    else:
        ret = process
        
    return ret
    
def _run_pipe_command(*cmds, stdout=False):
    process = []

    process.append(subprocess.Popen(_split(cmds[0]), stdout=subprocess.PIPE))
    for command in cmds[1:-1]:
        process.append(subprocess.Popen(_split(command), stdin=process[-1].stdout, stdout=subprocess.PIPE))
    
    process.append(subprocess.Popen(_split(cmds[-1]), stdin=process[-1].stdout, **{'stdout':subprocess.PIPE} if stdout else {'stdout':subprocess.DEVNULL, 'stderr':subprocess.DEVNULL}))
    
    if stdout:
        output, _ = process[-1].communicate()
        ret = output
    else:
        ret = process[-1]

    return ret


class Volume:
    SINK_POS    = 3
    SOURCE_POS  = 5

    @staticmethod
    def version():
        command1 = "pactl --version"
        command2 = "head -n 1"
        command3 = "sed -E s/[^0-9.]//g"
        command4 = "sed -E 's/.[^.]*$//'"
        
        return float(_run_pipe_command(command1, command2, command3, command4, stdout=True).decode().strip())
        
    @staticmethod
    def __volume(target):
        if target == "sinks":
            pos = str(Volume.SINK_POS)
        elif target == "sources":
            pos = str(Volume.SOURCE_POS)
        else:
            return
        
        command1 = f"pactl list {target}"
        command2 = "grep ^[[:space:]]Volume:"
        command3 = f"head -n {pos}"
        command4 = "tail -n 1"
        command5 = "sed -E 's/.* ([0-9]+)% .*/\\1/'"
        
        return int(_run_pipe_command(command1, command2, command3, command4, command5, stdout=True).decode().strip())
       
    @staticmethod
    def sink():
        if Volume.version() >= 15.0:
            command = "pactl get-sink-volume @DEFAULT_SINK@"
            ret = int(_run_command(command, stdout=True))
        else:
            ret = Volume.__volume("sinks") 
        
        return ret

    @staticmethod
    def setSink(value):        
        command = f"pactl set-sink-volume @DEFAULT_SINK@ {value}%"
        _run_command(command)
    
    @staticmethod
    def source():
        if Volume.version() >= 15.0:
            command = "pactl get-source-volume @DEFAULT_SOURCE@"
            ret = int(_run_command(command, stdout=True))
        else:
            ret = Volume.__volume("sources")
        
        return ret
        
    @staticmethod
    def setSource(value):        
        command = f"pactl set-source-volume @DEFAULT_SOURCE@ {value}%"
        _run_command(command)


class Record:    
    def __init__(self, channel=2):
        self.__rec_process = None
        self.__channel = channel
        
        home_dir = os.path.expanduser("~")
        self.__noise_path = os.path.join(home_dir, ".noise.wav")
        self.__prof_path = os.path.join(home_dir, ".noise.prof")
        
        if not os.path.exists(self.__prof_path):
            self.updateNoiseProf()
        
    def __del__(self):
        self.stop()
        
    def start(self, filename, noisered=False, attenuation_factor=0.18):
        command = f"rec -q -c {self.__channel} {filename}"
        
        if noisered:
            command += f" noisered {self.__prof_path} {attenuation_factor}"

        self.__rec_process = _run_command(command)
        
    def stop(self):
        if self.__rec_process:
            self.__rec_process.send_signal(signal.SIGINT)
            self.__rec_process.wait()    
            self.__rec_process = None

    def updateNoiseProf(self, timeout=3):
        self.start(self.__noise_path)
        time.sleep(timeout)
        self.stop()
        
        command = f"sox {self.__noise_path} -n noiseprof {self.__prof_path}"
        process = _run_command(command)
        process.wait()
        os.remove(self.__noise_path)


class Play:    
    def __init__(self, *filename):
        self.__play_process = None
        self.__play_list = filename
        self.__length = len(filename)
        self.__index = 0

    def __play(self, filename):
        command = f"play {filename}"

        if self.__play_process:
            self.stop()

        self.__play_process = _run_command(command)
        
    def start(self):           
        self.__index = 0
        self.__play(self.__play_list[self.__index])
    
    def stop(self):
        if self.__play_process:
            self.__play_process.send_signal(signal.SIGINT)
            self.__play_process.wait()
            self.__play_process = None

    def next(self):
        self.__index = (self.__index + 1) % self.__length
        self.__play(self.__play_list[self.__index])

    def prev(self):
        self.__index = (self.__index - 1) % self.__length
        self.__play(self.__play_list[self.__index])
        

class Tone:
    TYPE_SIN = "sin"
    TYPE_SQUARE = "square"
    TYPE_TRIANGLE = "triangle"
    TYPE_SAWTOOTH = "sawtooth"
    TYPE_TRAPEZIUM = "trapezium"
    
    
    def __init__(self, tempo=120):
        self.__tempo = tempo
        self.__fade = (0.05, 0.05)
        self.notes = {("C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B")[n] : n+1 for n in range(12)}
        
    @property
    def tempo(self):
        return self.__tempo
    
    @tempo.setter
    def tempo(self, n):
        self.__tempo = n
        self.__fade = (0.0, 1/self.tempo*10)
    
    def play(self, pitch_octave, note, **kwargs):
        '''
        pitch: C, C#, D, D#, E, F, F#, G, G#, A, A#, B
        octave: 1 ~ 8
        note: 1, 2, 4, 8, 16, 32
        '''
        
        duration = 60 / self.tempo * (4 / note)
        
        if pitch_octave != "REST":
            synth_type = kwargs.get('type', Tone.TYPE_TRAPEZIUM)
            overtone = kwargs.get('overtone', 5)
            
            freq = []
            freq.append(2**(int(pitch_octave[-1])-1) * 55 * 2 ** ((self.notes[pitch_octave[:-1]]-10)/12))
            for i in range(overtone-1):
                freq.append(freq[0] * (i+2))
            
            command = ["play", "-c", "2", "-n", "synth", str(duration), *[item for f in freq for item in (synth_type, str(f))]]
            
            fade = kwargs.get('fade', False)
            if fade:
                del command[5] # remove duration
                command.append("fade")
                command.extend([fade[0], str(fade[1]), str(duration), str(fade[2])])
            
            chorus = kwargs.get('chorus', (0.7, 0.9, 60, 0.4, 0.25, 6))
            if chorus:
                command.append("chorus")
                command.extend([str(n) for n in chorus])
                command.append("-t")
                
            _run_command(command)
            
        
        time.sleep(duration)
        
    def rest(self, note):
        self.play("REST", note)
```

다음은 audio.py를 이용한 테스트 코드입니다.
```python
import serbot2.audio as audio
import time

def tone_test():
    melody_tetris = (
        "E5",4, "B4",8, "C5",8, "D5",4, "C5",8, "B4",8,
        "A4",4, "A4",8, "C5",8, "E5",4, "D5",8, "C5",8,
        "B4",4, "C5",8, "D5",4, "E5",4,
        "C5",4, "A4",4, "A4",8, "A4",4, "B4",8, "C5",8,
            
        "D5",4, "F5",8, "A5",4, "G5",8, "F5",8,
        "E5",4, "C5",8, "E5",4, "D5",8, "C5",8,
        "B4",4, "B4",8, "C5",8, "D5",4, "E5",4,
        "C5",4, "A4",4, "A4",4, "REST", 4,
            
        "E5",4, "B4",8, "C5",8, "D5",4, "C5",8, "B4",8,
        "A4",4, "A4",8, "C5",8, "E5",4, "D5",8, "C5",8,
        "B4",4, "C5",8, "D5",4, "E5",4,
        "C5",4, "A4",4, "A4",8, "A4",4, "B4",8, "C5",8,
            
        "D5",4, "F5",8, "A5",4, "G5",8, "F5",8,
        "E5",4, "C5",8, "E5",4, "D5",8, "C5",8,
        "B4",4, "B4",8, "C5",8, "D5",4, "E5",4,
        "C5",4, "A4",4, "A4",4, "REST", 4,
            
        "E5",2, "C5",2,
        "D5",2,  "B4",2,
        "C5",2,  "A4",2,
        "G#4",2, "B4",4, "REST",8, 
        "E5",2,  "C5",2,
        "D5",2,  "B4",2,
        "C5",4,  "E5",4, "A5",2,
        "G#5",2
    )

    tone = audio.Tone()
    tone.tempo = 200

    melody = melody_tetris
    for pitch_octave, duration in zip(melody[::2], melody[1::2]):
        tone.play(pitch_octave, duration)


if __name__ == "__main__":
    tone_test()
```
