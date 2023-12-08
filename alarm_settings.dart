/// 알림에 초기 설정 클래스
class AlarmSettings {
  /// 알람의 고유 식별자
  final int id;

  /// 알람이 발동될 날짜와 시간
  final DateTime dateTime;

  /// Path to audio asset to be used as the alarm ringtone. Accepted formats:
  /// 알람 벨소리로 사용될 오디오d 파일의 경로
  /// * Project asset: `assets/your_audio.mp3`.
  /// * Local asset: `/path/to/your/audio.mp3`, which is your `File.path`.
  final String assetAudioPath;

  /// If true, [assetAudioPath] will repeat indefinitely until alarm is stopped.
  /// 오디오가 무한 반복되어야 하는지 여부를 결정하는 부울 값
  final bool loopAudio;

  /// If true, device will vibrate for 500ms, pause for 500ms and repeat until
  /// alarm is stopped.
  /// 알람이 울릴 때 기기가 진동해야 하는지 여부
  /// If [loopAudio] is set to false, vibrations will stop when audio ends.
  final bool vibrate;

  /// If true, set system volume to maximum when [dateTime] is reached
  /// and set it back to its previous value when alarm is stopped.
  /// Else, use current system volume. Enabled by default.
  /// 참일 경우, 알람이 울릴 때 시스템 볼륨을 최대로 설정
  final bool volumeMax;

  final bool complexNotification;

  /// Duration, in seconds, over which to fade the alarm ringtone.
  /// Set to 0.0 by default, which means no fade.
  /// 알람 벨소리가 점차 커지는 데 걸리는 시간
  final double fadeDuration;

  /// Title of the notification to be shown when alarm is triggered.
  /// Must not be null nor empty to show a notification.
  /// 알람이 울릴 때 표시될 알림의 제목
  final String? notificationTitle;

  /// Body of the notification to be shown when alarm is triggered.
  /// Must not be null nor empty to show a notification.
  /// 알람이 울릴 때 표시될 알림의 제목
  final String? notificationBody;

  /// Whether to show a notification when application is killed to warn
  /// the user that the alarms won't ring anymore. Enabled by default.
  /// 애플리케이션이 종료될 때 알람이 더 이상 울리지 않는다는 것을 사용자에게 경고하는 알림을 표시할지 여부
  final bool enableNotificationOnKill;

  /// Stops the alarm on opened notification.
  /// 참일 경우, 알림을 열면 알람이 정지
  final bool stopOnNotificationOpen;

  /// Whether to turn screen on when android alarm notification is triggered. Enabled by default.
  ///
  /// [notificationTitle] and [notificationBody] must not be null nor empty.
  /// 알람이 울릴 때 전체 화면 인텐트로 화면을 켤지 여부를 결정
  final bool androidFullScreenIntent;

  /// Returns a hash code for this `AlarmSettings` instance using Jenkins hash function.
  /// 각 'AlarmSettings' 인스턴스에 대한 고유한 해시를 생성하는 사용자 정의 'hashCode' 메서드
  @override
  int get hashCode {
    var hash = 0;

    hash = hash ^ id.hashCode;
    hash = hash ^ dateTime.hashCode;
    hash = hash ^ assetAudioPath.hashCode;
    hash = hash ^ loopAudio.hashCode;
    hash = hash ^ vibrate.hashCode;
    hash = hash ^ volumeMax.hashCode;
    hash = hash ^ fadeDuration.hashCode;
    hash = hash ^ (notificationTitle?.hashCode ?? 0);
    hash = hash ^ (notificationBody?.hashCode ?? 0);
    hash = hash ^ enableNotificationOnKill.hashCode;
    hash = hash ^ stopOnNotificationOpen.hashCode;
    hash = hash ^ complexNotification.hashCode;
    hash = hash & 0x3fffffff;

    return hash;
  }

  /// Model that contains all the settings to customize and set an alarm.
  ///
  ///
  /// Note that if you want to show a notification when alarm is triggered,
  /// both [notificationTitle] and [notificationBody] must not be null nor empty.
  const AlarmSettings({
    required this.id,
    required this.dateTime,
    required this.assetAudioPath,
    this.loopAudio = true,
    this.vibrate = true,
    this.volumeMax = true,
    this.fadeDuration = 0.0,
    this.notificationTitle,
    this.notificationBody,
    this.enableNotificationOnKill = true,
    this.stopOnNotificationOpen = false,
    this.androidFullScreenIntent = true,
    this.complexNotification = false,
  });

