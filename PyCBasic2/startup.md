## soda 계정 메모리맵 접근 권한 부여
```sh
sudo chmod 6755 /home/soda/.local/mambaforge/bin/xcpp
sudo chmod 6755 /home/soda/.local/mambaforge/bin/cling

sudo setcap cap_sys_rawio,cap_sys_nice+ep ~/.local/mambaforge/bin/cling
sudo setcap cap_sys_rawio,cap_sys_nice+ep ~/.local/mambaforge/bin/xcpp

sudo systemctl restart jupyter
```
