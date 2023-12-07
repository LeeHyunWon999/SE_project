import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

import 'firebase_options.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'requirement_1.dart';
import 'requirement_2.dart';
import 'requirement_view.dart';

int ID_num = 0; // 작업에 각각 부여하는 개별 아이디

class TodoTree extends StatelessWidget {
  final String? account_id;
  final String? account_photoUrl;
  final String? account_email;

  // 생성자 : 사용자 정보 받아오기 // constructor : get user information
  TodoTree({required this.account_id, required this.account_photoUrl, required this.account_email});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(title: '$account_id\'s Todo List', account_id: account_id, account_photoUrl: account_photoUrl, account_email: account_email),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String? account_id;
  final String? account_photoUrl;
  final String? account_email;
  MyHomePage({super.key, required this.title, required this.account_id, required this.account_photoUrl, required this.account_email});

  final String title;


  @override
  State<MyHomePage> createState() => _MyHomePageState(account_id: account_id, account_photoUrl: account_photoUrl, account_email: account_email);
}

class _MyHomePageState extends State<MyHomePage> {
  final String? account_id;
  final String? account_photoUrl;
  final String? account_email;
  List<TodoItem>? gettedTasks = []; // 서버 혹은 로컬로부터 받아온 task

  SharedPreferences? prefs; // local에 마지막 접속한 사용자 이메일 저장용 객체 // saving last connected user email to local
  var db; // 로컬 db // local db

  int currentView = 0; // 현재 선택중인 view(0 : 트리(계층), 1 : 우선순위, 2 : 캘린더, 3 : 마감일)


  // 생성자 // constructor
  _MyHomePageState({
    required this.account_id,
    required this.account_photoUrl,
    required this.account_email,
  });






  // 로컬에서 sqlite로 할 일 목록 받아오기
  Future<List<TodoItem>> getTask_local() async {
    // 데이터베이스에서 'todolist' 테이블의 'abc' 컬럼 데이터를 조회합니다.
    List<Map<String, dynamic>> queryResult = await db.query('todolist', columns: ['abc'],where: 'id = ?', whereArgs: [1]);
    print(queryResult);

    // 조회된 결과를 TodoItem 객체의 리스트로 변환합니다. (근데 이제 하나만 나오는게 정상임)
    List<TodoItem> todoItems = [];
    var jsonData = jsonDecode(queryResult[0]['abc'] as String);
    if(jsonData is List) {
      todoItems.addAll(jsonData.map((jsonItem) => TodoItem.fromJson(jsonItem)).toList());
    }

    // json 저장시점에서 ID_count는 모두가 같은 값을 저장하므로 그중에 하나 받아다가 갱신
    // TodoItem.ID_count = jsonData[0]['ID_count'] + 1;

    return todoItems;
  }

  // 로컬로 현재 리스트 저장
  void saveLocal(List<TodoItem> list) async {
    // List<String> jsonList = list.map((item) => jsonEncode(item.toJson())).toList();

    String jsonString = jsonEncode(list.map((item) => item.toJson()).toList());

    // 이게 sqlite 문법이라 한다
    await db.transaction((txn) async {
        // await txn.insert('todolist', {'abc' : jsonString});
      int? count = Sqflite.firstIntValue(await txn.rawQuery('SELECT COUNT(*) FROM todolist WHERE id = 1'));
      if (count == 0) {
        // 행이 없으면 새로 만듭니다.
        await txn.insert('todolist', {'id': 1, 'abc': jsonString});
      } else {
        // 행이 있으면 업데이트합니다.
        await txn.update('todolist', {'abc': jsonString}, where: 'id = ?', whereArgs: [1]);
      }
    });
  }

