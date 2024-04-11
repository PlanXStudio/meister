# Numpy
## numpy란?
NumPy는 배열 개념을 사용하여 대규모 과학 계산에서 Python의 속도를 향상시키는 과학 컴퓨팅을 위한 기본 패키지입니다. 다차원 배열 객체, 다양한 파생 객체(예: 마스크 배열 및 행렬), 그리고 수학적, 논리적, 모양 조작, 정렬, 선택, I/O를 포함하여 배열에 대한 빠른 작업을 위한 일련의 이산 푸리에 변환, 기본 선형 대수학, 기본 통계 연산, 무작위 시뮬레이션 루틴을 제공하는 Python 라이브러리입니다.

### Numpy 요약
- 과학연산을위한파이썬핵심라이브러리중하나로빠른고성능연산을위해C언어로구현
    - 파이썬의편의성과C언어의연산능력을동시에이용
- 벡터부터텍서에 이르기까지다양한방법으로만드는다차원배열제공하며, 선형대수문제를쉽게처리할수있음
    - 스칼라scalar
       - 하나의값. a = 10
    - 벡터vector
       - 순서가있는 1 차원배열.x = [0, 1, 2]
       - 순서가없는배열은집합set
    - 행렬matrix
       - 벡터m이n개존재(m x n)하는 2 차원배열
       - 1 x n 행row벡터[[ 1 2 ]]와m x 1 열column벡터 [[[^12 ]]]는서로전치관계
    - 텐서tensor
       - 같은크기의행렬로구성된 3 차원이상배열
- 인기있는서드파티라이브러리들이NumPy를기본자료구조로사용하거나호환됨
    - matplotlib, pandas, opencv, pytorch, tensorflow 등


## ndarray

#### ▪ NumPy의 다차원배열객체
- ndarray의주요속성
    - ndarray.ndim: 배열의축axis(차원dimensions ) 수
    - ndarray.shape: 배열의차원으로,각차원배열의크기를정수튜플로나타냄.
       - (4 axis 0,), (4 axis 0, 3 axis 1), (2 axis 0, 4 axis 1, 3 axis 2)
       - 4 ≒ (4,) ➡(1, 4): 1x4 행벡터
       - (4, 1): 4x1 열벡터
    - ndarray.size: 배열의총요소수로, 각차원배열의크기를모두곱한값
    - ndarray.dtype:배열요소타입
       - 정수: numpy.int8, numpy.int16, numpy.int32, numpy.int64 (== int, 정수기본타입)
       - 실수: numpy.float16, numpy.float32, numpy.float64 (== float,실수기본타입), nympy.float
       - 기타: numpy.complex, numpy.bool, numpy.str, numpy.object
    - ndarray.itmesize: 바이트단위배열요소의크기(요소타입크기)
    - ndarray.data: 실제배열요소를포함하는버퍼로, 이미지나오디오같은바이너리데이터를다룰때사용

```
axis 2
```
```
axis 1 ndim: 3
shape: (2, 4, 3)
size: 24
dtype: int
itemsize: 8
```
```
axis 0
```
```
axis 1
```
```
ndim: 2
shape: (4, 1)
size: 4
dtype: int
itemsize: 8
```
```
axis 0
```
```
ndim: 1
shape: (4,)
size: 4
dtype: int
itemsize: 8
```
```
1D array
```
```
2D array
```
```
3D array
```

## 배열 생성

#### ▪ 파이썬객체(리스트, 튜플)

- 2 차원이상은반드시열의개수가일치해야함
- 요소중에실수가하나라도포함되면실수타입
- 정수요소의디폴트타입은int64이고실수요소의디폴트타입은float

```
01: import numpy as np
02:
03: show = lambda m, o : print(m, o.shape, o.dtype, '\n', o, '\n')
04:
05: a1 = np.array([2, 3, 4], dtype=np.int8)
06: a2 = np.array((1.5, 7, 9, 10))
07: a3 = np.array([[2, 3, 4], [7, 9, 10]])
08:
09: show("a1:", a1)
10: show("a2:", a2)
11: show("a3:", a3)
```

### 배열 생성

#### ▪ 범위 기반

- arange()는range()처럼주어진[start, stop)에서균일한정수또는실수배열반환
    - numpy.arange([start]stop, [step,]dtype=None)
- linspace()는arange()와유사하나step이실수이면오차가발생할수있으므로개수사용
    - numpy.linspace(start, stop, num=50, endpoint=True, retstep=False, dtype=None, axis=0)

```
01: import numpy as np
02
03: show = lambda m, o : print(m, o.shape, o.dtype, '\n', o, '\n')
04:
05: a1 = np.arange(27+1)
06: a2 = np.arange(1, 10+1, 0.5)
07: a3 = np.linspace(1, 10+1, 20)
08:
09: show("a1:", a1)
10: show("a2:", a2)
11: show("a3:", a3)
```

### 배열 생성

#### ▪ 특정 값으로초기화

