import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'requirement_2.dart';

import 'package:se_project/alarm.dart';
import 'package:se_project/edit_alarm.dart';
import 'package:se_project/ring.dart';
import 'package:se_project/complex_ring.dart';
// import 'package:se_project/shortcut_button.dart';
import 'package:se_project/tile.dart';
import 'package:se_project/home.dart';
import 'package:intl/intl.dart';
// import 'package:awesome_notifications/awesome_notifications.dart';

// dd
// 필수 요구사항 1번에 대한 기능들 작성 // Functions for mandatory requirements #1
// 다른 요구사항에서 1번의 수정이 필요한 경우 수정가능 // editable if other requirements needs to do



final double list_width = 500;


// Todo Item을 저장할 수 있는 자료구조(트리) 클래스 // Tree class : Todo Item
class TodoItem {
  static int ID_count = 0; // 아이디 구분용 정적변수 // static var for dividing ID
  int ID; // 개별 Task 구분용 아이디 // ID for dividing tasks
  String title; // 작업명(초기 생성 시 고정? 그럴 필요는 없지 않나?) // Task name
  String description; // 작업 설명 // Task description
  int priority; // 속성 : 우선순위(필수) // attr(necessary)
  String location; // 속성 : 수행장소(옵셔널) // attr(optional)
  List<TodoItem> relatedTasks; // 속성 : 연관작업목록 // attr(optional)
  List<String> tags; // 속성 : 태그 // attr(optional)
  List<TodoItem> subTasks; // 하위 작업들은 여기에 들어가는 구조 // subtasks stored here
  bool isCompleted; // 완료되었는가? // work for higher task's complete progress
  TodoItem?
  parent; // 자신의 부모 노드, root는 null을 가질 수 있음 // it's parent node(Item), root node can take parent 'null'
  double
  progress; // 하위 목록의 달성여부로 % 값 산정, 하위 100% 시 자동 완료판정 // progress percentage calculated by subTasks' complete or not, automatically change isComplete into true when subTasks are all done
  String url; // 추가정보 : URL // additional information : URL
  String fileName; // 추가정보 : 첨부파일 있는 경우 경로 // additional information : file path
  bool isAlarmEnabled;
  DateTime? alarmTime;

  // 생성자 // constructor
  TodoItem({
    this.ID = -1, // 이걸로 초기화되면 문제가 있는 것 // it's error value if ID is still -1
    required this.title,
    this.description = '',
    this.priority = 0,
    this.location = '',
    required this.relatedTasks,
    required this.tags,
    required this.subTasks,
    this.isCompleted = false,
    this.parent,
    this.progress =
    0.0, // 자식이 없다면 UI에서 프로그레스를 비활성화하는 방법도 생각중 // considering deactivate this option in UI when subtasks == 0
    this.url = '',
    this.fileName = '_',
    this.isAlarmEnabled = false,
    this.alarmTime,
  }) {
    ID = ID_count;
    ID_count++;
  }

  // 자신의 상위 아이템 반환(root 때문에 null값이 가능함, 이거 부를때 후처리 필요) // return parent's item(return value can be null, so post processing is needed)
  TodoItem? returnUpper() {
    return this.parent;
  }

  // 자식이 있는 경우, 자신의 progress 상태 갱신 // if subtask exsists, update it's progress
  void updateProgress() {
    if (this.subTasks.length == 0) {
      if (this.isCompleted == true)
        this.progress = 1.0;
      else
        this.progress = 0.0;
      return;
    } else {
      // Todo : 자식의 완료여부를 기준으로 상태 갱신 // update progress based on subtasks' completion
    }
  }

  // 자신의 하위 아이템 생성(생성 시 ) // create child item
  void createItem(
      String title,
      int priority,
      String location,
      List<TodoItem> relatedTasks,
      List<String> tags,
      List<TodoItem> subTasks,
      ) {
    TodoItem newItem = TodoItem(
      title: title,
      priority: priority,
      location: location,
      relatedTasks: relatedTasks,
      tags: tags,
      subTasks: subTasks,
    );
    this.subTasks.add(newItem);
    return;
  }

