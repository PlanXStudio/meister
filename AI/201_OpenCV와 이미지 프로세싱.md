# OpenCV와 이미지 프로세싱

## 라이브러리 설치
```python
pip install opencv-python
pip install mediapipe
pip install cvzone
```

**결과 확인**
```python
python -c 'import cv2; print(cv2.__version__)'
```

[OpenCV 강좌](https://opencv-python.readthedocs.io/en/latest/)  
[MediaPipe 예제](https://developers.google.com/mediapipe/solutions/vision/hand_landmarker)  
[cvzone 예제](https://github.com/cvzone/cvzone/tree/master/Examples)  

## 이미지 데이터
OpenCV의 이미지 데이터는 [y, x, [b, g, r]] 형태의 Numpy 배열입니다.
- y: 행 집합
- x: 열 집합
- [b, g, r]: 채널 집합을 나타내는 배열로, 일반적으로는 Red, Green, Blue 순이지만 OpenCV는 **Blue, Green, Red**

### Numpy로 이미지 데이터 만들기
```python
import cv2
import numpy as np

gray = np.linspace(0, 255, num=90000, endpoint=True, retstep=False, dtype=np.uint8).reshape(300, 300, 1)
color = np.zeros((300, 300, 3), np.uint8)
color[0:150, :, 0] = gray[0:150, :, 0]
color[:, 150:300, 2] = gray[:, 150:300, 0]

cv2.imshow("gray", gray)
cv2.imshow("color", color)
cv2.waitKey(0)
cv2.destroyAllWindows()
```

### 파일로부터 이미지 데이터 얻기
```python
import cv2

img_file = "<your_image_path>/<file>.jpg"
img = cv2.imread(img_file)

cv2.imshow('ImageView', img)
cv2.waitKey(0)
cv2.destroyAllWindows()
```

### 카메라로부터 실시간 이미지 데이터 얻기
**카메라 캡처 객체 생성**
```python
import cv2

cap = cv2.VideoCapture(0)
```

**해상도 설정**
```python
cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)
cap.set(cv2.CAP_PROP_FRAME_WIDTH, 640)
```

**이미지 읽기**
```python
while True:
    success, frame = cap.read()
    if not success:
        break

    cv2.imshow("Camera", frame)
    
    key = chr(cv2.waitKey(1) & 0xFF)
    if key == 'q':
        cap.release()
        cv2.destroyAllWindows()
```

**전체 코드**
```python
import cv2

cap = cv2.VideoCapture(0)

cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)
cap.set(cv2.CAP_PROP_FRAME_WIDTH, 640)

while True:
    success, frame = cap.read()
    if not success:
        break

    cv2.imshow("CameraPreview", frame)
    
    key = chr(cv2.waitKey(1) & 0xFF)
    if key == 'q':
        cap.release()
        cv2.destroyAllWindows()
```

**프로세싱 패턴 적용**
```python
import sys
import cv2

cap = None

def setup():
    global cap

    cap = cv2.VideoCapture(0)

    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)
    cap.set(cv2.CAP_PROP_FRAME_WIDTH, 640)

def cleanup():
    cap.release()
    cv2.destroyAllWindows()
    sys.exit()

def doProcessing(frame):
    #TODO: Image Processing

    return frame

def loop():
    _, frame = cap.read()
    frame = doProcessing(frame)
    cv2.imshow("Camera", frame)
    
    key = chr(cv2.waitKey(1) & 0xFF)
    if key == 'q':
        cleanup()

def main():
    setup()
    while True:
        loop()

if __name__ == '__main__':
    main()
```

## 카메라 응용

### 일정 시간마다 사진찍기
```python
INTERVAL = 5

cap = None
tick_count = 0
file_count = 0

def setup():
    global cap, tick_count

    cap = cv2.VideoCapture(0)

    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)
    cap.set(cv2.CAP_PROP_FRAME_WIDTH, 640)

    tick_count = time.time()

def doProcessing(frame)
    global tick_count, file_count

    if time.time() - tick_count > INTERVAL:
        cv2.imwrite(f"./cap{file_count:03d}.jpg", frame)
        file_count += 1
        tick_count = time.time()

    return frame
```

### 이미지 합성
> 카메라 이미지에 합성할 배경이 투명한 mask.png 파일 준비

```python
import cvzone

mark_file = "<your_image_path>/<file>.png"
cap = None
watermark = None

def setup():
    global cap, watermark

    cap = cv2.VideoCapture(0)
    
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)
    cap.set(cv2.CAP_PROP_FRAME_WIDTH, 640)

    watermark = cv2.imread(mark_file, cv2.IMREAD_UNCHANGED)

def doProcessing(frame):
    frame = cvzone.overlayPNG(frame, watermark, pos=[20, 340])
    return frame
```

### 손 동작 인식
**손 랜드마크** 
![손 랜드마크](https://developers.google.com/static/mediapipe/images/solutions/hand-landmarks.png)

**손 동작 추적**
```python
from cvzone.HandTrackingModule import HandDetector

cap = None
detector = None

def setup():
    global cap, detector

    cap = cv2.VideoCapture(0)
    
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 480)
    cap.set(cv2.CAP_PROP_FRAME_WIDTH, 640)

    detector = HandDetector(maxHands=1, detectionCon=0.8)
    
def doProcessing(frame):
    hands, frame = detector.findHands(frame, draw=True, flipType=True)

    if hands:
        hand = hands[0]
        lm_list = hand["lmList"]
        x, y, w, h = hand["bbox"]
        center = hand['center']
        hand_type = hand["type"]

        fingers = detector.fingersUp(hand)
        length, info, frame = detector.findDistance(
            lm_list[8][0:2], 
            lm_list[12][0:2], 
            frame, 
            color=(255, 0, 255),
            scale=10)
        
        print(x, y, w, h, center, hand_type, fingers, length)
        
    return frame
```
