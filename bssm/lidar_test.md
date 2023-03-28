## 2D Lidar Test

```pythohn
from pop.LiDAR import Rplidar
import matplotlib.pyplot as plt
import numpy as np
import cv2

lidar = Rplidar()
lidar.connect()
lidar.startMotor()

fig = plt.figure(figsize=(12.8, 7.2), dpi=100)
ax = fig.add_subplot(111, projection='polar')
fig.tight_layout()

dist = 5000 #5m

while True:
    V = np.array(lidar.getVectors(True))
    V = np.where(V <= dist, V, 0)
    ax.plot(np.deg2rad(V[:,0]), V[:,1])
    fig.canvas.draw()

    cv2.imshow("lidar", np.array(fig.canvas.renderer._renderer))
    plt.cla()
    ax.set_theta_zero_location("N")

    if cv2.waitKey(10) == 27:
        break

lidar.stopMotor()
cv2.destroyAllWindows()
```
