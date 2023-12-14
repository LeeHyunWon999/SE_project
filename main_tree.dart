import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:sqflite/sqflite.dart';
import 'package:test_flutter/ring.dart';

import 'alarm.dart';
import 'alarm_settings.dart';
import 'complex_ring.dart';
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
  TodoTree(
      {required this.account_id,
      required this.account_photoUrl,
      required this.account_email});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(
          title: '$account_id\'s Todo List',
          account_id: account_id,
          account_photoUrl: account_photoUrl,
          account_email: account_email),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String? account_id;
  final String? account_photoUrl;
  final String? account_email;

  MyHomePage(
      {super.key,
      required this.title,
      required this.account_id,
      required this.account_photoUrl,
      required this.account_email});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState(
      account_id: account_id,
      account_photoUrl: account_photoUrl,
      account_email: account_email);
}

class _MyHomePageState extends State<MyHomePage> {
  final String? account_id;
  final String? account_photoUrl;
  final String? account_email;
  List<TodoItem>? gettedTasks = []; // 서버 혹은 로컬로부터 받아온 task

  SharedPreferences?
      prefs; // local에 마지막 접속한 사용자 이메일 저장용 객체 // saving last connected user email to local
  var db; // 로컬 db // local db

  int currentView = 0; // 현재 선택중인 view(0 : 트리(계층), 1 : 우선순위, 2 : 캘린더, 3 : 마감일)

  // 알람 변수
  late List<AlarmSettings> alarms;
  static StreamSubscription? subscription;

  ThemeMode _themeMode = ThemeMode.system; // 기본값으로 시스템 테마를 사용합니다.

  bool isKakaoTalkSharingAvailable = false; // 카톡 공유여부 확인용

  int point = 0; // 할 일 완수 점수
  int point_tendency = 0; // 할 일 완수 경향

  // 공유용 임시 메시지
  late TextTemplate defaultText = TextTemplate(
    text: "User ${account_id} is doing it's job at a speed of ${point_tendency}, and it's current score is ${point}!",
    link: Link(
      webUrl: Uri.parse(
          'https://docs.google.com/document/d/11c-Dwza4nnfjKpX1vHPdESuNRHwEMA5i/edit?usp=sharing&ouid=107513231846175452047&rtpof=true&sd=true'),
      mobileWebUrl: Uri.parse(
          'https://docs.google.com/document/d/11c-Dwza4nnfjKpX1vHPdESuNRHwEMA5i/edit?usp=sharing&ouid=107513231846175452047&rtpof=true&sd=true'),
    ),
  );

  // 생성자 // constructor
  _MyHomePageState({
    required this.account_id,
    required this.account_photoUrl,
    required this.account_email,
  });

  // Alarm.getAlarms()의 반환값으로 alarms 리스트의 상태를 설정하고, 날짜와 시간으로 알람을 정렬하여 표시
  void loadAlarms() {
    setState(() {
      alarms = Alarm.getAlarms();
      alarms.sort((a, b) => a.dateTime.isBefore(b.dateTime) ? 0 : 1);
    });
    print("알람 로드 완료");
  }

