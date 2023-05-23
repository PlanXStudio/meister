## WSL Ubuntu-22.04
- Powershell opened as **Administrator**
```sh
wsl --update
wsl -l -o
wsl --install -d Ubuntu-22.04
```

- Activate WinGet  
> Window Package Manager (https://learn.microsoft.com/ko-kr/windows/package-manager/winget/)
```sh
Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe
```

- Window Terminal
  - Uninstall Old Version
    ```sh
    winget list windowsterminal
    winget uinstall Microsoft.WindowsTerminal
    ```
  - Install New Version
    ```
    winget search windowsterminal
    winget install Microsoft.WindowsTerminal.Preview
    ```

## Install Mosquitto (MQTT Broker)
- Linux (Include WSL)
```sh
sudo apt install mosquitto
sudo apt install mosquitto-clients
```
- Mac
```sh
brew install mosquitto
brew install mosquitto-clients
```

## Public MQTT Brokers

|Name |	Broker Address | TCP Port	| TLS Port | WebSocket Port| Message Retention|
|---|---|---|---|---|---|
Eclipse	| mqtt.eclipse.org	| 1883	| N/A	| 80, 443 |	YES  
Mosquitto	| test.mosquitto.org	| 1883	| 8883, 8884	| 80	| YES  
HiveMQ | broker.hivemq.com	| 1883	| N/A	| 8000	| YES  
Flespi | mqtt.flespi.io | 1883 | 8883 | 80, 443 | YES
Dioty	| mqtt.dioty.co |	1883 | 8883 |	8080, 8880 |	YES
Fluux	| mqtt.fluux.io |	1883 | 8883 |	N/A |	N/A
EMQX | broker.emqx.io |	1883 | 8883| 8083 |	YES

- subscribe
```sh
mosquitto_sub -h broker.hivemq.com -p 1883 -t "broker/test" -d
```
- publish
```
mosquitto_pub -h broker.hivemq.com -p 1883 -t "broker/test" -d -m "Hello"
```
