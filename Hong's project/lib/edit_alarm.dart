import 'package:se_project/alarm.dart';
import 'package:flutter/material.dart';


import 'package:se_project/requirement_1.dart';

// 알람 설정 화면을 구현하는 데 사용
// 이 화면은 사용자가 알람을 설정하고 조정할 수 있는 여러 옵션을 제공.
class ExampleAlarmEditScreen extends StatefulWidget {
  final AlarmSettings? alarmSettings; // 'alarmSetting' : 기존 알람 설정을 받아올 수 있는 선택적 매개변수
  final Function(DateTime)? onSave; // 콜백 함수 추가


  const ExampleAlarmEditScreen({Key? key, this.alarmSettings, this.onSave,}) // State<ExampleAlarmEditScreen> 타입의 상태 클래스를 반환하는 createState 메서드를 오버라이드
      : super(key: key);

  @override
  State<ExampleAlarmEditScreen> createState() => _ExampleAlarmEditScreenState();
}

class _ExampleAlarmEditScreenState extends State<ExampleAlarmEditScreen> {
  // loading, creating, selectedDateTime ... assetAudio 등 다양한 상태 변수들
  bool loading = false;

  late bool creating;
  late DateTime selectedDateTime;
  late bool loopAudio;
  late bool vibrate;
  late bool volumeMax;
  late bool showNotification;
  late bool complexNotification;
  late String assetAudio;


  @override
  void initState() {    // 화면이 처음 로드될 때 호출되어 변수들을 초기화. 새 알람을 생성하는 경우 기본값을 설정하고, 기존 알람을 수정하는 경우 해당 값들을 기존 설정에서 가져옴
    super.initState();
    creating = widget.alarmSettings == null;

    if (creating) {
      selectedDateTime = DateTime.now().add(const Duration(minutes: 1));
      selectedDateTime = selectedDateTime.copyWith(second: 0, millisecond: 0);
      loopAudio = true;
      vibrate = true;
      volumeMax = false;
      showNotification = true;
      complexNotification = false;
      assetAudio = 'assets/marimba.mp3';
      //assetAudio = 'C:/Users/Kwon/AndroidStudioProjects/se_project/assets/marimba.mp3';

    } else {
      selectedDateTime = widget.alarmSettings!.dateTime;
      loopAudio = widget.alarmSettings!.loopAudio;
      vibrate = widget.alarmSettings!.vibrate;
      volumeMax = widget.alarmSettings!.volumeMax;
      complexNotification = widget.alarmSettings!.complexNotification;
      showNotification = widget.alarmSettings!.notificationTitle != null &&
          widget.alarmSettings!.notificationTitle!.isNotEmpty &&
          widget.alarmSettings!.notificationBody != null &&
          widget.alarmSettings!.notificationBody!.isNotEmpty;
      assetAudio = widget.alarmSettings!.assetAudioPath;
    }
  }