- numpy.zeros(shape, dtype=float): 배열전체를 0 으로초기화
- numpy.ones(shape, dtype=None): 배열전체를 1 로초기화. 기본타입은float
- numpy.full(shape,fill_value,dtype=None): 배열전체를전달한값으로초기화
- numpy.eye(N, M=None, k=0, dtype=float): N x M 배열에 대해대각선이 1 이고나머지는 0 으로초기화
    - M을생략하면M=N (항등또는단위행렬identity matrix) , k는대각선인덱스로 0 은기준대각, 양수는기준대각위쪽, 음수는아래쪽
- numpy.diag(a,k=0):단위행렬의대각선값들을하나의배열로반환

```
01: import numpy as np
02
03: show = lambda m, o : print(m, o.shape, o.dtype, '\n', o, '\n')
04:
05: a0 = np.zeros(5)
06: a1 = np.zeros((5,1), dtype=int)
07: a2 = np.ones((3, 4), dtype=int)
08: a3 = np.full((2, 3), -1)
09: a4 = np.eye(5, k=1)
10: a5 = np.diag(a4, k=1)
11:
12: show("a0:", a0) ; show("a1:", a1) ; show("a2:", a2)
13: show("a3:", a3) ; show("a4:", a4) ; show("a5:", a5)
```

### 배열 생성

#### ▪ 기존 배열복사

- numpy.ones_like(a, dtype=None): 1로채워진배열
- numpy.zeros_like(a, dtype-None): 0으로채워진배열
- numpy.full_like(a,fill_value,dtype=None): 전달한값으로채워진배열

```
01: import numpy as np
02
03: show = lambda m, o : print(m, o.shape, o.dtype, '\n', o, '\n')
04:
05: a = np.linspace(1, 12, 12).reshape((2, 3, 2))
06:
07: b1 = np.ones_like(a)
08: b2 = np.zeros_like(a)
09: b3 = np.full_like(a, -1)
10:
11: show("a:", a)
12: show("b1:", b1)
13: show("b2:", b2)
14: show("b3:", b3)
```

## 모양 변경

#### ▪ 배열은 각축을따라 요소의 수로지정된 모양을가짐

- 배열자체는변하지않고새로운차원으로모양만바꾸므로size는같아야함
    - numpy.reshape(a, new_shape)
    - ndarray.reshape(new_shape)
- 모양에맞춰배열크기도함께변경하므로새모양의size가더크면나머지요소는 0 으로채움
    - ndarray.resize(new_shape)

```
01: import numpy as np
02
03: show = lambda m, o : print(m, o.shape, o.dtype, '\n', o, '\n')
04:
05: a1 = np.full((6, 3), -1)
06: a2 = np.reshape(a1, (3, 3, 2))
07: a3 = np.arange(1, 10 + 1, 0.5).reshape((5, 4))
08: a4 = np.linspace(1, 10 + 1, 20).reshape((2, 5, 2))
09:
10: show("a1:", a1)
11: show("a2:", a2)
12: show("a3:", a3)
13: show("a4:", a4)
```
```
(12,)
```
```
(3,4)
```
```
(1,1,12)
```
```
(1,2,6)
```
```
(2,2,3)
```
```
memory (12 elements)
```
```
shape
```

## 기본 연산

#### ▪ 산술연산과 관계연산

- 산술연산과관계연산은행렬요소사이1:1로적용되며관계연산은불결
    - 피연산자는배열또는스칼라값으로둘다배열일때는shape와size가같아야함
       - 스칼라값은같은크기및모양의배열로브로드캐스딩broadcasting한후연산수행
    - 산술연산은연산자(+, -, *, /, %, **)와함수(numpy 모듈의add,subtract,multiply,divide,mod, power)모두지원. *는일반적인행렬곱셈이아님
    - 관계연산의결과는불배열

```
01: import numpy as np
02:
03: show = lambda m, o : print(m, o.shape, o.dtype, '\n', o, '\n')
04:
05: a1 = np.array([10, 20, 30, 40, 50, 60])
06: a2 = np.linspace(5, 6, a1.size)
07:
08: b1 = a1 -a
09: b2 = np.power(b1, 2) # b1**[2, 2, 2, 2, 2, 2]
10: b3 = np.sin(a1) * 10 # np.sin(a1) * [10, 10, 10, 10, 10, 10]
11: b4 = a1 % a
12: b5 = b1 < 25 # b1 < [25, 25, 25, 25, 25, 25]
13:
14: show("a1:", a1) ; show("a2:", a2)
15: show("b1:", b1) ; show("b2:", b2) ; show("b3:", b3) ; show("b4:", b4) ; show("b5:", b5)
```

### 기본 연산

#### ▪ 브로드캐스팅