  // 이미 존재하는 아이템을 자신의 하위 아이템에 추가 // add existing item into its subtask
  void addItem(TodoItem tempItem) {
    subTasks.add(tempItem);
  }

  // 자신의 속성 수정(완료상태와 하위목록은 따로 빼기) // edit its attr(except isCompleted and subTasks)
  void editItem(
      String title,
      int priority,
      String location,
      List<TodoItem> relatedTasks,
      List<String> tags,
      ) {
    this.title = title;
    this.priority = priority;
    this.location = location;
    this.relatedTasks = relatedTasks;
    this.tags = tags;
    this.subTasks = subTasks;
  }
}


// // 작업목록 클릭 시 정보 및 수정창 띄워주는 위젯(루트와 하위 둘다 이게 필요) // modification window(needed by root and sub tasks)
// class informWindowWidget extends StatefulWidget {
//   @override
//   _informWindowWidgetState createState() => _informWindowWidgetState();
// }
//
// // 후속 클래스
// class _informWindowWidgetState extends State<informWindowWidget> {
//
//   Widget build(BuildContext context) {
//     return
//   }
// }


void showEditAlarmModal(BuildContext context, Function(DateTime) onSave) {
  showModalBottomSheet(
    context: context,
    enableDrag: true,
    showDragHandle: true,
    isScrollControlled: false,
    // isScrollControlled: true, // 모달을 전체 화면으로 표시하려면 true로 설정
    builder: (BuildContext context) {
      // return Container(
      //   padding: EdgeInsets.only(
      //     bottom: MediaQuery.of(context).viewInsets.bottom,
      //   ),
      //   child: ExampleAlarmEditScreen(),
      // );
      return ExampleAlarmEditScreen(
        onSave: onSave,
      );
    },
  );
}

