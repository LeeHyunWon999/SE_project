import 'package:se_project/alarm.dart';
import 'package:flutter/material.dart';
import 'package:se_project/requirement_1.dart';

// 알림이 울리는 화면을 나타내는 인터페이스 구성
// 알림이 울릴 때 보여질 UI를 정의.
class ExampleAlarmRingScreen extends StatelessWidget {
  final AlarmSettings alarmSettings;


  const ExampleAlarmRingScreen({Key? key, required this.alarmSettings})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(     // 노치나 시스템 상태바 영역을 침범하지 않는 안전한 영역 내에서 내용이 표시되도록 함.
        child: Column(    // 위젯을 세로로 정렬. 텍스트와 버튼들을 중앙에 배치
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              "You alarm (${alarmSettings.id}) is ringing...",    // 알람 ID와 함께 "Your alarm is ringing" 메시지 표시
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Text("🔔", style: TextStyle(fontSize: 50)),    // 이모티콘 사용 (fontSize 50으로)
            Row(    // 버튼들을 가로로 배치
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                RawMaterialButton(    // "Snooze" 버튼으로, 클릭하면 알람이 1분 뒤로 연기됨. 이 때 "Alarm.set" 메소드를 호출하고 새 "DateTime" 객체를 생성
                  onPressed: () {
                    final now = DateTime.now();
                    Alarm.set(
                      alarmSettings: alarmSettings.copyWith(
                        dateTime: DateTime(
                          now.year,
                          now.month,
                          now.day,
                          now.hour,
                          now.minute,
                          0,
                          0,
                        ).add(const Duration(minutes: 1)),
                      ),
                    ).then((_) => Navigator.pop(context));
                  },
                  child: Text(
                    "Snooze",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                RawMaterialButton(    // "Stop" 버튼으로, 클릭하면 "Alarm.stop" 메소드를 호출하여 알람을 중지함. 이 메소드는 'alarmSettings.id'를 인자로 받는다.
                  onPressed: () {
                    Alarm.stop(alarmSettings.id)
                        .then((_) {
                          Navigator.pop(context, false);});
                  },
                  child: Text(
                    "Stop",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
