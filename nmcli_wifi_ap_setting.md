## AP List
```sh
nmcli device wifi list
```

## Join AP
```sh
sudo nmcli device wifi connect <want_ap_ssid> password <ap_passwd>
```

## Remove Join AP 
```sh
sudo nmcli connect delete <connected_ssid>
```
