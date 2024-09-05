# 코드 스니펙 만들기
## PyQt6 코드 탬플릿 사례
1. VSCode 실행
2. File > Preferences > Configure Snippets 선택
3. python 선택
4. python.json 파일이 열리면 다음 내용으로 덮어쓰기
```xml
{
	"PyQt6 Code": {
		"prefix": "qapp",
		"body" : [
			"import sys",
			"from PyQt6.QtWidgets import QApplication, QMainWindow",
			"from $1 import Ui_MainWindow",
			"",
			"class $2(QMainWindow, Ui_MainWindow):",
    		"    def __init__(self):",
        	"        super().__init__()",
        	"        self.setupUi(self)",
			"",
			"if __name__ == '__main__':",
			"    app = QApplication(sys.argv)",
			"    $3 = $2()",
			"    $3.show()",
			"    app.exec()" 
		],
		"description": "PyQt6 Code Template"
	}
}
```
