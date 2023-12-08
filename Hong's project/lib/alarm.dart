// ignore_for_file: avoid_print
// 알람 관리 : Alarm 클래스는 알람 설정, 중지, 확인 및 관리를 담당한다.
// 알람 초기화 : init 함수는 알람 서비스를 초기화하고 이전 세션에서 설정된 알람을 다시 예약한다.
// set 함수는 AlarmSettings 객체를 사용하여 알람을 예약한다. 필요한 경우 알림도 함께 예약된다.
// stop 함수는 지정된 ID의 알람을 중지한다.
// 알람 상태 확인 : hasAlarm, isRinging, getAlarm, getAlarms 함수를 통해 알람의 상태와 설정을 확인할 수 있다.

export 'package:se_project/alarm_settings.dart';
import 'dart:async';

import 'package:se_project/alarm_settings.dart';
import 'package:se_project/ios_alarm.dart';
import 'package:se_project/android_alarm.dart';
import 'package:se_project/notification.dart';
import 'package:se_project/storage.dart';
import 'package:flutter/foundation.dart';

/// Custom print function designed for Alarm plugin.
DebugPrintCallback alarmPrint = debugPrintThrottled;

class Alarm {
  /// Whether it's iOS device.
  static bool get iOS => defaultTargetPlatform == TargetPlatform.iOS;

  /// Whether it's Android device.
  static bool get android => defaultTargetPlatform == TargetPlatform.android;

  /// Stream of the ringing status.
  static final ringStream = StreamController<AlarmSettings>();

  /// Initializes Alarm services.
  ///
  /// Also calls [checkAlarm] that will reschedule alarms that were set before
  /// app termination.
  ///
  /// Set [showDebugLogs] to `false` to hide all the logs from the plugin.
  /// 알람 서비스를 초기화하고, 앱 종료 전에 설정된 알람을 다시 예약한다. 디버그 로그 표시 여부를 선택할 수 있다.
  static Future<void> init({bool showDebugLogs = true}) async {
    alarmPrint = (String? message, {int? wrapWidth}) {
      if (kDebugMode && showDebugLogs) {
        print("[Alarm] $message");
      }
    };

    await Future.wait([
      if (android) AndroidAlarm.init(),
      AlarmNotification.instance.init(),
      AlarmStorage.init(),
    ]);
    await checkAlarm();
  }

  /// Checks if some alarms were set on previous session.
  /// If it's the case then reschedules them.
  /// 이전 세션에 설정된 알람이 있는지 확인하고, 필요한 경우 다시 예약
  static Future<void> checkAlarm() async {
    final alarms = AlarmStorage.getSavedAlarms();

    for (final alarm in alarms) {
      final now = DateTime.now();
      if (alarm.dateTime.isAfter(now)) {
        await set(alarmSettings: alarm);
      } else {
        await AlarmStorage.unsaveAlarm(alarm.id);
      }
    }
  }

  /// Schedules an alarm with given [alarmSettings].
  ///
  /// If you set an alarm for the same [dateTime] as an existing one,
  /// the new alarm will replace the existing one.
  ///
  /// Also, schedules notification if [notificationTitle] and [notificationBody]
  /// are not null nor empty.
  /// 주어진 AlarmSettings에 따라 알람을 예약한다. 알람 시간과 동일한 새 알람이 기존 알람을 대체한다.
  /// notificationTitle과 notificationBody가 null이 아니면 알람과 함께 알림도 예약된다.
  static Future<bool> set({required AlarmSettings alarmSettings}) async {
    if (!alarmSettings.assetAudioPath.contains('.')) {
      throw AlarmException(
        'Provided asset audio file does not have extension: ${alarmSettings.assetAudioPath}',
      );
    }

    for (final alarm in Alarm.getAlarms()) {
      if (alarm.id == alarmSettings.id ||
          (alarm.dateTime.day == alarmSettings.dateTime.day &&
              alarm.dateTime.hour == alarmSettings.dateTime.hour &&
              alarm.dateTime.minute == alarmSettings.dateTime.minute)) {
        await Alarm.stop(alarm.id);
      }
    }

    await AlarmStorage.saveAlarm(alarmSettings);

    if (alarmSettings.notificationTitle != null &&
        alarmSettings.notificationBody != null) {
      if (alarmSettings.notificationTitle!.isNotEmpty &&
          alarmSettings.notificationBody!.isNotEmpty) {
        await AlarmNotification.instance.scheduleAlarmNotif(
          id: alarmSettings.id,
          dateTime: alarmSettings.dateTime,
          title: alarmSettings.notificationTitle!,
          body: alarmSettings.notificationBody!,
          fullScreenIntent: alarmSettings.androidFullScreenIntent,
        );
      }
    }

    if (alarmSettings.enableNotificationOnKill) {
      await AlarmNotification.instance.requestPermission();
    }

    if (iOS) {
      return IOSAlarm.setAlarm(
        alarmSettings,
            () => ringStream.add(alarmSettings),
      );
    } else
    if (android) {
      return await AndroidAlarm.set(
        alarmSettings,
            () => ringStream.add(alarmSettings),
      );
    }

    return false;
  }

  /// When the app is killed, all the processes are terminated
  /// so the alarm may never ring. By default, to warn the user, a notification
  /// is shown at the moment he kills the app.
  /// This methods allows you to customize this notification content.
  ///
  /// [title] default value is `Your alarm may not ring`
  ///
  /// [body] default value is `You killed the app. Please reopen so your alarm can ring.`
  static Future<void> setNotificationOnAppKillContent(
      String title,
      String body,
      ) =>
      AlarmStorage.setNotificationContentOnAppKill(title, body);

  /// Stops alarm.
  /// 지정된 ID의 알람을 중지한다.
  static Future<bool> stop(int id) async {
    await AlarmStorage.unsaveAlarm(id);

    AlarmNotification.instance.cancel(id);

    return iOS ? await IOSAlarm.stopAlarm(id) : await AndroidAlarm.stop(id);
  }

  /// Stops all the alarms.
  /// 모든 알람을 중지한다.
  static Future<void> stopAll() async {
    final alarms = AlarmStorage.getSavedAlarms();

    for (final alarm in alarms) {
      await stop(alarm.id);
    }
  }

  /// Whether the alarm is ringing.
  /// 지정된 ID의 알람이 울리고 있는지 확인한다.
  static Future<bool> isRinging(int id) async =>
      iOS ? await IOSAlarm.checkIfRinging(id) : AndroidAlarm.isRinging;

  /// Whether an alarm is set.
  /// 설정된 알람이 있는지 확인한다.
  static bool hasAlarm() => AlarmStorage.hasAlarm();

  /// Returns alarm by given id. Returns null if not found.
  /// 주어진 ID의 알람을 반환한다. 찾을 수 없는 경우 null을 반환
  static AlarmSettings? getAlarm(int id) {
    List<AlarmSettings> alarms = AlarmStorage.getSavedAlarms();

    for (final alarm in alarms) {
      if (alarm.id == id) return alarm;
    }
    alarmPrint('Alarm with id $id not found.');

    return null;
  }

  /// Returns all the alarms.
  /// 저장된 모든 알람을 반환한다.
  static List<AlarmSettings> getAlarms() => AlarmStorage.getSavedAlarms();
}

class AlarmException implements Exception {
  final String message;

  const AlarmException(this.message);

  @override
  String toString() => message;
}