// 정보 및 수정창 // information & edit window
void informWindow(BuildContext context, TodoItem item, List<TodoItem> items,
    Function createTask, Function removeTask) {
  DateTime? alarmTime;
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text(item.title + "Attributes"),
            content: Column(
              children: [
                Text(
                    "Show here editable attrs, Description, Hyperlinks, File + preview"),
                // 여기에 각종 속성 보기 및 수정작업 // attrs and editing features here
                Text("Description : " + item.description),
                // 수정 가능한 블럭으로 바꿔야 함, 이것 말고 나머지들도 // needed to be change into editable block, others also
                Text("Priority : " + item.priority.toString()),
                Text("Tags : " + item.tags.toString()),
                Text("Location : " + item.location.toString()),
                Text("Related Tasks : " + item.relatedTasks.toString()),
                // 직접 클릭하는걸로 변경해야 보일듯 // it would visable if create option changes into clickable object
                Text("Progress : " +
                    (item.progress * 100).toString() +
                    "%"),
                SizedBox(
                  height: 10,
                ),
                Container(
                  height: 10,
                  color: Colors.black26,
                ),
                Text("Additional Informations",
                    style: TextStyle(
                      fontSize: 20,
                    )),
                Column(
                  children: [
                    Text("Hyperlink : "),
                    InkWell(
                      onTap: () async {
                        if (!await launch(item.url))
                          throw 'Could not launch $item.url';
                      },
                      child: Text(
                        item.url,
                        style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline),
                      ),
                    )
                  ],
                ),
                Text("file : ${item.fileName}"),
                TextButton(
                  child: Text("upload"),
                  onPressed: (){pickAndSaveFileLocally(item);},
                ),
                TextButton(
                  child: Text("download"),
                  onPressed: (){copyFileToStorage(item, item.fileName);},
                ),
              ],
            ),
            actions: <Widget>[
              Container(
                // 새 하위작업 생성 // create new subtask
                child: ElevatedButton(
                  onPressed: () {
                    //Navigator.of(context).pop(); //창 닫기 // close Dialog with apply changes
                    // TextEditingController 추가로 Task 요소 관리하며 새 작업 생성 // managing TextField content : using controllers
                    final TaskNameController = TextEditingController();
                    final TaskPriorController = TextEditingController();
                    final TaskLocController = TextEditingController();
                    final TaskRelateController =
                    TextEditingController();
                    final TaskTagController = TextEditingController();
                    // 이들 중 일부는 상황에 따라 쓰이지 않거나 바뀔 수도 있음 // some of these could be not used or changed
                    // myController.text 형식으로 접근 // access fields by like myController.text

                    showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Icon(Icons.add),
                          content: Container(
                            // 너비지정용 // setting width by this
                            width: 600,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("creating subTask UI"),
                                TextField(
                                    controller: TaskNameController,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Task name',
                                    )),
                                SizedBox(
                                  height: 10,
                                ),
                                TextField(
                                    controller: TaskPriorController,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText:
                                      'Priority(need to be change into number input)',
                                    )),
                                SizedBox(
                                  height: 10,
                                ),
                                TextField(
                                    controller: TaskLocController,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'location(optional)',
                                    )),
                                SizedBox(
                                  height: 10,
                                ),
                                TextField(
                                    controller: TaskRelateController,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText:
                                      'related Tasks(optional)(need to be change into task select box)',
                                    )),
                                SizedBox(
                                  height: 10,
                                ),
                                TextField(
                                    controller: TaskTagController,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText:
                                      'tags(optional)(no need to be change but need to parsing to use)',
                                    )),
                                // 하위작업은 루트작업 생성 후 진행 // subTask is not added at creating root Task
                                SizedBox(
                                  height: 10,
                                ),
                                //!!
                              ],
                            ),
                          ),
                          actions: <Widget>[
                            Container(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); //창 닫기 // close Dialog with Create tasks
                                  // 작업 생성 시도
                                  createTask();
                                },
                                child: Text("Create"),
                              ),
                            ),
                            Container(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); //창 닫기 // close Dialog with cancel
                                },
                                child: Text("Cancel"),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text("Create SubTask.."),
                ),
              ),
              Container(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pop(); //창 닫기 // close Dialog with apply changes
                  },
                  child: Text("Apply"),
                ),
              ),
              Container(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pop(); //창 닫기 // close Dialog with discard changes
                  },
                  child: Text("Cancel"),
                ),
              ),
              Container(
                child: ElevatedButton(
                  onPressed: () {
                    // 상위 컨텍스트 저장
                    BuildContext parentDialogContext = context;
                    // 진짜 삭제할 것인지 묻기 // ask really want to delete
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: Text(
                                "Do you really want to delete this task?\n All subtasks will also be deleted."),
                            actions: <Widget>[
                              Container(
                                child: ElevatedButton(
                                  onPressed: () {
                                    // 삭제작업 진행
                                    removeTask();
                                    Navigator.of(parentDialogContext)
                                        .pop();
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("Yes"),
                                ),
                              ),
                              Container(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("No"),
                                ),
                              ),
                            ],
                          );
                        });
                  },
                  child: Text("Delete"),
                ),
              ),
              // Container(
              //   child: ElevatedButton(
              //     onPressed: () => showEditAlarmModal(context),
              //     child: Text("Notification"),
              //   ),
              // ),
              SwitchListTile(
                title: Text("Set Alarm"),
                value: item.isAlarmEnabled,
                onChanged: (bool value) {
                  setState(() {
                    item.isAlarmEnabled = value;
                    if (value) {
                      // toggle이 켜질 때만 모달 표시
                      showEditAlarmModal(context, (DateTime time){
                        // Update the TodoItem with the alarm time
                        setState(() {
                          item.alarmTime = time;
                        });
                      });
                      // toggle이 꺼질 때는 아무것도 하지 않음.
                    } // if
                  });
                },
              ),

              // Text("Alarm time : ${item.alarmTime}")
              Text("Alarm time : ${item.isAlarmEnabled && item.alarmTime != null ? DateFormat('MM/dd HH:mm').format(item.alarmTime!) : 'no settings'}")

            ],
          );
        },
      );
    },
  );
}


