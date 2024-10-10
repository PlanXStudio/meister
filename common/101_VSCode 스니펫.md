# 코드 스니펫 만들기
코드 스니펫은 재사용 가능한 소스 코드, 기계어, 텍스트의 작은 부분을 의미합니다.

## VSCode에서 코드 스니펙
1. VSCode를 실행합니다.
2. 메뉴에서 File(파일) > Preferences(기본 설정) > Configure Snippets(코드 조각 구성)을 선택합니다.
3. 목록에서 python을 선택합니다. (VSCode/data/user-data/User/snippets/python.json)
4. python.json 파일이 열리면 스니펙을 구현합니다.

스니펫의 기본 구조는 다음과 같습니다.
```json
{
	"your_title": {
	"prefix": "your_prefix",
	"body": [
		"your_code",
	],
	"description": "your_description"
	...
}
```
prefix, body, description은 키워드이므로 수정할 수 없고 사용자는 다음 내용을 수정합니다. 또한 your_title과 your_prefix는 일반적으로 같은 문자열을 사용합니다. 
- your_prefix: 스니펫 호출 문자열입니다.
- your_code: 스니펫이 호출될 때 추가할 소스 코드입니다.
  - 들여쓰기는 **탭문자 1개 대신 스페이스 문자 4개**를 사용합니다.  
- your_description: 스니펫에 대해 설명으로 생략 가능합니다. 

body에 '$1', '$2'와 같이 변수를 사용하면 사용자가 직접 내용을 입력해야 합니다. 변수 이동은 \<TAB> 또는 \<Shift>\<TAB>입니다. 

## PyQt6 코드 탬플릿 사례
1. VSCode 실행
2. File(파일) > Preferences(기본 설정) > Configure Snippets(코드 조각 구성) 선택
3. python 선택
4. python.json 파일이 열리면 다음 내용으로 덮어쓰기
```xml
{
	"QtApp": {
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
			"        $3",
			"",
			"if __name__ == '__main__':",
			"    app = QApplication(sys.argv)",
			"    win = $2()",
			"    win.show()",
			"    app.exec()" 
		],
	}
}
```