- 스칼라값이나벡터를배열과연산할때이를배열의share와같도록확장한후기존데이터복사
    - 배열과스칼라값사이연산: 스칼라를배열의share로확장한후스칼라값복사
    - 벡터와벡터사이연산: 벡터N, M에대해양쪽다배열의N x M shape로확장한후행또는열단위요소복사
    - 배열과벡터사이연산: 배열의마지막축크기와벡터의크기가같을때, 벡터를배열의shape로확장한후백터요소복사
    - 크기가다른배열과배열사이연산: 두배열의마지막축부터차례로비교해축의크기가같거나 1 일때,양쪽배열을큰축기준으로확장한후배열요소복사

```
01: import numpy as np
02:
03: show = lambda m, o : print(m, o.shape, o.dtype, '\n', o, '\n')
04:
05: a1 = np.linspace(1, 12, 12).reshape((3, 4))
06: a2 = np.arange(1, 5)
07: a3 = a2.reshape((4, 1))
08: a4 = a1.reshape((3, 1, 4))
09:
10: b1 = a1 + a
11: b2 = a2 + a
12: b3 = a1 + a
13:
14: show("a1:", a1) ; show("a2:", a2) ; show("a3:", a3)
15: show("b1:", b1) ; show("b2:", b2) ; show("b3:", b3)
```
```
n
```

## 인덱싱과 슬라이싱

#### ▪ 리스트처럼NumPy 배열도 인덱스로요소에 접근하고원하는 부분만 잘라내는슬라이싱 가능

- 리스트와다른점은슬라이싱은원본배열의데이터를참조하는새로운배열이므로슬라이싱된배열을수정하면원본배열도함께수정됨
- 1 차원배열의슬라이싱은[[start]:[end]:[step]]
    - 인덱스i가start일때i < end 동안i += step단위로이동하며요소접근. i가음수면마지막요소부터역순으로접근
    - start를생략하면0, end를생략하면-1(마지막요소), step을생략하면 1

```
01: import numpy as np
02:
03: show = lambda m, o : print(m, o.shape, o.dtype, '\n', o, '\n')
04:
05: a1 = np.arange(1, 10+1)**
06: a2 = a1[2:9]
07:
08: show("a1", a1) ; show("a2", a2)
09:
10: a1[3] = a1[1] + a1[2]
11: a2[:5:2] = 10_
12:
13: for i in range(len(a1)):
14: print(a1[(i+1)*-1], end=', ')
15: print()
```
```
original
```
```
slicing
```
```
memory
0 1 2 3 4 5 6 7 8 9
```
```
0 1 2 3 4 5 6
```

### 인덱싱과슬라이싱

- 다차원배열은축당하나의인덱스를가질수있으며인덱스는쉼표로구분➡[x, y]
    - 축수보다적은인덱스를제공하면누락된인덱스는슬라이스로간주
    - 점(...)은완전한인덱싱에필요한만큼의콜론을나타냄
       - 5 차원배열x에대해
          - x[1, 2, ...] == x[1, 2, :, :, :]
          - x[..., 3] == x[:, :, :, :, 3]
          - x[4, ..., 5, :] = x[4, :, :, 5, :]
    - 다차원배열에대한반복은첫번째축에대해수행
       - 반복자인flat 속성을이용하면배열의모든요소에접근할수있음
- 슬라이싱할때추가연산을통해브로드캐스팅이발생하면사본복사

```
01: import numpy as np
02:
03: show = lambda m, o : print(m, o.shape, o.dtype, '\n', o, '\n')
04:
05: a1 = np.fromfunction(lambda x, y, z: x + y + z, (2, 5, 4), dtype=int)
06: a2 = a1[:, 1::2, :3] * 10 # a2는새로운배열
07:
08: a2[1, ...] = - 1
09:
10: show("a1", a1)
11: for array in a2: # forelementina2.flat
12: print("out:\n", array) # print(element, end=', ')
```
```
slicing
```
```
broadcasting
```
```
copy
```
```
*
```

## 서로 다른 배열 쌓기

#### ▪ 서로 다른축을따라 여러 배열을 수평또는수직으로 쌓은 새로운배열생성

- vstack(tup), hstack(tub): 세로(행방향), 가로(열방향)순서로쌓음
    - tup: 배열시퀀스로배열모양은첫번째축을제외하고모두동일해야함. 1차원배열은길이가같아야함
- concatenate((a1, a2, ...), axis=0, ...): 기존축을따라배열시퀀스결합
    - a1, a2, ...: 배열시퀀스로첫번째축의차원을제외하고동일한모양을가져야함
    - axis: 배열이결합될축. None으로설정하면 1 차원으로병합

```
01: import numpy as np
02:
03: show = lambda m, o : print(m, o.shape, o.dtype, '\n', o, '\n')
04:
05: a1 = np.fromfunction(lambda x, y, z: x + y + z, (2, 5, 4), dtype=int)
06: a2 = np.arange(1, (1*5*4)+1).reshape((1, 5, 4)) * 10
07:
08: a3 = np.vstack((a1[0, ...], a2[0, ...]))
09: a4 = np.hstack((a1[1, ...], a2[0, ...]))
10: a5 = np.concatenate((a1, a2), 0)
11:
12: show("a1", a1) ; show("a2", a2)
13: show("a3", a3) ; show("a4", a4) ; show("a5", a5)
```
```
hstack
```
```
vstack
```
```
concatenate
```
```
original
```