// GPT로 생성한 할 일 리스트(트리구조로 변경 필요) // GPT-generated Todo List, need to be changed into tree form
class TodoList extends StatefulWidget {
  final List<TodoItem> items;

  TodoList({required this.items});

  @override
  _TodoListState createState() => _TodoListState();
}

// 위에껀 상태 변경 가능한 위젯 껍데기고, 이게 위젯 내부의 내용을 채워주는 자유로운 내부 핵심 클래스 // Upper class is 'stateful' outer class, this is core class
class _TodoListState extends State<TodoList> {
  late List<AlarmSettings> alarms;

  static StreamSubscription? subscription;

  @override
  void initState() {
    super.initState();
    loadAlarms();
    subscription ??= Alarm.ringStream.stream.listen(    // subscription이 null이면, 알람이 울리면 navigateToRingScreen을 트리거하는 Alarm.ringStream을 듣도록 설정됨.
          (alarmSettings) { navigateToRingScreen(alarmSettings, );
    });
  }



  // Alarm.getAlarms()의 반환값으로 alarms 리스트의 상태를 설정하고, 날짜와 시간으로 알람을 정렬하여 표시
  void loadAlarms() {
    setState(() {
      alarms = Alarm.getAlarms();
      alarms.sort((a, b) => a.dateTime.isBefore(b.dateTime) ? 0 : 1);
    });
  }

  // navigateToRingScreen은 AlarmSettings 객체를 가져와 알람이 울릴 때 ExampleAlarmRingScreen으로 네비게이션
  // Future<void> navigateToRingScreen(AlarmSettings alarmSettings) async {
  //   await Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) =>
  //             ExampleAlarmRingScreen(alarmSettings: alarmSettings),
  //       ));
  //   loadAlarms();
  // }

