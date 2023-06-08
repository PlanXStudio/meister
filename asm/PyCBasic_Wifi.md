## Wi-Fi Checking
```
ifconfig wlan0
```

## AP Scanning
```sh
sudo iwlist wlan0 scan | grep ESSID | sed -e 's/:/\t/g' | cut -f 2 | sed -e 's/"//g'
```

## WPA Supplicant
```sh
sudo vi /etc/wpa_supplicant/wpa_supplicant.conf
```
```sh
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={
     ssid="Your ap name"
     psk="Your ap password"
}
```

- Reconfigure for wlan0
```sh
sudo wpa_cli -i wlan0 reconfigure
```
