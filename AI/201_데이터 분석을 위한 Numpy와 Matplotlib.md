# 영상 강의
- [201_Numpy와 Matplotlib 라이브러리](https://1drv.ms/v/s!AtTAtBZJQ9JFlcBvyxTP0Dh0sQYGGg?e=pGScjG)

## 강의 노트
- [201_Numpy.pdf](https://github.com/PlanXStudio/meister/files/15015370/201_Numpy.pdf)  
- [201_Matplotlib.pdf](https://github.com/PlanXStudio/meister/files/15015368/201_Matplotlib.pdf)

## 실습
### 삼각함수 시각화
```python
import matplotlib.pyplot as plt
import numpy as np

plt.title("Trigonometric functions")
plt.xlabel("angle")
plt.ylabel("value")
plt.grid(True, color='darkcyan', alpha=0.5, linestyle='-.')
plt.xlim(-10, 360+10)
plt.ylim(-1.2, 1.2)

x = np.arange(0, 360+1, 45)
sin_y = np.sin(x * np.pi / 180)
cos_y = np.cos(x * np.pi / 180)

plt.plot(x, sin_y, label='sin', color='#f00000', linestyle='-.', marker='o')
plt.plot(x, cos_y, label='cos')

plt.legend(loc=(0.7, 0.83))
plt.xticks([0, 90, 180, 270], ['0d', '90d', '180d', '270d'])
plt.tick_params('y', direction='inout', width=5)

plt.show()
```

### 주식 데이터 분석
> pandas-datareader 대신 finance-datareader 사용
```sh
pip install finance-datareader
pip install plotly 
```

**LG전자, 삼성전자** 
```python
import FinanceDataReader as fdr
import matplotlib.pyplot as plt

lge = fdr.DataReader('066570')
sec = fdr.DataReader('005930')

fig = plt.figure(figsize=(12, 4), dpi=300)
plt.plot(lge['Close'], label="LGE", color='C3')
plt.plot(sec['Close'], label="SEC", color='C0')
plt.grid(True, linestyle='-.')
plt.legend()
plt.show()
```

### 날씨 분석
> OpenWeatherMap 이용
>> API_KEY = 82d9ba39c9ea064bcc0432f5b9aff602
```sh
pip3 install pyowm
```

**서울 포함해 광역시의 현재 온도 시각화**
```python
import numpy as np
import matplotlib.pyplot as plt
from pyowm import OWM

API_KEY = '82d9ba39c9ea064bcc0432f5b9aff602'

def make_weather(citys):
    owm = OWM(API_KEY)
    mgr = owm.weather_manager()
    
    for city in citys.keys():
        o = mgr.weather_at_place(city + ',kr')
        citys[city] = o.weather.temperature('celsius')['temp']
    x = np.array(list(citys.keys()))
    y = np.array(list(citys.values()))
    return x, y


def init_plot():
    plt.title("Weather")
    plt.xlabel("citys")
    plt.ylabel("temperature")

def weather_ploting(citys):
    x, y = make_weather(citys)
    bar = plt.bar(x, y, color=['C0', 'C1', 'C2', 'C3', 'C4'])

    ylim = plt.ylim() 	# y에 음수가 있으면 텍스트를 바 플롯에 추가할 때 여유가 있도록 눈금 범위 확장
    if (ylim[0] < 0):
        plt.ylim((ylim[0] - 0.5, ylim[1] + 0.5))

    for rect in bar:		# 바 플롯 위(양수) 또는 아래(음수) 텍스트 추가
        height = rect.get_height()
        if height < 0: 
            height -= 0.4
        plt.text(rect.get_x() + rect.get_width()/2.0, height, '%.1f' % height, ha='center', va='bottom', size = 12)

def show_plot():
    plt.show()

def main():
    citys = {'seoul':0, 'incheon':0, 'daejeon':0, 'pusan':0, 'gwangju':0}
    init_plot()
    weather_ploting(citys)
    show_plot()

if __name__ == '__main__':
    main()
```
