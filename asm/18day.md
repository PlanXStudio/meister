# 영상 처리 응용

## 라이브러리 설치
- cvzone(opencv 포함), mediapipe
```python
pip install cvzone mediapipe
```

## OpenCV로 카메라 데이터 처리 
[OpenCV 참고 강좌](https://opencv-python.readthedocs.io/en/latest/)

### 기본 틀
```python
import cv2

cap = cv2.VideoCapture(0)

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

### 함수 구조 기본
```python
import cv2

def main():
    cap = cv2.VideoCapture(0)

    while True:
        success, frame = cap.read()
        if not success:
            break
        
        cv2.imshow("Camera", frame)
        
        key = chr(cv2.waitKey(1) & 0xFF)
        if key == 'q':
            cap.release()
            cv2.destroyAllWindows()

if __name__ == '__main__':
    main()
```

### 프로세싱 패턴 적용 기본
```python
import sys
import cv2

cap = None

def setup():
    global cap
    cap = cv2.VideoCapture(0)

def doProcessing(frame):
    return frame

def loop():
    success, frame = cap.read()
    frame = doProcessing(frame)
    cv2.imshow("Camera", frame)
    
    key = chr(cv2.waitKey(1) & 0xFF)
    if key == 'q':
        cap.release()
        cv2.destroyAllWindows()
        sys.exit()

def main():
    setup()
    while True:
        loop()

if __name__ == '__main__':
    main()
```

### 일정 시간마다 사직찍기
```python
import sys
import time
import cv2

cap = None
tick_count = None
file_count = 0

import sys
import cv2

cap = None

def setup():
    global cap, tick_count
    cap = cv2.VideoCapture(0)
    tick_count = time.time()

def doProcessing(frame)
    global tick_count, file_count

    if time.time() - tick_count > 5:
        cv2.imwrite(f"./cap{file_count:03d}.jpg", frame)
        file_count += 1
        tick_count = time.time()

    return frame

def loop():
    success, frame = cap.read()
    frame = doProcessing(frame)
    cv2.imshow("Camera", frame)
    
    key = chr(cv2.waitKey(1) & 0xFF)
    if key == 'q':
        cap.release()
        cv2.destroyAllWindows()
        sys.exit()

def main():
    setup()
    while True:
        loop()

if __name__ == '__main__':
    main()
```

## cvzone 라이브러리
- cvzone Example (https://github.com/cvzone/cvzone/tree/master/Examples)
- MediaPipe (https://developers.google.com/mediapipe/solutions/vision/hand_landmarker)

### 이미지 합성
- asm.png 파일 준비

```python
import sys
import cv2
import cvzone

cap = None
watermark = None

def setup():
    global cap, watermark
    cap = cv2.VideoCapture(0)
    watermark = cv2.imread("./pc/asm.png", cv2.IMREAD_UNCHANGED)
    
def doProcessing(frame):
    frame = cvzone.overlayPNG(frame, watermark, pos=[20, 340])
    return frame

def loop():
    success, frame = cap.read()
    frame = doProcessing(frame)
    cv2.imshow("Camera", frame)
    
    key = chr(cv2.waitKey(1) & 0xFF)
    if key == 'q':
        cap.release()
        cv2.destroyAllWindows()
        sys.exit()

def main():
    setup()
    while True:
        loop()

if __name__ == '__main__':
    main()
```

### 손 동작 인식
**손 랜드마크** 
![손 랜드마크](https://developers.google.com/static/mediapipe/images/solutions/hand-landmarks.png)

**손 동작 추적**
```python
import sys
import cv2
from cvzone.HandTrackingModule import HandDetector

cap = None
detector = None

def setup():
    global cap, detector
    cap = cv2.VideoCapture(0)
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

def loop():
    success, frame = cap.read()
    frame = doProcessing(frame)
    cv2.imshow("Camera", frame)
    
    key = chr(cv2.waitKey(1) & 0xFF)
    if key == 'q':
        cap.release()
        cv2.destroyAllWindows()
        sys.exit()

def main():
    setup()
    while True:
        loop()

if __name__ == '__main__':
    main()
```
