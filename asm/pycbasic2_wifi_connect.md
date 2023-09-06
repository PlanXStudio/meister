# Debin 계열 리눅스에서 Wi-Fi 어뎁터를 AP에 연결하기
> AP 이름은 asaniot1이며, 패스워드는 asan123456으로 가정 

## VSCode로 PyCBasic 2 실습장비에 원격 접속한 후 수행
> 터미널 창을 실행한 후 진행

### 설정 파일을 현재 디렉토리로 복사
```sh
cp /etc/wpa_supplicant/wpa_supplicant.conf ./
```

### 현재 디렉토리의 wpa_supplicant.conf를 편집기로 열고 다음 내용으로 수정 
> VSCode에서 현재 디렉토리의 wpa_supplicant.conf를 열어 편집 후 저장
```sh
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={
     ssid="asaniot1"
     psk="asan123456"
}
```

### 수정한 wpa_supplicant.conf를 /etc/wpa_supplicant/ 디렉토리로 복사
```sh
sudo mv wpa_supplicant.conf /etc/wpa_supplicant/
```

### 현재 디렉토리의 wpa_supplicant.conf 삭제
```sh
rm ./wpa_supplicant.conf
```

### 네트워크 서비스 다시 시작
> AP의 DHCP 서버를 통해 IP를 할당받아야 함
```sh
sudo systemctl restart dhcpcd
sudo systemctl restart networking.service
```

### Wi-Fi 어뎁터에 동적으로 할당된 IP 확인
```sh
ifconfig wlan0
```

- 만약 IP가 할당되지 않았으면 실습장비를 재 시작해 볼 것
  ```sh
  sudo reboot
  ```
  
