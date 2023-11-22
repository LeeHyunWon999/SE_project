import 'package:flutter/material.dart';
import 'package:se_project/alarm.dart';

class ExampleAlarmEditScreen extends StatefulWidget {
  final AlarmSettings? alarmSettings;

  ExampleAlarmEditScreen({this.alarmSettings});

  @override
  _ExampleAlarmEditScreenState createState() => _ExampleAlarmEditScreenState();
}

class _ExampleAlarmEditScreenState extends State<ExampleAlarmEditScreen> {
  DateTime selectedTime = DateTime.now();
  bool loopAudio = true;
  bool vibrate = true;
  bool systemVolumeMax = false;
  bool showNotification = true;
  bool complexNotification = false;
  String selectedSound = 'Marimba';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set Alarm'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              // TODO: 저장 로직 구현
              print("save 출력");
            },
          ),
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: <Widget>[
            ListTile(
              title: Text('Time'),
              subtitle: Text(
                '${selectedTime.hour}:${selectedTime.minute}',
                style: TextStyle(fontSize: 48),
              ),
              onTap: () async {
                final timeOfDay = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(selectedTime),
                );
                if (timeOfDay != null) {
                  setState(() {
                    selectedTime = DateTime(
                      selectedTime.year,
                      selectedTime.month,
                      selectedTime.day,
                      timeOfDay.hour,
                      timeOfDay.minute,
                    );
                  });
                }
              },
            ),
            SwitchListTile(
              title: Text('Loop alarm audio'),
              value: loopAudio,
              onChanged: (bool value) {
                setState(() {
                  loopAudio = value;
                });
              },
            ),
            SwitchListTile(
              title: Text('Vibrate'),
              value: vibrate,
              onChanged: (bool value) {
                setState(() {
                  vibrate = value;
                });
              },
            ),
            SwitchListTile(
              title: Text('System volume max'),
              value: systemVolumeMax,
              onChanged: (bool value) {
                setState(() {
                  systemVolumeMax = value;
                });
              },
            ),
            SwitchListTile(
              title: Text('Show notification'),
              value: showNotification,
              onChanged: (bool value) {
                setState(() {
                  showNotification = value;
                });
              },
            ),
            SwitchListTile(
                title: Text("Complex Alarm"),
                value: complexNotification,
                onChanged: (bool value) {
                  setState(() {
                    complexNotification = value;
                  });
                },
            ),
            ListTile(
              title: Text('Sound'),
              trailing: DropdownButton<String>(
                value: selectedSound,
                items: <String>['Marimba', 'Beep', 'Alarm'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedSound = newValue!;
                  });
                },
              ),
            ),
            // 여기에 추가 설정을 위한 위젯들을 추가할 수 있습니다.
          ],
        ),
      ),
    );
  }
}