  /// Constructs an `AlarmSettings` instance from the given JSON data.
  /// JSON 데이터로부터 인스턴스를 생성하는 fromJson 팩토리 생성자
  factory AlarmSettings.fromJson(Map<String, dynamic> json) => AlarmSettings(
    id: json['id'] as int,
    dateTime: DateTime.fromMicrosecondsSinceEpoch(json['dateTime'] as int),
    assetAudioPath: json['assetAudioPath'] as String,
    loopAudio: json['loopAudio'] as bool,
    vibrate: json['vibrate'] as bool,
    volumeMax: json['volumeMax'] as bool,
    fadeDuration: json['fadeDuration'] as double,
    notificationTitle: json['notificationTitle'] as String?,
    notificationBody: json['notificationBody'] as String?,
    enableNotificationOnKill: json['enableNotificationOnKill'] as bool,
    stopOnNotificationOpen: json['stopOnNotificationOpen'] as bool,
    androidFullScreenIntent:
    json['androidFullScreenIntent'] as bool? ?? false,
  );

  /// Creates a copy of `AlarmSettings` but with the given fields replaced with
  /// the new values.
  /// 변경된 필드로 인스턴스의 복사본을 생성하는 copyWith 메서드
  AlarmSettings copyWith({
    int? id,
    DateTime? dateTime,
    String? assetAudioPath,
    bool? loopAudio,
    bool? vibrate,
    bool? volumeMax,
    double? fadeDuration,
    String? notificationTitle,
    String? notificationBody,
    bool? enableNotificationOnKill,
    bool? stopOnNotificationOpen,
    bool? androidFullScreenIntent,
  }) {
    return AlarmSettings(
      id: id ?? this.id,
      dateTime: dateTime ?? this.dateTime,
      assetAudioPath: assetAudioPath ?? this.assetAudioPath,
      loopAudio: loopAudio ?? this.loopAudio,
      vibrate: vibrate ?? this.vibrate,
      volumeMax: volumeMax ?? this.volumeMax,
      fadeDuration: fadeDuration ?? this.fadeDuration,
      notificationTitle: notificationTitle ?? this.notificationTitle,
      notificationBody: notificationBody ?? this.notificationBody,
      enableNotificationOnKill:
      enableNotificationOnKill ?? this.enableNotificationOnKill,
      stopOnNotificationOpen:
      stopOnNotificationOpen ?? this.stopOnNotificationOpen,
      androidFullScreenIntent:
      androidFullScreenIntent ?? this.androidFullScreenIntent,
    );
  }

  /// Converts this `AlarmSettings` instance to JSON data.
  /// 인스턴스를 JSON 데이터로 변환하는 toJson 메서드
  Map<String, dynamic> toJson() => {
    'id': id,
    'dateTime': dateTime.microsecondsSinceEpoch,
    'assetAudioPath': assetAudioPath,
    'loopAudio': loopAudio,
    'vibrate': vibrate,
    'volumeMax': volumeMax,
    'fadeDuration': fadeDuration,
    'notificationTitle': notificationTitle,
    'notificationBody': notificationBody,
    'enableNotificationOnKill': enableNotificationOnKill,
    'stopOnNotificationOpen': stopOnNotificationOpen,
    'androidFullScreenIntent': androidFullScreenIntent,
  };

  /// Returns all the properties of `AlarmSettings` for debug purposes.
  @override
  String toString() {
    Map<String, dynamic> json = toJson();
    json['dateTime'] = DateTime.fromMicrosecondsSinceEpoch(json['dateTime']);

    return "AlarmSettings: ${json.toString()}";
  }

  /// Compares two AlarmSettings.
  /// AlarmSettings 인스턴스의 동등성을 비교하기 위한 operator ==
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AlarmSettings &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              dateTime == other.dateTime &&
              assetAudioPath == other.assetAudioPath &&
              loopAudio == other.loopAudio &&
              vibrate == other.vibrate &&
              volumeMax == other.volumeMax &&
              fadeDuration == other.fadeDuration &&
              notificationTitle == other.notificationTitle &&
              notificationBody == other.notificationBody &&
              enableNotificationOnKill == other.enableNotificationOnKill &&
              stopOnNotificationOpen == other.stopOnNotificationOpen &&
              androidFullScreenIntent == other.androidFullScreenIntent;
}