## 작은 배열로 분할

#### ▪ 하나의배열은 여러 개의작은배열로 분할될수 있음

- vsplit(ary, indices_or_sections): 배열을세로로(행방향) 첫번째축을따라여러하위배열로분할
    - ary는배열, indices_or_sections는분할개수또는분할위치지정스퀀스또는배열
    - 반환은튜플배열
- hsplit(ary, indices_or_sections): 배열을가로로(열 방향) 두번째축을따라여러 하위배열로분할

```
01: import numpy as np
02:
03: show = lambda m, o : print(m, o.shape, o.dtype, '\n', o, '\n')
04:
05: a = np.arange(24).reshape(3, 2, 4)
06:
07: b1, b2, b3 = np.vsplit(a, 3)
08: b4, b5 = np.vsplit(a, np.array([1]))
09:
10: c1, c2 = np.hsplit(a, 2)
11:
12: show("a", a)
13: show("b1", b1) ; show("b2", b2) ; show("b3", b3) ; show("b4", b4) ; show("b5", b5)
14: show("c1", c1) ; show("c2", c2)
```
```
vsplit (axis=0)
```
```
hsplit (axis=1)
```
```
original
```

## 참조와 복사

#### ▪ 배열에 대한연산결과로 만들어지는새로운배열은 기존 배열의참조또는 복사

- 대입문에의한단순할당과함수의인자전달은객체참조
- 얕은복사: view() 메소드나슬라이싱은동일한데이터를새로운관점에서보여주는새로운배열객체를만듦
- 깊은복사: copy() 메소드는배열과해당데이터의전체사본을만듦

```
01: import numpyas np
02:
03: show = lambda m, o : print(m, o.shape, o.dtype, '\n', o, '\n')
04:
05: def foo(n):
06: return id(n) # id()는변수에저장된참조값반환
07:
08: a = np.arange(20).reshape(4, 5)
09: b = a
10: c= a.view()
11:
12: print(b is a, id(a) == foo(a))
13: print(c is a, c.flags.owndata) # .flags.owndata 데이터유무
14:
```
```
15: d = c.reshape((2, 10))
16: d[1, 0] = 1_000_
16 : show("d", d) ; show("a", a)
17:
18: s = a[: 1:3]
19: s[:] = - 1
20: show("a", a)
21:
22 : e = a.copy()
23: print(e is a)
24: d[1, 2] = 2_000_
25 : show("e", e) ; show("a", a)
26:
27: m = np.arange(1_000_000)
28: n = m[:100].copy()
29: del m
```

## 수학 함수

#### ▪ 삼각 함수

- numpy.pi: 𝜋 상수
- numpy.sin(x), numpy.cos(x), numpy.tan(x) : x에대해sine, cosine, tangent 계산. x는라디안값또는배열
- numpy.arcsin(x), numpy.arccos(x), numpy.arctan(x): x에대해sine, cosine, tangent의역함수계산
- numpy.radians(x), numpy.degrees(x): x에대해 디그리를 라디안 또는 라디안을 디그리로 변환

```
01: import numpyas np
02:
03: show = lambda m, o : print(m, o.shape, o.dtype, '\n', o, '\n')
04:
05: print(np.pi)
06: print(np.sin(30 * np.pi/ 180), np.cos(3 * np.pi/ 2), end='\n\n’)
07:
08: a1 = np.degrees([np.pi/4, 3*np.pi/4, 5*np.pi/4, 7*np.pi/4])
09: a2 = np.radians(a1)
10: a3 = np.sin(a1 * np.pi/ 180)
11: a4 = np.cos(a2)
12:
13: show("a1", a1) ; show("a2", a2) ; show("a3", a3) ; show("a4", a4)
```

### 수학 함수

#### ▪ 지수와로그

- numpy.ℯ: 지수(자연로그밑)상수(약2.718281...)
- numpy.exp(x): x에대해𝒴= ℯ𝓍인지수(자연로그역) 계산
- numpy.log(x): x에대해밑이ℯ인자연로그(지수함수역) 계산
    - 밑이 10 인상용로그는numpy.log10(x)

```
01: import numpy as np
02:
03: show = lambda m, o : print(m, o.shape, o.dtype, '\n', o, '\n')
04:
05: d1 = np.exp(1)
06: a1 = np.exp([i for i in range(1, 10 + 1, 2)])
07: d2 = np.log(np.e)
08: a2 = np.log(a1)
09:
10: print("d1:", d1)
11: print("d2:", d2)
12:
13: show("a1", a1)
14: show("a2", a2)
```

### 수학 함수

#### ▪ 기타 함수

