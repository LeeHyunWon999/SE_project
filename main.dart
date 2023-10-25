import 'package:flutter/material.dart';

import 'requirement_1.dart';

TodoItem temp1 = TodoItem(title: '하위 : 바닥쓸기', relatedTasks: [], tags: [], subTasks: [],);
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


void main() {
  // 선언 외의 동작은 여기서 설정 // Actions other than settings set here
  print('tlqkf');
  temp3.addItem(temp4);
  temp3.addItem(temp5);

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
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: TodoList(items: sampleTasks),
      bottomNavigationBar: IconButton(
        icon:Icon(Icons.priority_high),
        onPressed: (){
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context){
              return AlertDialog(
                content: Icon(Icons.add),

              );
            },
          );
        },
      ),
    );
  }
}
