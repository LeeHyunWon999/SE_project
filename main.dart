import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:flutter/material.dart';

import 'main_tree.dart';
import 'requirement_1.dart';
import 'requirement_2.dart';


// 페이지 구성 : 로그인 화면 -> 메인화면(할 일 목록 보여주기; 근데 이제 여러가지 뷰를 통해서)
// Page construction : Login -> Main(showing Todo List; by many of views)

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  WidgetsFlutterBinding.ensureInitialized();
  requestPermissions();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SE_TodoApp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Todo App'),
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
    return Container(
      color: Colors.purple,
      // Todo : 여기에 로그인화면 넣기! // Todo : insert Login Screen here!
      // 로그인 화면이 넘어가면 다음 화면으로 가야 할 것이다. 그건 이제 기존에 작업하던 그녀석을 불러야 할 수도 있다.
      // If login successes, then it should change into its next screen : already making task tree.
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/img.png',
            width: 200,
            height: 200,
          ),
          Text('Todo App'),
          TextButton(
            child: Text('Login'),
            onPressed: (){
              // 이거 누르면 메인트리 화면으로 이동?
              Navigator.push(context, MaterialPageRoute(builder: (context) => TodoTree()));
            },
          ),
        ],
      ),
    );
  }
}