- numpy.abs(x), numpy.absolute(x): x에대해절대값계산
    - abs()는정수한정
- numpy.ceil(x): x에대해 x보다작은정수중가장큰값계산
- numpy.floor(x): x에대해x보다큰정수중가장작은값계산
- numpy.sqrt(x): x에대해 제곱근계산

```
01: import numpy as np
02:
03: show = lambda m, o : print(m, o.shape, o.dtype, '\n', o, '\n')
04:
05: a1 = np.array([-2.5, 1, -1.7, 5.1, 4.0, -0.2, 6.8])
06: a2 = np.absolute(a1)
07: a3 = np.ceil(a1)
08: a4 = np.floor(a1)
09: a5 = np.sqrt(a2)
10:
11: show("a1", a1)
12: show("a2", a2)
13: show("a3", a3)
14: show("a4", a4)
15: show("a5", a5)
```

## 선형 대수

#### ▪ 전치 행렬transposed matrix

- 행과열을서로맞바꾼행렬로numpy 모듈이나ndarray객체의transpose() 또는T 프로퍼티사용

```
01: import numpy as np
02:
03: show = lambda m, o : print(m, o.shape, o.dtype, '\n', o, '\n')
04:
05: a1 = np.array([1, 2, 3, 4])
06: a2 = np.array([[1, 2, 3], [4, 5, 6]])
07: a3 = np.linspace(10, 120, 12).reshape((3, 2, 2))
08:
09: b1 = a1.T
10: b2 = a2.transpose()
11: b3 = np.transpose(a3)
12:
13: show("a1:", a1) ; show("a2:", a2) ; show("a3:", a3)
14: show("b1:", b1) ; show("b2:", b2) ; show("b3:", b3)
```

### 선형 대수

#### ▪ 행렬곱셈

- 두행렬에대한곱셈은 연산자@ 또는numpy 모듈이나ndarray객체의dot()사용
    - 첫번째배열행의요소수와두번째배열열의요소수는같아야함

```
01: import numpy as np
02:
03: show = lambda m, o : print(m, o.shape, o.dtype, '\n', o, '\n')
04:
05: a1 = np.array([[2, -1, 5], [-5, 2, 2], [2, 1, 3]])
06:
07: a2 = np.array([[0, 1, 0], [1, 0, 1], [1, 1, 0]])
08: a3 = np.array([1, -1, 1])
09: a4 = np.array([1, 0, 1]).reshape((3,1))
10:
11: b1 = np.dot(a1, a2)
12: b2 = a1.dot(a3)
13: b3 = a1 @ a4
14:
15: show("a1:", a1) ; show("a2:", a2) ; show("a3:", a3) ; show("a4:", a4)
16: show("b1:", b1) ; show("b2:", b2) ; show("b3:", b3)
```

### 선형 대수

#### ▪ 역행렬과방정식해

- 역행렬은(n x n) 정방행렬에 대한곱셈결과가항등원인단위행렬을만드는행렬
- numpy.linalg.inv(a): 배열의역행렬계산
- numpy.linalg.solve(a, b): 연립방정식해계산

```
01: import numpy as np
02:
03: show = lambda m, o : print(m, o.shape, o.dtype, '\n', o, '\n')
04:
05: a1 = np.random.randint(10, size=(3, 3))
06: a2 = np.linalg.inv(a1)
07: a3 = np.array([[2, 3], [5, 6]])
08: a4 = np.array([4, 7])
09: a5 = np.linalg.solve(a3, a4)
10:
11: show("a1", a1) ; show("a2", a2)
12: show("a3", a3) ; show("a4", a4) ; show("a5", a5)
```

```
01: import numpy as np
02:
03: show = lambda m, o : print(m, o.shape, o.dtype, '\n', o, '\n')
04:
05: A = np.array([[2, 3], [5, 6]])
06: B = np.array([4, 7])
07: C = np.linalg.inv (A)
08: D = np.dot(C, B)
10:
11: show(“solve", D)
```

## 랜덤 샘플

##### 에 대해값이나 요소를 [𝑎,𝑏)에서균등배치

- numpy.random.random(size=None): [0.0, 1.0) 범위실수
    - size는생략하거나스칼라값, 2차원이상은shape로반환은스칼라값또는배열
- numpy.random.uniform(low=0.0, high=1.0, size=None): [low, high) 범위실수타입
- numpy.random.randint(low, high=None, size=None, dtype=int): [low,high)범위정수타입
    - high를생략하면low = 0, high = low

```
01: import numpy as np
02
03: show = lambda m, o : print(m, o.shape, o.dtype, '\n', o, '\n')
04:
05: a1 = np.random.random(6)
06: a2 = np.random.random((2, 3))
07: a3 = np.random.uniform(1.0, 2.0, (2, 3))
08: d = np.random.randint(10)
09: a4 = np.random.randint(1, 10, (2, 3))
10:
11: show("a1", a1) ; show("a2", a2) ; show("a3", a3)
12: print("d:", d) ; show("a4", a4)
```

