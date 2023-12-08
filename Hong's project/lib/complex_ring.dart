import 'dart:math';
import 'package:flutter/material.dart';
import 'package:se_project/alarm.dart';

class ComplexAlarmRingScreen extends StatefulWidget {
  final AlarmSettings alarmSettings;

  const ComplexAlarmRingScreen({Key? key, required this.alarmSettings})
      : super(key: key);

  @override
  _ComplexAlarmRingScreenState createState() => _ComplexAlarmRingScreenState();
}

class _ComplexAlarmRingScreenState extends State<ComplexAlarmRingScreen> {
  final Random _random = Random();
  late int _factorA;
  late int _factorB;
  late int _correctAnswer;
  final TextEditingController _answerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _generateMathProblem();
  }

  void _generateMathProblem() {
    setState(() {
      _factorA = _random.nextInt(90) + 10; // 10 ~ 99
      _factorB = _random.nextInt(90) + 10; // 10 ~ 99
      _correctAnswer = _factorA * _factorB;
    });
  }

  void _checkAnswer() {
    if (int.tryParse(_answerController.text) == _correctAnswer) {
      Alarm.stop(widget.alarmSettings.id).then((_) => Navigator.pop(context));
    } else {
      // 정답이 아닐 경우, 새로운 문제 생성
      _generateMathProblem();
      _answerController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              "Solve this to stop the alarm:",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              "$_factorA × $_factorB = ?",
              style: TextStyle(fontSize: 30),
            ),
            TextField(
              controller: _answerController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24),
              onSubmitted: (_) => _checkAnswer(),
            ),
            RawMaterialButton(
              onPressed: _checkAnswer,
              child: Text(
                "Submit",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
