import 'dart:async';

import 'package:se_project/alarm.dart';
import 'package:se_project/edit_alarm.dart';
import 'package:se_project/ring.dart';
import 'package:se_project/shortcut_button.dart';
import 'package:se_project/tile.dart';
import 'package:flutter/material.dart';
import 'package:se_project/requirement_1.dart';



// 알람 App의 홈 스크린을 정의하는 Dart 파일.
// 알람 목록을 표시하고 사용자가 알람을 만들 수 있도록 하며, 알람이 울릴 때 편집 화면이나 알람 소리 화면으로 네비게이션 하는 기능을 담당.
class ExampleAlarmHomeScreen extends StatefulWidget {
  const ExampleAlarmHomeScreen({Key? key}) : super(key: key);

  @override
  State<ExampleAlarmHomeScreen> createState() => _ExampleAlarmHomeScreenState();

}

// _ExampleAlarmHomeScreenState는 ExampleAlarmHomeScreen의 상태를 유지 관리한다.
// 알람 설정을 저장하는 사용자 정의 객체인 AlarmSettings 객체의 리스트를 선언
class _ExampleAlarmHomeScreenState extends State<ExampleAlarmHomeScreen> {
  late List<AlarmSettings> alarms;

  // static 변수인 subscription은 알람이 울릴 때마다 트리거될 Alarm.ringStream을 듣기 위한 StreamSubscription을 보유
  static StreamSubscription? subscription;

  @override
  void initState() {    // 이 위젯이 트리에 삽입될 때 initState가 호출된다.
    super.initState();
    loadAlarms();   // loadAlarms 메소드가 호출되어 alarms 리스트를 기존 알람 구성으로 초기화한다.
    subscription ??= Alarm.ringStream.stream.listen(    // subscription이 null이면, 알람이 울리면 navigateToRingScreen을 트리거하는 Alarm.ringStream을 듣도록 설정됨.
          (alarmSettings) => navigateToRingScreen(alarmSettings),
    );
  }

  // Alarm.getAlarms()의 반환값으로 alarms 리스트의 상태를 설정하고, 날짜와 시간으로 알람을 정렬하여 표시
  void loadAlarms() {
    setState(() {
      alarms = Alarm.getAlarms();
      alarms.sort((a, b) => a.dateTime.isBefore(b.dateTime) ? 0 : 1);
    });
  }

  // navigateToRingScreen은 AlarmSettings 객체를 가져와 알람이 울릴 때 ExampleAlarmRingScreen으로 네비게이션
  Future<void> navigateToRingScreen(AlarmSettings alarmSettings) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ExampleAlarmRingScreen(alarmSettings: alarmSettings),
        ));
    loadAlarms();
  }

  // navigateToAlarmScreen은 모달 하단 시트에 ExampleAlarmEditScreen을 표시하여 사용자가 알람 설정을 편집하거나 새 알람을 생성할 수 있게한다.
  // 시트는 화면 높이의 75%
  Future<void> navigateToAlarmScreen(AlarmSettings? settings) async {
    final res = await showModalBottomSheet<bool?>(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        builder: (context) {
          return FractionallySizedBox(
            heightFactor: 0.75,
            child: ExampleAlarmEditScreen(alarmSettings: settings),
          );
        });

    if (res != null && res == true) loadAlarms();
  }

  // 이 메소드는 위젯이 해제될 때 subscription을 정리한다.
  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  // 각 알람은 스와이프로 제거할 때 알람을 중지하는 onDismissed 콜백이 포함된 ExampleAlarmTile로 표현된다.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alarm Test')),
      body: SafeArea(
        child: alarms.isNotEmpty
            ? ListView.separated(
          itemCount: alarms.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            return ExampleAlarmTile(
              key: Key(alarms[index].id.toString()),
              title: TimeOfDay(
                hour: alarms[index].dateTime.hour,
                minute: alarms[index].dateTime.minute,
              ).format(context),
              onPressed: () => navigateToAlarmScreen(alarms[index]),
              onDismissed: () {
                Alarm.stop(alarms[index].id).then((_) => loadAlarms());
              },
            );
          },
        )
            : Center(   // 설정된 알람이 없으면 "No alarms set" 메시지 출력
          child: Text(
            "No alarms set",
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ExampleAlarmHomeShortcutButton(refreshAlarms: loadAlarms),
            FloatingActionButton(
              onPressed: () => navigateToAlarmScreen(null),
              child: const Icon(Icons.alarm_add_rounded, size: 33),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );

  }


}