### 램덤 샘플

- numpy.random.shuffle(x): 시퀀스x의내용을 섞어서수정. 다차원배열은첫번째축기준
- numpy.random.choice(a, size=None, replace=True, p=None): 주어진 1 차원배열에서무작위샘플생성
    - replace는선택값재사용유무, p는a항목선택확률
- numpy.seed(seed=None): 의사난수제너레이터에서사용할시드값설정

```
01: import numpy as np
02
03: show = lambda m, o : print(m, o.shape, o.dtype, '\n', o, '\n')
04:
05: np.random.seed(1)
06:
07: a1 = np.arange(9)
08: np.random.shuffle(a1)
09:
10: a2 = np.arange(3*3).reshape((3, 3))
11: np.random.shuffle(a2)
12:
13: a3 = np.random.choice([4, 2, 6, 1], 3, False, [0.4, 0.2, 0.3, 0.1])
14:
15: show("a1", a1)
16: show("a2", a2)
17: show("a3", a3)
```

### 램덤 샘플

#### ▪ 정규 분포normal distribution

- 가우스분포의확률밀도𝒫 𝓍 =

```
1
2 𝜋𝜎^2
```
###### ℯ

```
−(𝓍−𝜇)
```
```
2
```
###### 2 𝜎^2 에대해𝜇는평균, 𝜎는표준편차,𝜎^2 는분산

- 평균에서최대치이며, 표준편차와함께확산되며증가함
- 멀리떨어져있는것보다평균에가까운샘플을반환할확률이높음
- numpy.random.normal(loc=0.0, scale=1.0, size=None): 정규분포
- loc은분표의평균(중앙), scale은양의값으로표준편차(확산또는너비), size는스칼라또는shape
- numpy.random.standard_normal(size=None): 표준정규분포standard normal (평균=0, 표준편차=1). 무작위샘플은N 𝜇,𝜎^2

```
01: import numpy as np
02:
03: show = lambda m, o : print(m, o.shape, o.dtype, '\n', o, '\n')
04:
05: mu, sigma = 0, 0.1
06: a1 = np.random.normal(mu, sigma, 50)
07: a2 = np.random.normal(4, 1.7, size=(3, 4)) # N(4, 2.89)
08: a3 = np.random.standard_normal(50)
09: a4 = 4 + 1.7 * np.random.standard_normal((3,4)) # N(4, 2.89)
10:
11: show("a1:", a1) ;
12: print("mean and standard deviation:", abs(mu -np.mean(a1)), sigma -np.std(a1, ddof=1), end="\n\n")
13:
14: show("a2:", a2) ; show("a3", a3) ; show("a4", a4)
```

## 파일 저장 및 로드

#### ▪ 데이터의 재사용을위해ndarray의배열요소를 파일로저장하거나파일로부터 데이터를읽어 ndarray 객체로변환

- 바이너리형식으로확장자는.npy
    - numpy.save(fname, arr) : 1개배열을파일로저장
       - file은확장자생략가능
    - numpy.savez(fname, *args, **kwargs) : n개의배열을파일로저장
       - kwargs는배열이름을키, 배열을값으로나열한키워드인자
    - numpy.load(fname): .npy 파일에서배열로드. 압축된바이너리라면압축해제
       - 파일명은확장자까지모두포함해야하며, 반환객체는ndarray와호환되는numpy.lib.npyio.NpzFile
    - numpy.lib.npyio.NpzFile.close(): 파일닫기
       - 파일을 닫으면더이상배열접근불가
- 압축된바이너리파일
    - numpy.savez_compressed(fname, *args,**kwargs): 압축후저장
- 텍스트파일(엑셀등과호환) 형식
    - numpy.savetxt(fname, x): 파일저장
       - x는 1 차원또는 1 차원배열
    - numpy.loadtxt(fname): 파일로드


### 파일 저장 및로드

```
01: import numpy as np
02:
03: show = lambda m, o : print(m, o.shape, o.dtype, '\n', o, '\n')
04:
05: a1 = np.arange(360+1)
06: a2 = np.sin(a1 * np.pi / 180)
07:
08: show("a1", a1)
09: show("a2", a2)
10:
11: np.savez_compressed("sin_sample", x=a1, y=a2)
12:
13: a3 = np.load("sin_sample.npz")
14:
15: print((a3['x'] == a1).all()) # a3[‘x’]==a1의결과는불배열이며, all()은전체요소가같은지검사
16: print((a3['y'] == a2).all())
17:
18: a3.close()
```

<details>
<summary>100 numpy exercises</summary>

#### 1. Import the numpy package under the name `np` (★☆☆)

#### 2. Print the numpy version and the configuration (★☆☆)

#### 3. Create a null vector of size 10 (★☆☆)

#### 4. How to find the memory size of any array (★☆☆)

#### 5. How to get the documentation of the numpy add function from the command line? (★☆☆)

