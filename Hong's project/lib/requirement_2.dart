import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

import 'requirement_1.dart';

// 권한 함수 // permission function
Future<void> requestPermissions() async {
  var status = await Permission.storage.status;
  if (!status.isGranted) {
    await Permission.storage.request();
  }

  // Android 11(API level 30) 이상에서 외부 저장소 관리 권한이 필요한 경우 // permission for higher API level
  if (await Permission.manageExternalStorage.status.isDenied) {
    print("권한설정안됨 다시할거임");
    await Permission.manageExternalStorage.request();
    if (await Permission.manageExternalStorage.status.isGranted) {
      print("권한얻기 완료!");
    }
  }
}

// 파일 업로드 함수 // file upload
Future<void> pickAndSaveFileLocally(TodoItem item) async {
  FilePickerResult? result = await FilePicker.platform.pickFiles();

  if (result != null) {
    PlatformFile pickedFile = result.files.first;
    File file = File(pickedFile.path!);

    // 읽기 // read
    final contents = await file.readAsBytes();
    print("읽기완료");

    // 로컬 경로 찾기 // find local path
    final directory = await getApplicationDocumentsDirectory();
    final localPath = directory.path;



    print("저장경로 : ${localPath}");

    // 쓰기 // upload at app directory
    final localFile = File('$localPath/${item.ID}/${pickedFile.name}');

    // 경로가 없는 경우 생성
    if(!await localFile.parent.exists()) {
      await localFile.parent.create(recursive: true);
    }
    await localFile.writeAsBytes(contents);

    print('File saved to $localPath/${item.ID}/${pickedFile.name}');

    // 파일명 저장
    item.fileName = pickedFile.name;
  } else {
    // 사용자가 파일 선택을 취소한 경우 // if user cancels process
    print('No file selected.');
  }
}




// 자료 다운 함수 // file download to external storage
Future<void> copyFileToStorage(TodoItem item, String fileName) async {
  final tempDir = await getApplicationDocumentsDirectory();
  final tempFilePath = '${tempDir.path}/${item.ID}/$fileName';

  // 앱 내부의 임시 파일 읽기 // read file
  final tempFile = File(tempFilePath);

  // 여기도 경로가 없는 경우 생성
  if(!await tempFile.parent.exists()) {
    await tempFile.parent.create(recursive: true);
  }

  print('Temp file path: $tempFilePath');
  print('Does temp file exist: ${tempFile.existsSync()}');

  if (tempFile.existsSync()) {
    final storageDir = await getExternalStorageDirectory();
    final storageFilePath = '${storageDir!.path}/${item.ID}/$fileName';

    print('얻어올 파일 경로 : ${tempFilePath}');
    print('파일 다운할 외부 경로 : ${storageFilePath}');

    // 여기도 경로 없는 경우 폴더 생성
    final pathTest = File(storageFilePath);
    if(!await pathTest.parent.exists()) {
      await pathTest.parent.create(recursive: true);
    }


    // 앱 내부 파일을 사용자의 스토리지로 복사 // copy to external storage
    await tempFile.copy(storageFilePath);


    print('File copied to user storage: $storageFilePath');
  } else {
    print('Temp file does not exist');
  }
}