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