#### 6. Create a null vector of size 10 but the fifth value which is 1 (★☆☆)

#### 7. Create a vector with values ranging from 10 to 49 (★☆☆)

#### 8. Reverse a vector (first element becomes last) (★☆☆)

#### 9. Create a 3x3 matrix with values ranging from 0 to 8 (★☆☆)

#### 10. Find indices of non-zero elements from [1,2,0,0,4,0] (★☆☆)

#### 11. Create a 3x3 identity matrix (★☆☆)

#### 12. Create a 3x3x3 array with random values (★☆☆)

#### 13. Create a 10x10 array with random values and find the minimum and maximum values (★☆☆)

#### 14. Create a random vector of size 30 and find the mean value (★☆☆)

#### 15. Create a 2d array with 1 on the border and 0 inside (★☆☆)

#### 16. How to add a border (filled with 0's) around an existing array? (★☆☆)

#### 17. What is the result of the following expression? (★☆☆)
```python
0 * np.nan
np.nan == np.nan
np.inf > np.nan
np.nan - np.nan
np.nan in set([np.nan])
0.3 == 3 * 0.1
```

#### 18. Create a 5x5 matrix with values 1,2,3,4 just below the diagonal (★☆☆)

#### 19. Create a 8x8 matrix and fill it with a checkerboard pattern (★☆☆)

#### 20. Consider a (6,7,8) shape array, what is the index (x,y,z) of the 100th element? (★☆☆)

#### 21. Create a checkerboard 8x8 matrix using the tile function (★☆☆)

#### 22. Normalize a 5x5 random matrix (★☆☆)

#### 23. Create a custom dtype that describes a color as four unsigned bytes (RGBA) (★☆☆)

#### 24. Multiply a 5x3 matrix by a 3x2 matrix (real matrix product) (★☆☆)

#### 25. Given a 1D array, negate all elements which are between 3 and 8, in place. (★☆☆)

#### 26. What is the output of the following script? (★☆☆)
```python
# Author: Jake VanderPlas

print(sum(range(5),-1))
from numpy import *
print(sum(range(5),-1))
```

#### 27. Consider an integer vector Z, which of these expressions are legal? (★☆☆)
```python
Z**Z
2 << Z >> 2
Z <- Z
1j*Z
Z/1/1
Z<Z>Z
```

#### 28. What are the result of the following expressions? (★☆☆)
```python
np.array(0) / np.array(0)
np.array(0) // np.array(0)
np.array([np.nan]).astype(int).astype(float)
```

#### 29. How to round away from zero a float array ? (★☆☆)

#### 30. How to find common values between two arrays? (★☆☆)

#### 31. How to ignore all numpy warnings (not recommended)? (★☆☆)

#### 32. Is the following expressions true? (★☆☆)
```python
np.sqrt(-1) == np.emath.sqrt(-1)
```

#### 33. How to get the dates of yesterday, today and tomorrow? (★☆☆)

#### 34. How to get all the dates corresponding to the month of July 2016? (★★☆)

#### 35. How to compute ((A+B)*(-A/2)) in place (without copy)? (★★☆)

#### 36. Extract the integer part of a random array of positive numbers using 4 different methods (★★☆)

#### 37. Create a 5x5 matrix with row values ranging from 0 to 4 (★★☆)

#### 38. Consider a generator function that generates 10 integers and use it to build an array (★☆☆)

#### 39. Create a vector of size 10 with values ranging from 0 to 1, both excluded (★★☆)

#### 40. Create a random vector of size 10 and sort it (★★☆)

#### 41. How to sum a small array faster than np.sum? (★★☆)

#### 42. Consider two random array A and B, check if they are equal (★★☆)

#### 43. Make an array immutable (read-only) (★★☆)

#### 44. Consider a random 10x2 matrix representing cartesian coordinates, convert them to polar coordinates (★★☆)

#### 45. Create random vector of size 10 and replace the maximum value by 0 (★★☆)

#### 46. Create a structured array with `x` and `y` coordinates covering the [0,1]x[0,1] area (★★☆)

#### 47. Given two arrays, X and Y, construct the Cauchy matrix C (Cij =1/(xi - yj)) (★★☆)

#### 48. Print the minimum and maximum representable value for each numpy scalar type (★★☆)

#### 49. How to print all the values of an array? (★★☆)

#### 50. How to find the closest value (to a given scalar) in a vector? (★★☆)

#### 51. Create a structured array representing a position (x,y) and a color (r,g,b) (★★☆)

#### 52. Consider a random vector with shape (100,2) representing coordinates, find point by point distances (★★☆)

#### 53. How to convert a float (32 bits) array into an integer (32 bits) in place?

#### 54. How to read the following file? (★★☆)
```
1, 2, 3, 4, 5
6,  ,  , 7, 8
 ,  , 9,10,11
```

#### 55. What is the equivalent of enumerate for numpy arrays? (★★☆)

