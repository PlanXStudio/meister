# SerBot2
NVIDIA Orin NX 16G + STM43F4 기반 서비스 로봇 개발장비

## 구조
**AP**
- NVIDIA Orin NX 16G, 100TOPS
- Ubuntu Linux 22.04
- Tourch Screen + Lidar

**MCU**
- STM32F4
- FreeRTOS
- IMU, Motor, Encoder, Etc

**CAN FD**
- AP <---> CAN FD <---> MCU

## 전압
- Voltage Meter에서 현재 전압 표시
- 파워: 19V DC Adapter
- 배터리
  - 공칭 전압: +14.8V
  - 최대 전압 +16.8V
  - 배터리 체크 LED: Normal, Low
    - Low ON: 충전이 필요한 상태로 반드시 19V DC Adapter 연결

## 사용자 계정 생성
- PC를 XField-Network에 연결
  - Passwd: xfield123! 
- SerBot2의 Wi-Fi IP 확인
- soda 계정으로 접속
  - ssh soda@<serbot2_ip>
  - passwd: soda
- 새 계정 생성
  - sudo adduser <user_id>
    - passwd: <user_pw>
  - sudo cp -R .* /home/<user_id>
  - sudo cp -R * /home/<user_id>
  - sudo gpasswd -a <user_id> sudo
  - exit
- <user_id> 계정으로 접속
  - ssh <user_id>@<serbot2_ip>
  - passwd: <user_pw>
  - sudo chsh
    - /bin/zsh
  - exit
     
