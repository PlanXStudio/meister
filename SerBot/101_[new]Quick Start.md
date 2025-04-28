
## Login
### pc ip settings
> 192.168.7.2

### ssh login
> ssh soda@192.168.7.1
>> soda
> history -c

###  Wi-Fi settings
> sudo nmtui -> Activate a connection -> Wi-Fi -> <your_ap>
>> Password: <your_passwd>
> ping www.google.co.kr

## CLI
###  zsh, oh-my-zsh, powerlevel10k
###  tmux prefix: C-b
- prefix: C-b
- split pane: |, -
> jtop

###  fzf
- 'word: 정확히 일치
- ^word: word로 시작
- word$: word로 끝남
- !word: word 제외
###  eza(ls), dust(du), broot(tree), gping(ping), fd(find), ripgrep(grep), hexyl(od)

## GUI
```sh
> Xorg :0 -nocursor & ;export DISPLAY=:0 
> xeyes -geometry 1024x600 -outline yellow -center green
> killall Xorg

> openbox-session &
> xeyes -geometry 640x480 -outline yellow -center green
> killall Xorg

> xinit /usr/bin/openbox-session -- /usr/bin/Xorg :0  -nocursor &
> DISPLAY=:0 xeyes -geometry 640x480 -outline yellow -center green
> killall Xorg

> startx -- -nocursor &
> ps aux | grep Xorg
> export DISPLAY=:0
```

##  VSCode for Python
> VSCode > Remote SSH 
> F1 -> Python: Select Interpreter -> Enter interpreter path...
>> /usr/bin/python3
> F1 -> Developer: Reload Window

##  serbot library
> mkdir workspace
> pip install genlib
> serbot.zip -> *.* -> workspace/workspace/serbot
