import 'package:flutter/material.dart';
import 'package:se_project/storage.dart';
import 'package:se_project/alarm.dart';
import 'package:se_project/home.dart';

import 'requirement_1.dart';
import 'requirement_2.dart';

int ID_num = 0; // 작업에 각각 부여하는 개별 아이디

TodoItem temp1 = TodoItem(title: '하위 : 바닥쓸기', relatedTasks: [], tags: [], subTasks: [], url: "http://www.naver.com");
TodoItem temp2 = TodoItem(title: '하위 : 설거지하기', relatedTasks: [], tags: [], subTasks: [],);
TodoItem temp3 = TodoItem(title: '하위 : 개발환경 설정하기', relatedTasks: [], tags: [], subTasks: [],);
TodoItem temp4 = TodoItem(title: '하위2 : 컴퓨터 켜기', relatedTasks: [], tags: [], subTasks: [],);
TodoItem temp5 = TodoItem(title: '하위2 : 크롬 켜기', relatedTasks: [], tags: [], subTasks: [],);



// 할 일 리스트(예제, 트리구조로 변경 필요) // Todo List(example, need to be changed into tree from)
final List<TodoItem> sampleTasks = [
  TodoItem(title: '청소하기', subTasks: [temp1, temp2,], relatedTasks: [], tags: [],),
  TodoItem(title: '코드 작성하기', subTasks: [temp3,], relatedTasks: [], tags: [],),
  TodoItem(title: '운동하기', relatedTasks: [], tags: [], subTasks: [],),
];


void main() async {
  // 선언 외의 동작은 여기서 설정 // Actions other than settings set here
  print('tlqkf');
  temp3.addItem(temp4);
  temp3.addItem(temp5);


  WidgetsFlutterBinding.ensureInitialized();
  await AlarmStorage.init();
  await Alarm.init(showDebugLogs : true);
  requestPermissions();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: TodoList(items: sampleTasks, ),
      bottomNavigationBar: TextButton(
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
                          sampleTasks.add(TodoItem(title: TaskNameController.text, relatedTasks: [], // 임시 : 연관작업에 컨트롤러 연동시키기 // temp : allocate related job into controller
                              tags: TaskTagController.text.split(","), subTasks: [], location: TaskLocController.text));
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
    );
  }
}