  String getDay() {   // 선택된 날짜가 현재 날짜와 얼마나 덜어져 있는지를 계산하여 문자열로 반환
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final difference = selectedDateTime.difference(today).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference == 2) {
      return 'After tomorrow';
    } else {
      return 'In $difference days';
    }
  }

  Future<void> pickTime() async {   // 시간 선택기를 보여주고, 사용자가 시간을 선택하면 그에 따라 selectedDateTime을 업데이트
    final res = await showTimePicker(
      initialTime: TimeOfDay.fromDateTime(selectedDateTime),
      context: context,
    );

    if (res != null) {
      setState(() {
        selectedDateTime = selectedDateTime.copyWith(
          hour: res.hour,
          minute: res.minute,
        );
        if (selectedDateTime.isBefore(DateTime.now())) {
          selectedDateTime = selectedDateTime.add(const Duration(days: 1));
        }
      });
    }
  }

  AlarmSettings buildAlarmSettings() {    // 현재 선택된 옵션들로부터 AlarmSettings 객체를 생성.
    final id = creating
        ? DateTime.now().millisecondsSinceEpoch % 10000
        : widget.alarmSettings!.id;

    final alarmSettings = AlarmSettings(
      id: id,
      dateTime: selectedDateTime,
      loopAudio: loopAudio,
      vibrate: vibrate,
      volumeMax: volumeMax,
      complexNotification: complexNotification,
      notificationTitle: showNotification ? 'Alarm example' : null,
      notificationBody: showNotification ? 'Your alarm ($id) is ringing' : null,
      assetAudioPath: assetAudio,
    );
    return alarmSettings;
  }

  void saveAlarm() { // 설정된 알람을 저장한다. 비동기로 'Alarm.set'을 호출하고, 성공적으로 저장되면 화면을 닫는다.
    setState(() => loading = true);
    final alarmSettings = buildAlarmSettings();
    print("Alarm Time : ${alarmSettings.dateTime}");

    Alarm.set(alarmSettings: buildAlarmSettings()).then((res) {
        print("Alarm Setting");
        widget.onSave?.call(alarmSettings.dateTime);
        Navigator.of(context).pop();
    });
    setState(() => loading = false);
  }

  void deleteAlarm() {    // 기존 알람을 삭제. 비동기로 'Alarm.set'을 호출하고, 성공적으로 삭제되면 화면을 닫는다.
    Alarm.stop(widget.alarmSettings!.id).then((res) {
      if (res) Navigator.pop(context, true);
    });
  }

  @override
  Widget build(BuildContext context) {    // UI를 빌드하는 메서드. 'Column' 위젯을 사용하여 화면 구성요소를 세로로 배열
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    "Cancel",
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(color: Colors.blueAccent),
                  ),
                ),
                TextButton(
                  onPressed: () => {saveAlarm(),
                    print("save"),
                    print("setting time : ")
                  },
                  child: loading
                      ? const CircularProgressIndicator()
                      : Text(
                    "Save",
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(color: Colors.blueAccent),
                  ),
                ),
              ],
            ),
            Text(
              getDay(),
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(color: Colors.blueAccent.withOpacity(0.8)),
            ),
            RawMaterialButton(
              onPressed: pickTime,
              fillColor: Colors.grey[200],
              child: Container(
                margin: const EdgeInsets.all(20),
                child: Text(
                  TimeOfDay.fromDateTime(selectedDateTime).format(context),
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium!
                      .copyWith(color: Colors.blueAccent),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Loop alarm audio',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Switch(
                  value: loopAudio,
                  onChanged: (value) => setState(() => loopAudio = value),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Vibrate',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Switch(
                  value: vibrate,
                  onChanged: (value) => setState(() => vibrate = value),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'System volume max',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Switch(
                  value: volumeMax,
                  onChanged: (value) => setState(() => volumeMax = value),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Show notification',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Switch(
                  value: showNotification,
                  onChanged: (value) => setState(() => showNotification = value),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Complex notification',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Switch(
                  value: complexNotification,
                  onChanged: (value) => setState(() => complexNotification = value),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sound',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                DropdownButton(
                  value: assetAudio,
                  items: const [
                    DropdownMenuItem<String>(
                      value: 'assets/marimba.mp3',
                      //value: 'C:/Users/Kwon/AndroidStudioProjects/se_project/assets/marimba.mp3',
                      child: Text('Marimba'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'assets/nokia.mp3',
                      child: Text('Nokia'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'assets/mozart.mp3',
                      child: Text('Mozart'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'assets/star_wars.mp3',
                      child: Text('Star Wars'),
                    ),
                    DropdownMenuItem<String>(
                      value: 'assets/one_piece.mp3',
                      child: Text('One Piece'),
                    ),
                  ],
                  onChanged: (value) => setState(() => assetAudio = value!),
                ),
              ],
            ),
            if (!creating)
              TextButton(
                onPressed: deleteAlarm,
                child: Text(
                  'Delete Alarm',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: Colors.red),
                ),
              ),
            const SizedBox(),
          ],
        ),
      ),
    );
  }
}