  // 서버에서 firestore로 할 일 목록 받아오기 : 구분자가 이메일임에 유의!
  Future<List<TodoItem>> getTask_server(String userEmail) async {
    List<TodoItem>? tempList = [];
    CollectionReference todos = FirebaseFirestore.instance.collection('todos');
    DocumentSnapshot docSnapshot = await todos.doc(userEmail).get(); // 이메일 값으로 문서 받아오기

    if (docSnapshot.exists) {
      // 문서의 데이터를 가져옴
      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
      String jsonData = data['data'];

      // JSON 데이터를 TodoItem 객체의 리스트로 변환
      List<dynamic> jsonList = jsonDecode(jsonData);
      List<TodoItem> todoItems = jsonList.map((json) => TodoItem.fromJson(json)).toList();

      // json 저장시점에서 ID_count는 모두가 같은 값을 저장하므로 그중에 하나 받아다가 갱신
      // TodoItem.ID_count = jsonList[0]['ID_count'] + 1;

      return todoItems;
    } else {
      // 문서가 존재하지 않는 경우 빈 리스트 반환
      print('해당 사용자의 기존 문서가 없어 빈 리스트를 반환합니다.');
      return [];
    }
    return tempList;
  }

  // 서버에 현재 리스트 업로드
  Future<void> saveServer(List<TodoItem> list, String userEmail) async {
    CollectionReference todos = FirebaseFirestore.instance.collection('todos');
    // 서버에 넣을 목적으로 json 생성
    String jsonString = jsonEncode(list.map((item) => item.toJson()).toList());
    // 현재 유저의 이메일을 문서 ID로 하여 서버에 업로드
    try {
      await todos.doc(userEmail).set({'data': jsonString});
    } catch(e) {
      print('task 업로드 중 문제가 발생했습니다 : ' + e.toString());
    }
  }

  // db에서 테이블 생성
  void _createDatabase(Database db, int version) async {
    await db.execute('''
    CREATE TABLE todolist (
      id INTEGER PRIMARY KEY,
      abc TEXT
    );
  ''');
  }

  // 부모 참조를 위한 재귀문 처리용
  void updateSuperTask(TodoItem item) {
    for (var task in item.subTasks) {
      task.superTask = item;
      updateSuperTask(task);
    }
  }

  // initState() 내에서 비동기 작업 처리를 위한 함수 // async function for initState()
  void initAsync() async {
    prefs = await SharedPreferences.getInstance(); // 로컬 간단변수 저장용 객체 초기화 // init local saving instance
    // db = await openDatabase('my_db.db'); // 로컬 할일목록 저장용 객체 초기화 // init local list saving instance

    // db 초기화 // init db
    String path = await getDatabasesPath() + 'my_db.db';
    db = await openDatabase(
      // 데이터베이스 파일 경로 설정
      path,
      onCreate: (db, version) {
        return _createDatabase(db, version);
      },
      version: 1, // 데이터베이스 버전
    );



    // 처음 이 화면 나올 때의 동작 : 서버로부터 받은 이메일과 마지막 이메일이 같은지 확인하기
    // 같으면 local에서 sqlite로 리스트 불러와서 그거 사용함, 다르면 그때 서버로 query
    // 위의 작업이 끝난 다음에 마지막으로 현재 접속한 유저 이메일로 갱신
    if (prefs == null) {
      print('prefs 객체가 없습니다!!');
    }
    if (account_email == prefs?.getString('lastUser')) {
      // 같으면 로컬에서 sqlite로 불러온 리스트로 화면에 표시
      gettedTasks = await getTask_local();
      print("작업이 잘 들어갔는지 확인하겠습니다.");
      print(gettedTasks?[1].title);

      // 아직 superTask는 처리하지 않았으므로, 이 정보를 재귀적으로 갱신하도록 한다.
      for(var tasks in gettedTasks!) {
        updateSuperTask(tasks);
      }

    } else {
      // 다르면 서버에 query 해서 정보 불러오기, sqlite로 로컬에 저장, 마지막 접속한 유저 갱신
      gettedTasks = await getTask_server(account_email!);
      saveLocal(gettedTasks!);
      for(var tasks in gettedTasks!) {  // 얘도 재귀적으로 부모 노드 연결 갱신한다.
        updateSuperTask(tasks);
      }
      prefs?.setString('lastUser', account_email!);
    }

    setState((){});
  }


  @override
  void initState() {
    super.initState();
    initAsync();
  }