#### 56. Generate a generic 2D Gaussian-like array (★★☆)

#### 57. How to randomly place p elements in a 2D array? (★★☆)

#### 58. Subtract the mean of each row of a matrix (★★☆)

#### 59. How to sort an array by the nth column? (★★☆)

#### 60. How to tell if a given 2D array has null columns? (★★☆)

#### 61. Find the nearest value from a given value in an array (★★☆)

#### 62. Considering two arrays with shape (1,3) and (3,1), how to compute their sum using an iterator? (★★☆)

#### 63. Create an array class that has a name attribute (★★☆)

#### 64. Consider a given vector, how to add 1 to each element indexed by a second vector (be careful with repeated indices)? (★★★)

#### 65. How to accumulate elements of a vector (X) to an array (F) based on an index list (I)? (★★★)

#### 66. Considering a (w,h,3) image of (dtype=ubyte), compute the number of unique colors (★★☆)

#### 67. Considering a four dimensions array, how to get sum over the last two axis at once? (★★★)

#### 68. Considering a one-dimensional vector D, how to compute means of subsets of D using a vector S of same size describing subset  indices? (★★★)

#### 69. How to get the diagonal of a dot product? (★★★)

#### 70. Consider the vector [1, 2, 3, 4, 5], how to build a new vector with 3 consecutive zeros interleaved between each value? (★★★)

#### 71. Consider an array of dimension (5,5,3), how to mulitply it by an array with dimensions (5,5)? (★★★)

#### 72. How to swap two rows of an array? (★★★)

#### 73. Consider a set of 10 triplets describing 10 triangles (with shared vertices), find the set of unique line segments composing all the  triangles (★★★)

#### 74. Given a sorted array C that corresponds to a bincount, how to produce an array A such that np.bincount(A) == C? (★★★)

#### 75. How to compute averages using a sliding window over an array? (★★★)

#### 76. Consider a one-dimensional array Z, build a two-dimensional array whose first row is (Z[0],Z[1],Z[2]) and each subsequent row is  shifted by 1 (last row should be (Z[-3],Z[-2],Z[-1]) (★★★)

#### 77. How to negate a boolean, or to change the sign of a float inplace? (★★★)

#### 78. Consider 2 sets of points P0,P1 describing lines (2d) and a point p, how to compute distance from p to each line i (P0[i],P1[i])? (★★★)

#### 79. Consider 2 sets of points P0,P1 describing lines (2d) and a set of points P, how to compute distance from each point j (P[j]) to each line i (P0[i],P1[i])? (★★★)

#### 80. Consider an arbitrary array, write a function that extract a subpart with a fixed shape and centered on a given element (pad with a `fill` value when necessary) (★★★)

#### 81. Consider an array Z = [1,2,3,4,5,6,7,8,9,10,11,12,13,14], how to generate an array R = [[1,2,3,4], [2,3,4,5], [3,4,5,6], ..., [11,12,13,14]]? (★★★)

#### 82. Compute a matrix rank (★★★)

#### 83. How to find the most frequent value in an array?

#### 84. Extract all the contiguous 3x3 blocks from a random 10x10 matrix (★★★)

#### 85. Create a 2D array subclass such that Z[i,j] == Z[j,i] (★★★)

#### 86. Consider a set of p matrices with shape (n,n) and a set of p vectors with shape (n,1). How to compute the sum of of the p matrix products at once? (result has shape (n,1)) (★★★)

#### 87. Consider a 16x16 array, how to get the block-sum (block size is 4x4)? (★★★)

#### 88. How to implement the Game of Life using numpy arrays? (★★★)

#### 89. How to get the n largest values of an array (★★★)

#### 90. Given an arbitrary number of vectors, build the cartesian product (every combinations of every item) (★★★)

#### 91. How to create a record array from a regular array? (★★★)

#### 92. Consider a large vector Z, compute Z to the power of 3 using 3 different methods (★★★)

#### 93. Consider two arrays A and B of shape (8,3) and (2,2). How to find rows of A that contain elements of each row of B regardless of the order of the elements in B? (★★★)

#### 94. Considering a 10x3 matrix, extract rows with unequal values (e.g. [2,2,3]) (★★★)

#### 95. Convert a vector of ints into a matrix binary representation (★★★)

#### 96. Given a two dimensional array, how to extract unique rows? (★★★)

#### 97. Considering 2 vectors A & B, write the einsum equivalent of inner, outer, sum, and mul function (★★★)

#### 98. Considering a path described by two vectors (X,Y), how to sample it using equidistant samples (★★★)?

#### 99. Given an integer n and a 2D array X, select from X the rows which can be interpreted as draws from a multinomial distribution with n degrees, i.e., the rows which only contain integers and which sum to n. (★★★)

#### 100. Compute bootstrapped 95% confidence intervals for the mean of a 1D array X (i.e., resample the elements of an array with replacement N times, compute the mean of each sample, and then compute percentiles over the means). (★★★)

</details>
