import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:sqflite/sqflite.dart';

import 'firebase_options.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'requirement_1.dart';
import 'requirement_2.dart';
import 'package:test_flutter/requirement_firestore.dart';

int ID_num = 0; // 작업에 각각 부여하는 개별 아이디

TodoItem temp1 = TodoItem(title: '하위 : 바닥쓸기', relatedTasks: [], tags: [], subTasks: [], superTask: null, url: "http://www.naver.com");
TodoItem temp2 = TodoItem(title: '하위 : 설거지하기', relatedTasks: [], tags: [], subTasks: [], superTask: null,);
TodoItem temp3 = TodoItem(title: '하위 : 개발환경 설정하기', relatedTasks: [], tags: [], subTasks: [], superTask: null,);
TodoItem temp4 = TodoItem(title: '하위2 : 컴퓨터 켜기', relatedTasks: [], tags: [], subTasks: [], superTask: null,);
TodoItem temp5 = TodoItem(title: '하위2 : 크롬 켜기', relatedTasks: [], tags: [], subTasks: [], superTask: null,);



// 할 일 리스트(예제, 트리구조로 변경 필요) // Todo List(example, need to be changed into tree from)
final List<TodoItem> sampleTasks = [
  TodoItem(title: '청소하기', subTasks: [temp1, temp2,], superTask: null, relatedTasks: [], tags: [],),
  TodoItem(title: '코드 작성하기', subTasks: [temp3,], superTask: null, relatedTasks: [], tags: [],),
  TodoItem(title: '운동하기', relatedTasks: [], superTask: null, tags: [], subTasks: [],),
];


// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//
//
//
//
//   // 선언 외의 동작은 여기서 설정 // Actions other than settings set here
//   print('tlqkf');
//   temp3.addItem(temp4);
//   temp3.addItem(temp5);
//
//
//   WidgetsFlutterBinding.ensureInitialized();
//   requestPermissions();
//
//   runApp(const MyApp());
// }

class TodoTree extends StatelessWidget {
  final String? account_id;
  final String? account_photoUrl;
  final String? account_email;
  //const TodoTree({super.key});

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

  FirestoreService? firestoreService; // 서버 통신용 객체 // server communicating instance
  SharedPreferences? prefs; // local에 마지막 접속한 사용자 이메일 저장용 객체 // saving last connected user email to local
  var db; // 로컬 db // local db


  // 생성자 // constructor
  _MyHomePageState({
    required this.account_id,
    required this.account_photoUrl,
    required this.account_email,
  });

  // 로컬에서 sqlite로 할 일 목록 받아오기
  Future<List<TodoItem>> getTask_local() async {
    List<TodoItem>? tempList = [];
    Map<String, dynamic> tempMap = await db.query('todolist', ['abc']);

    tempList = List.from(tempMap as Iterable);

    return tempList;
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

  // 서버에서 firestore로 할 일 목록 받아오기 : 기본키가 이메일임에 유의!
  List<TodoItem> getTask_server() {
    List<TodoItem>? tempList = [];

    return tempList;
  }

  // 서버에 현재 리스트 업로드
  void saveServer(List<TodoItem> list) {

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

  // 할 일 목록을 map(json)으로 만들어서 정보전달용 파일로 변환하기 (일단 남겨놓는데 서버에서도 필요없으면 지우기)
  Map<String, dynamic> toMap() => {
    'todoList' : gettedTasks,
  };

  // initState() 내에서 비동기 작업 처리를 위한 함수 // async function for initState()
  void initAsync() async {
    prefs = await SharedPreferences.getInstance(); // 로컬 간단변수 저장용 객체 초기화 // init local saving instance
    firestoreService = FirestoreService(); // 서버 저장용 객체 초기화 // init server saving instance
    // db = await openDatabase('my_db.db'); // 로컬 할일목록 저장용 객체 초기화 // init local list saving instance

    final Future<Database> db = openDatabase(
      // 데이터베이스 파일 경로 설정
      'my_db.db',
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
    } else {
      // 다르면 서버에 query 해서 정보 불러오기, sqlite로 로컬에 저장, 마지막 접속한 유저 갱신
      gettedTasks = getTask_server();
      saveLocal(gettedTasks!);
      prefs?.setString('lastUser', account_email!);
    }
  }


  @override
  void initState() {
    super.initState();
    initAsync();
  }

  @override
  Widget build(BuildContext context) {
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
              },
            ),
            TextButton(
              child: Text("Save this task into local"),
              onPressed: (){
                // 로컬에 TodoList 정보 저장
                saveLocal(gettedTasks!);
              },
            ),
            TextButton(
              child: Text("Upload this task into server"),
              onPressed: (){
                // 서버에 TodoList 정보 업로드
                saveServer(gettedTasks!);
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
      body: TodoList(items: gettedTasks!),
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
              final TaskRelateController = TextEditingController();
              final TaskTagController = TextEditingController();
              // 이들 중 일부는 상황에 따라 쓰이지 않거나 바뀔 수도 있음 // some of these could be not used or changed
              // myController.text 형식으로 접근 // access fields by like myController.text

              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (BuildContext context){
                  return AlertDialog(
                    title: Icon(Icons.add),
                    content: Container( // 너비지정용 // setting width by this
                      width: 600,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("creating root task UI"),
                          TextField(
                            controller: TaskNameController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Task name',
                              )
                          ),
                          SizedBox(height: 10, width: 100,),
                          TextField(
                            controller: TaskPriorController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Priority(need to be change into number input)',
                              )
                          ),
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
                            controller: TaskRelateController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'related Tasks(optional)(need to be change into task select box)',
                              )
                          ),
                          SizedBox(height: 10, width: 100,),
                          TextField(
                            controller: TaskTagController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'tags(optional)(no need to be change but need to parsing to use)',
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
                              gettedTasks?.add(TodoItem(title: TaskNameController.text, relatedTasks: [], // 임시 : 연관작업에 컨트롤러 연동시키기 // temp : allocate related job into controller
                                  tags: TaskTagController.text.split(","), subTasks: [], superTask: null, location: TaskLocController.text));
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