  Future<void> navigateToRingScreen(AlarmSettings alarmSettings) async {
    // complexNotification 값에 따라 다른 스크린으로 네비게이션
    if (mounted) {
      if (alarmSettings.complexNotification) {
        //ComplexAlarmRingScreen으로 네비게이션
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ComplexAlarmRingScreen(alarmSettings: alarmSettings),
          ),
        );
      } else {
        // ExampleAlarmRingScreen으로 네비게이션
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExampleAlarmRingScreen(
              alarmSettings: alarmSettings,
            ),
          ),
        );
      }
    } else
      print("주의 : 화면 전환 처리 도중 마운트 체크가 false가 되어있음!!");
    if (mounted) {
      loadAlarms();
    } else
      print("주의 : 마운트 2스택");
  }

  @override
  void dispose() {
    print("위젯이 사라집니다!!");
    subscription?.cancel();
    super.dispose();
  }

  // 로컬에서 sqlite로 할 일 목록 받아오기
  Future<List<TodoItem>> getTask_local() async {
    // 데이터베이스에서 'todolist' 테이블의 'abc' 컬럼 데이터를 조회합니다.
    List<Map<String, dynamic>> queryResult = await db.query('todolist',
        columns: ['abc'], where: 'id = ?', whereArgs: [1]);
    print(queryResult);

    // 조회된 결과를 TodoItem 객체의 리스트로 변환합니다. (근데 이제 하나만 나오는게 정상임)
    List<TodoItem> todoItems = [];
    var jsonData = jsonDecode(queryResult[0]['abc'] as String);
    if (jsonData is List) {
      todoItems.addAll(
          jsonData.map((jsonItem) => TodoItem.fromJson(jsonItem)).toList());
    }

    // json 저장시점에서 ID_count는 모두가 같은 값을 저장하므로 그중에 하나 받아다가 갱신
    // TodoItem.ID_count = jsonData[0]['ID_count'] + 1;

    return todoItems;
  }

  // 추가 : 로컬로부터 포인트 상황도 받아오기
  List<int> getPoint_local() {
    List<int> tempList = []; // 어차피 2개만 쓸거임
    tempList.add(prefs?.getInt("point") ?? 0);
    tempList.add(prefs?.getInt("point_tendency") ?? 0);

    return tempList;
  }

  // 로컬로 현재 리스트 저장 (+ 포인트)
  void saveLocal(List<TodoItem> list) async {
    String jsonString = jsonEncode(list.map((item) => item.toJson()).toList());

    // 이게 sqlite 문법이라 한다
    await db.transaction((txn) async {
      int? count = Sqflite.firstIntValue(
          await txn.rawQuery('SELECT COUNT(*) FROM todolist WHERE id = 1'));
      if (count == 0) {
        // 행이 없으면 새로 만듭니다.
        await txn.insert('todolist', {'id': 1, 'abc': jsonString});
      } else {
        // 행이 있으면 업데이트합니다.
        await txn.update('todolist', {'abc': jsonString},
            where: 'id = ?', whereArgs: [1]);
      }
    });

    // 포인트는 간단하니 prefs로 진행
    prefs?.setInt('point', point);
    prefs?.setInt('point_tendency', point_tendency);
  }

  // 서버에서 firestore로 할 일 목록 받아오기 : 구분자가 이메일임에 유의!
  Future<List<TodoItem>> getTask_server(String userEmail) async {
    CollectionReference todos = FirebaseFirestore.instance.collection('todos');
    DocumentSnapshot docSnapshot =
        await todos.doc(userEmail).get(); // 이메일 값으로 문서 받아오기

    if (docSnapshot.exists) {
      // 문서의 데이터를 가져옴
      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
      String jsonData = data['data'];

      // JSON 데이터를 TodoItem 객체의 리스트로 변환
      List<dynamic> jsonList = jsonDecode(jsonData);
      List<TodoItem> todoItems =
          jsonList.map((json) => TodoItem.fromJson(json)).toList();

      // json 저장시점에서 ID_count는 모두가 같은 값을 저장하므로 그중에 하나 받아다가 갱신
      // TodoItem.ID_count = jsonList[0]['ID_count'] + 1;

      return todoItems;
    } else {
      // 문서가 존재하지 않는 경우 빈 리스트 반환
      print('해당 사용자의 기존 문서가 없어 빈 리스트를 반환합니다.');
      return [];
    }
  }

  // 추가 : 서버로부터 포인트 상황도 받아오기 : points에 따로 저장
  Future<List<int>> getPoint_server(String userEmail) async {
    List<int> tempList = [];
    CollectionReference points = FirebaseFirestore.instance.collection('points');
    DocumentSnapshot docSnapshot =
        await points.doc(userEmail).get(); // 이메일 값으로 문서 받아오기

    if (docSnapshot.exists) {
      // 문서의 데이터를 가져옴
      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;

      tempList.add(data['point']);
      tempList.add(data['point_tendency']);
    } else {
      tempList.add(0);
      tempList.add(0);
    }

    return tempList;
  }

  // 서버에 현재 리스트 업로드 (+ 포인트)
  Future<void> saveServer(List<TodoItem> list, String userEmail) async {
    CollectionReference todos = FirebaseFirestore.instance.collection('todos');
    // 서버에 넣을 목적으로 json 생성
    String jsonString = jsonEncode(list.map((item) => item.toJson()).toList());
    // 현재 유저의 이메일을 문서 ID로 하여 서버에 업로드
    try {
      await todos.doc(userEmail).set({'data': jsonString});
    } catch (e) {
      print('task 업로드 중 문제가 발생했습니다 : ' + e.toString());
    }

    // 추가 : 포인트도 별개의 자료구조에 업로드
    CollectionReference points = FirebaseFirestore.instance.collection('points');
    // 서버에 대체 어떻게 넣어야 하지? 그냥 숫자 넣으면 될거같은데?
    try {
      await points.doc(userEmail).set({'point': point, 'point_tendency': point_tendency});
    } catch(e) {
      print('포인트 진행상황 업로드 중 문제가 발생했습니다 : ' + e.toString());
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
    prefs = await SharedPreferences
        .getInstance(); // 로컬 간단변수 저장용 객체 초기화 // init local saving instance
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
      for (var tasks in gettedTasks!) {
        updateSuperTask(tasks);
      }

      // 로컬에서 포인트 상황 마저 불러오기
      List<int> tempList = getPoint_local();
      point = tempList[0];
      point_tendency = tempList[1];
    } else {
      // 다르면 서버에 query 해서 정보 불러오기, sqlite로 로컬에 저장, 마지막 접속한 유저 갱신
      gettedTasks = await getTask_server(account_email!);
      saveLocal(gettedTasks!);
      for (var tasks in gettedTasks!) {
        // 얘도 재귀적으로 부모 노드 연결 갱신한다.
        updateSuperTask(tasks);
      }
      prefs?.setString('lastUser', account_email!);

      // 서버에서도 포인트 상황 마저 불러오기
      List<int> tempList = await getPoint_server(account_email!);

      point = tempList[0];
      point_tendency = tempList[1];
    }

    // 카톡 공유 API 위한 인스턴스 초기화
    isKakaoTalkSharingAvailable =
        await ShareClient.instance.isKakaoTalkSharingAvailable();

    if (isKakaoTalkSharingAvailable) {
      print('카카오톡으로 공유 가능');
    } else {
      print('카카오톡 미설치: 웹 공유 기능 사용 권장');
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    initAsync();

    print("위젯을 생성합니다!");
    loadAlarms();
    subscription ??= Alarm.ringStream.stream.listen(
        // subscription이 null이면, 알람이 울리면 navigateToRingScreen을 트리거하는 Alarm.ringStream을 듣도록 설정됨.
        (alarmSettings) {
      print("Alarm event received"); // 로깅 추가
      navigateToRingScreen(alarmSettings);
    });
    print("subscription 생성 완료");

    _loadThemeMode();
  }

  // 다크모드 설정 // setting dark mode
  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('darkMode') ?? false; // 기본값은 false입니다.
    setState(() {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }

  // 테마 변경 콜백
  Future<void> _toggleThemeMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', isDark);
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    GlobalKey<TodoListState> todoListKey = GlobalKey<TodoListState>();

    // view 종류 지정용 // choosing view
    Widget currentView_widget;
    switch (currentView) {
      case 0:
        currentView_widget = TodoList(items: gettedTasks!, key: todoListKey);
        break;
      case 1:
        currentView_widget = buildView_Priority(gettedTasks!);
        break;
      case 2:
        currentView_widget = buildView_Calendar(gettedTasks!);
        break;
      case 3:
        currentView_widget = buildView_DueDate(gettedTasks!);
      default:
        currentView_widget = TodoList(items: gettedTasks!, key: todoListKey);
        break;
    }

    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      themeMode: _themeMode, // 현재 테마 모드를 적용합니다.
      home: Scaffold(
        drawer: Drawer(
          child: ListView(
            children: [
              UserAccountsDrawerHeader(
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: NetworkImage(account_photoUrl!),
                  ),
                  accountName: Text(account_id!),
                  accountEmail: Text(account_email!)),
              TextButton(
                child: Text("Change the view"),
                onPressed: () {
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
                                  onPressed: () {
                                    setState(() {
                                      Navigator.of(context).pop();
                                      currentView = 0;
                                    });
                                  },
                                  child: Text("Tree View")),
                              ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      Navigator.of(context).pop();
                                      currentView = 1;
                                    });
                                  },
                                  child: Text("Priority View")),
                              ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      Navigator.of(context).pop();
                                      currentView = 2;
                                    });
                                  },
                                  child: Text("Calendar View")),
                              ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      Navigator.of(context).pop();
                                      currentView = 3;
                                    });
                                  },
                                  child: Text("Due date View")),
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
                onPressed: () {
                  // 로컬에 TodoList 정보 저장
                  saveLocal(gettedTasks!);
                  Fluttertoast.showToast(msg: "Local saved!");
                },
              ),
              TextButton(
                child: Text("Upload this task into server"),
                onPressed: () {
                  // 서버에 TodoList 정보 업로드
                  saveServer(gettedTasks!, account_email!);
                  Fluttertoast.showToast(
                      msg:
                          "Uploaded! Make sure to download your extern files!!");
                },
              ),
              Text("My Task Completion Point : ${point}"),
              Text("My Task Completion Tendency : ${point_tendency}"),
              ElevatedButton(
                  onPressed: () {
                    // 여기선 포인트 계산
                    // 포인트 계산방식 : 일단 잘 되는지 보기 위해 point는 1씩, tendency는 2씩 올려보도록 하자.
                    point += 1;
                    point_tendency += 2;

                    setState(() {});
                    Fluttertoast.showToast(msg: "Updated progress!");
                  },
                  child: Text("Update Task Completion Progress")),
              ElevatedButton(
                  onPressed: () async {
                    // 카카오톡 실행 가능 여부 확인
                    bool isKakaoTalkSharingAvailable = await ShareClient
                        .instance
                        .isKakaoTalkSharingAvailable();

                    if (isKakaoTalkSharingAvailable) {
                      try {
                        Uri uri = await ShareClient.instance
                            .shareDefault(template: defaultText);
                        await ShareClient.instance.launchKakaoTalk(uri);
                        print('카카오톡 공유 완료');
                      } catch (error) {
                        print('카카오톡 앱 공유 실패 $error');
                      }
                    } else {
                      try {
                        Uri shareUrl = await WebSharerClient.instance
                            .makeDefaultUrl(template: defaultText);
                        await launchBrowserTab(shareUrl, popupOpen: true);
                      } catch (error) {
                        print('카카오톡 웹 공유 실패 $error');
                      }
                    }
                  },
                  child: Text("Share")),
              SwitchListTile(
                title: Text("Dark Mode"),
                value: _themeMode == ThemeMode.dark,
                onChanged: _toggleThemeMode,
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
              onPressed: () {
                context;
                // TextEditingController 추가로 Task 요소 관리하며 새 작업 생성 // managing TextField content : using controllers
                final TaskNameController = TextEditingController();
                final TaskDescController = TextEditingController();
                final TaskPriorController = TextEditingController();
                final TaskLocController = TextEditingController();
                final TaskTagController = TextEditingController();

                // 이들 중 일부는 상황에 따라 쓰이지 않거나 바뀔 수도 있음 // some of these could be not used or changed
                // myController.text 형식으로 접근 // access fields by like myController.text

                // showDialog(
                //   context: context,
                //   barrierDismissible: true,
                //   builder: (BuildContext context) {
                //     return AlertDialog(
                //       title: Text("creating root task"),
                //       content: Container(
                //         // 너비지정용 // setting width by this
                //         width: 600,
                //         child: Column(
                //           mainAxisSize: MainAxisSize.min,
                //           children: [
                //             TextField(
                //                 controller: TaskNameController,
                //                 decoration: InputDecoration(
                //                   border: OutlineInputBorder(),
                //                   labelText: 'Task name',
                //                 )),
                //             SizedBox(
                //               height: 10,
                //               width: 100,
                //             ),
                //             TextField(
                //                 keyboardType: TextInputType.number,
                //                 inputFormatters: [
                //                   FilteringTextInputFormatter.allow(
                //                       RegExp('[0-9]'))
                //                 ],
                //                 controller: TaskPriorController,
                //                 decoration: InputDecoration(
                //                   border: OutlineInputBorder(),
                //                   labelText: 'Priority',
                //                 )),
                //             SizedBox(
                //               height: 10,
                //               width: 100,
                //             ),
                //             TextField(
                //                 controller: TaskLocController,
                //                 decoration: InputDecoration(
                //                   border: OutlineInputBorder(),
                //                   labelText: 'location(optional)',
                //                 )),
                //             SizedBox(
                //               height: 10,
                //               width: 100,
                //             ),
                //             TextField(
                //                 controller: TaskTagController,
                //                 decoration: InputDecoration(
                //                   border: OutlineInputBorder(),
                //                   labelText: 'tags(optional)',
                //                 )),
                //             // 하위작업은 루트작업 생성 후 진행 // subTask is not added at creating root Task
                //             SizedBox(
                //               height: 10,
                //               width: 100,
                //             ),
                //           ],
                //         ),
                //       ),
                //       actions: <Widget>[
                //         Container(
                //           child: ElevatedButton(
                //             onPressed: () {
                //               Navigator.of(context)
                //                   .pop(); //창 닫기 // close Dialog with Create tasks
                //               // 작업 생성 시도
                //               setState(() {
                //                 gettedTasks?.add(TodoItem(
                //                   title: TaskNameController.text,
                //                   tags: TaskTagController.text.split(","),
                //                   subTasks: [],
                //                   superTask: null,
                //                   location: TaskLocController.text,
                //                   priority: TaskPriorController.text.isEmpty
                //                       ? 0
                //                       : int.parse(TaskPriorController.text),
                //                 ));
                //               });
                //             },
                //             child: Text("Create"),
                //           ),
                //         ),
                //         Container(
                //           child: ElevatedButton(
                //             onPressed: () {
                //               Navigator.of(context)
                //                   .pop(); //창 닫기 // close Dialog with cancel
                //             },
                //             child: Text("Cancel"),
                //           ),
                //         ),
                //       ],
                //     );
                //   },
                // );


                bool setDeadline = false; // 마감일 여부
                DateTime deadline = DateTime.parse("1000-00-00"); // 마감일 설정용

                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) {
                    return StatefulBuilder(builder:
                        (BuildContext context, StateSetter setState1) {
                      return AlertDialog(
                        title: Text("creating subTask"),
                        content: Container(
                          // 너비지정용 // setting width by this
                          width: 600,
                          child: ListView(
                            // mainAxisSize: MainAxisSize.min,
                            // crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                  controller: TaskNameController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Task name',
                                  )),
                              SizedBox(
                                height: 10,
                              ),
                              TextField(
                                  maxLines: null,
                                  controller: TaskDescController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Task Description',
                                  )),
                              SizedBox(
                                height: 10,
                              ),
                              TextField(
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp('[0-9]'))
                                  ],
                                  controller: TaskPriorController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Priority',
                                  )),
                              SizedBox(
                                height: 10,
                              ),
                              TextField(
                                  controller: TaskLocController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'location(optional)',
                                  )),
                              SizedBox(
                                height: 10,
                              ),
                              TextField(
                                  controller: TaskTagController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'tags(optional)',
                                  )),
                              // 하위작업은 루트작업 생성 후 진행 // subTask is not added at creating root Task
                              SizedBox(
                                height: 10,
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  // Lam의 구현이 잘 되는지 확인

                                  TimeOfDay _selectedTime = TimeOfDay.now();
                                  DateTime _selectedDate = DateTime.now();

                                  Future<DateTime>
                                  _showDueDatePicker() async {
                                    final DateTime? picked1 =
                                    await showDatePicker(
                                        context: context,
                                        initialDate: _selectedDate,
                                        firstDate: _selectedDate,
                                        lastDate:
                                        DateTime.parse('2100-01-01'));

                                    if (picked1 != null &&
                                        picked1 != _selectedDate) {
                                      setState(() {
                                        _selectedDate = picked1;
                                      });
                                    }
                                    final TimeOfDay? picked2 =
                                    await showTimePicker(
                                      context: context,
                                      initialTime: _selectedTime,
                                    );

                                    if (picked2 != null &&
                                        picked2 != _selectedTime) {
                                      setState(() {
                                        _selectedTime = picked2;
                                      });
                                    }
                                    return new DateTime(
                                      _selectedDate.year,
                                      _selectedDate.month,
                                      _selectedDate.day,
                                      _selectedTime.hour,
                                      _selectedTime.minute,
                                    );
                                  }

                                  deadline = await _showDueDatePicker();

                                  print(_selectedTime);
                                  print(_selectedDate);
                                },
                                child: Text("Select Due date"),
                              ),
                              Row(
                                children: [
                                  Checkbox(
                                    value: setDeadline,
                                    onChanged: (value) {
                                      setState(() {
                                        setDeadline = value!;
                                        print("${setDeadline}");
                                      });
                                      setState(() {});
                                    },
                                  ),
                                  Text("Activate Due date"),
                                ],
                              ),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          Container(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context)
                                    .pop(); //창 닫기 // close Dialog with Create tasks
                                // 작업 생성 시도
                                // createTask(
                                //   null,
                                //   TaskNameController,
                                //   TaskDescController,
                                //   TaskTagController,
                                //   TaskLocController,
                                //   TaskPriorController,
                                //   null,
                                //   setDeadline,
                                //   deadline,
                                // );




                                setState((){
                                  gettedTasks?.add(TodoItem(
                                    title: TaskNameController.text,
                                    description: TaskDescController.text,
                                    tags: TaskTagController.text.split(","),
                                    subTasks: [],
                                    superTask: null,
                                    location: TaskLocController.text,
                                    priority: TaskPriorController.text.isEmpty
                                        ? 0
                                        : int.parse(
                                      TaskPriorController.text,
                                    ),
                                    isDeadlineEnabled: setDeadline,
                                    deadline: deadline,
                                  ));
                                });


                              },
                              child: Text("Create"),
                            ),
                          ),
                          Container(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context)
                                    .pop(); //창 닫기 // close Dialog with cancel
                              },
                              child: Text("Cancel"),
                            ),
                          ),
                        ],
                      );
                    });
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