  Future<void> navigateToRingScreen(AlarmSettings alarmSettings) async {
    // complexNotification 값에 따라 다른 스크린으로 네비게이션
    if (alarmSettings.complexNotification) {
       //ComplexAlarmRingScreen으로 네비게이션
        await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ComplexAlarmRingScreen(alarmSettings: alarmSettings),
        ),
      );

    } else {
      // ExampleAlarmRingScreen으로 네비게이션
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ExampleAlarmRingScreen(
            alarmSettings: alarmSettings,),
        ),
      );

    }
    loadAlarms();
  }



  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        return _buildItem2(widget.items, widget.items[index]); // 0층 빌드
      },
    );
  }



  // 상태변경 콜백 메소드 : 작업생성 // setState callback : create task
  void createTask(TodoItem item,
      TextEditingController TaskNameController,
      TextEditingController TaskTagController,
      TextEditingController TaskLocController,
      ) {
    setState(() {
      item.subTasks.add(TodoItem(
          title: TaskNameController.text,
          relatedTasks: [],
          // 임시 : 연관작업에 컨트롤러 연동시키기 // temp : allocate related job into controller
          tags: TaskTagController.text
              .split(","),
          subTasks: [],
          location:
          TaskLocController.text));
    });
  }


  // 상태변경 콜백 메소드 : 작업삭제 // setState callback : remove task
  void removeTask(List<TodoItem> items, TodoItem item) {
    setState(() {
      items.remove(item);
    });
  }

  // 재귀적으로 TodoItem을 빌드하여 계층구조 구현 // implement data structure by building TodoItem recursively
  Widget _buildItem(List<TodoItem> items, TodoItem item, [int depth = 0]) {
    return Column(
      children: [
        Container(
          width: list_width,
          child: ListTile(
            contentPadding: EdgeInsets.only(left: 16.0 + depth * 16.0),
            // 하위작업 들여쓰기용 패딩 // inset padding for subtasks
            title: Row(
              // 필요한 속성이 있는 경우 제목 옆에 간략하게 표시
              children: [
                Text(item.title),
                SizedBox(width: 8.0),
                Icon(Icons.star, color: Colors.yellow),
              ],
            ),
            trailing: Checkbox(
              value: item.isCompleted,
              onChanged: (bool? value) {
                setState(() {
                  item.isCompleted = value!;
                  item.updateProgress();
                });
              },
            ),
            onTap: () {
              // 클릭 시 속성 확인 및 수정 가능 페이지로 이동하는 것을 구상중 // thinking of onClick : check attr & editing page
              informWindow(context, item, items, createTask, removeTask,);
            },
          ),
        ),
        // 하위 작업을 여기서 빌드 // build subtasks here
        for (var subItem in item.subTasks)
          _buildItem(item.subTasks, subItem, depth + 1)
      ],
    );
  }

  // 임시 : 최상위 항목에만 드래그 기능 추가 버전 // Temp : Draggable in root task
  Widget _buildItem2(List<TodoItem> items, TodoItem item, [int depth = 0]) {
    Widget listItem = _buildListTile(items, item, depth); // 기존의 리스트 타일

    // 최상위 항목에만 드래그 기능 추가
    if (depth == 0) {
      return GestureDetector(
        onLongPress: () {
          // 여기에 길게 누를 때의 동작을 추가하실 수 있습니다.
          print("Long pressed: ${item.title}");
        },
        child: _buildDragTarget(
            items,
            LongPressDraggable<TodoItem>(
              data: item,
              child: listItem,
              feedback: Material(
                elevation: 4.0,
                child: listItem,
              ),
              childWhenDragging: Container(), // 드래그 중 원래 위치에 보여질 위젯
            ),
            item),
      );
    } else {
      return listItem;
    }
  }

  // 임시 항목의 하위목록 작성하는 메소드 // method following buildItem2
  Widget _buildListTile(List<TodoItem> items, TodoItem item, int depth) {
    return Column(
      children: [
        Container(
          width: list_width,
          child: ListTile(
            contentPadding: EdgeInsets.only(left: 16.0 + depth * 16.0),
            title: Row(
              children: [
                Text(item.title),
                SizedBox(width: 8.0),
                Icon(Icons.star, color: Colors.yellow),
              ],
            ),
            trailing: Checkbox(
              value: item.isCompleted,
              onChanged: (bool? value) {
                setState(() {
                  item.isCompleted = value!;
                  item.updateProgress();
                });
              },
            ),
            onTap: () {
              // 항목 클릭 시 로직 : 창 켜기
              informWindow(context, item, items, createTask, removeTask,);
            },
          ),
        ),
        for (var subItem in item.subTasks)
          _buildItem(item.subTasks, subItem, depth + 1),
      ],
    );
  }

  // 드래그 앤 드롭 이벤트 처리에 쓰이는 위젯 // widget used at Drag & Drop event
  Widget _buildDragTarget(
      List<TodoItem> items, Widget draggableItem, TodoItem item) {
    return DragTarget<TodoItem>(
      onWillAccept: (receivedItem) {
        // 드롭할 수 있는지 결정하는 조건
        // 예: 같은 리스트 내에서만 드롭 가능하도록 설정
        // return receivedItem != null && receivedItem.listId == item.listId;
        return receivedItem != null; // 여기서는 모든 항목을 받아들임
      },
      onAccept: (receivedItem) {
        // 드롭 이벤트 처리
        int oldIndex = items.indexOf(receivedItem);
        int newIndex = items.indexOf(item);

        if (oldIndex < newIndex) {
          newIndex -= 1;
        }

        TodoItem movedItem = items.removeAt(oldIndex);
        items.insert(newIndex, movedItem);

        // 상태 업데이트
        setState(() {
          // 여기서는 items 리스트를 업데이트합니다.
          // 필요에 따라 다른 처리를 추가할 수 있습니다.
        });
      },
      builder: (BuildContext context, List<TodoItem?> candidateData,
          List<dynamic> rejectedData) {
        return Container(
          // 드래그 항목을 표시하는 데 사용되는 위젯
          child: draggableItem,
        );
      },
    );
  }
}

// 작업 생성, 드래그&드롭 및 표시 등 관리해주는 클래스 // Create, Drag&Drop, etc. managing Class
class ItemManager {
  // 자료구조 변수, 초기화는 나중에 생성하면서 진행 // Var : TodoItem, init later
  late TodoItem ItemTree;
}