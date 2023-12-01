//import 'dart:js_interop';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_options.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

// 직접 만든 파일들 // files we created
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

  final _googleSignIn = GoogleSignIn(
    clientId: '647470475554-qi3ro055j6e4qggtb326ot9toucti12q.apps.googleusercontent.com',
  );

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
          ElevatedButton(
            child: Text('Login'),
            onPressed: () async{
              // 이거 누르면 메인트리 화면으로 이동 // move into view page(tree)
              // 여긴 튜토리얼 페이지 보고 따라하기 // following tutorial
              // https://cokebi.com/34

              final googleAccount = await _googleSignIn.signIn();

              if (googleAccount != null) {
                final googleAuth = await googleAccount.authentication;

                if (googleAuth.accessToken != null &&
                    googleAuth.idToken != null) {
                  try {
                    await FirebaseAuth.instance.signInWithCredential(GoogleAuthProvider.credential(
                      idToken: googleAuth.idToken,
                      accessToken: googleAuth.accessToken,
                    ));
                    print("인증성공");
                    
                    // 이제 여기서 화면전환하면 된다.
                    Navigator.push(context, MaterialPageRoute(builder: (context) => TodoTree(
                      account_id: googleAccount.displayName,
                      account_photoUrl: googleAccount.photoUrl,
                      account_email: googleAccount.email,
                    )));
                  } on FirebaseAuthException catch (e) {
                    print('문제가 있어 인증에 실패했습니다 : $e');
                  } catch (e) {
                    print('문제가 있어 인증에 실패했습니다 : $e');
                  }
                } else {
                  print('문제가 있어 인증에 실패했습니다 : Access 및 Id token이 Null임!! : ${googleAuth.accessToken}, ${googleAuth.idToken}');
                }
              } else {
                print('문제가 있어 인증에 실패했습니다 : googleAccount가 Null임!! : $googleAccount');
              }


              // 임시 : 인증 넣기 전의 화면전환 위치 // original change screen's position before inserting authentication
              //Navigator.push(context, MaterialPageRoute(builder: (context) => TodoTree()));
            },
          ),
          ElevatedButton(onPressed: () async{
            // Google 로그아웃
            await _googleSignIn.signOut();

            // Firebase 로그아웃
            await FirebaseAuth.instance.signOut();

            Fluttertoast.showToast(msg: "Logouted!");

            // 필요한 경우 로그인 화면으로 돌아가거나 다른 처리를 수행
          }, child: Text('Logout')),
        ],
      ),
    );
  }
}