  @override
  Widget build(BuildContext context) {
    GlobalKey<TodoListState> todoListKey = GlobalKey<TodoListState>();

    // view 종류 지정용 // choosing view
    Widget currentView_widget;
    switch(currentView) {
      case 0 :
        currentView_widget = TodoList(items: gettedTasks!, key: todoListKey);
        break;
      case 1 :
        currentView_widget = buildView_Priority(gettedTasks!);
        break;
      case 2 :
        currentView_widget = buildView_Calendar(gettedTasks!);
        break;
      case 3 :
        currentView_widget = buildView_DueDate(gettedTasks!);
      default :
        currentView_widget = TodoList(items: gettedTasks!, key: todoListKey);
        break;
    }

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(backgroundImage: NetworkImage(account_photoUrl!),),
                accountName: Text(account_id!), accountEmail: Text(account_email!)),
            TextButton(
              child: Text("Change the view"),
              onPressed: (){
                // 뷰 변경 // changing view
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      actions: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ElevatedButton(
                                onPressed: (){
                                  setState(() {
                                    currentView = 0;
                                  });
                                },
                               child: Text("Tree View")
                            ),
                            ElevatedButton(
                                onPressed: (){
                                  setState(() {
                                    currentView = 1;
                                  });
                                },
                                child: Text("Priority View")
                            ),
                            ElevatedButton(
                                onPressed: (){
                                  setState(() {
                                    currentView = 2;
                                  });
                                },
                                child: Text("Calendar View")
                            ),
                            ElevatedButton(
                                onPressed: (){
                                  setState(() {
                                    currentView = 3;
                                  });
                                },
                                child: Text("Due date View")
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            TextButton(
              child: Text("Save this task into local"),
              onPressed: (){
                // 로컬에 TodoList 정보 저장
                saveLocal(gettedTasks!);
                Fluttertoast.showToast(msg: "Local saved!");
              },
            ),
            TextButton(
              child: Text("Upload this task into server"),
              onPressed: (){
                // 서버에 TodoList 정보 업로드
                saveServer(gettedTasks!, account_email!);
                Fluttertoast.showToast(msg: "Uploaded! Make sure to download your extern files!!");
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        //leading: Image.network(account_photoUrl!),

      ),
      body: currentView_widget,
      bottomNavigationBar: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            child: Text("Create New Root Tasks"),
            onPressed: (){

              // TextEditingController 추가로 Task 요소 관리하며 새 작업 생성 // managing TextField content : using controllers
              final TaskNameController = TextEditingController();
              final TaskPriorController = TextEditingController();
              final TaskLocController = TextEditingController();
              final TaskTagController = TextEditingController();
              // 이들 중 일부는 상황에 따라 쓰이지 않거나 바뀔 수도 있음 // some of these could be not used or changed
              // myController.text 형식으로 접근 // access fields by like myController.text

              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (BuildContext context){
                  return AlertDialog(
                    title: Text("creating root task"),
                    content: Container( // 너비지정용 // setting width by this
                      width: 600,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: TaskNameController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Task name',
                              )
                          ),
                          SizedBox(height: 10, width: 100,),
                          TextField(
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9]'))],
                              controller: TaskPriorController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText:
                                'Priority',
                              )),
                          SizedBox(height: 10, width: 100,),
                          TextField(
                            controller: TaskLocController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'location(optional)',
                              )
                          ),
                          SizedBox(height: 10, width: 100,),
                          TextField(
                            controller: TaskTagController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'tags(optional)',
                              )
                          ),
                          // 하위작업은 루트작업 생성 후 진행 // subTask is not added at creating root Task
                          SizedBox(height: 10, width: 100,),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      Container(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(); //창 닫기 // close Dialog with Create tasks
                            // 작업 생성 시도
                            setState(() {
                              gettedTasks?.add(TodoItem(title: TaskNameController.text,
                                tags: TaskTagController.text.split(","),
                                subTasks: [], superTask: null,
                                location: TaskLocController.text,
                                priority: TaskPriorController.text.isEmpty ? 0 : int.parse(TaskPriorController.text),
                              ));
                            });


                          },
                          child: Text("Create"),
                        ),
                      ),
                      Container(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(); //창 닫기 // close Dialog with cancel
                          },
                          child: Text("Cancel"),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
