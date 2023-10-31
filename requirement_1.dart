import 'package:flutter/material.dart';


// 필수 요구사항 1번에 대한 기능들 작성 // Functions for mandatory requirements #1


// Todo Item을 저장할 수 있는 자료구조(트리) 클래스 // Tree class : Todo Item
class TodoItem {
  String title; // 작업명(초기 생성 시 고정? 그럴 필요는 없지 않나?) // Task name
  String description; // 작업 설명 // Task description
  int priority; // 속성 : 우선순위(필수) // attr(necessary)
  String location; // 속성 : 수행장소(옵셔널) // attr(optional)
  List<TodoItem> relatedTasks; // 속성 : 연관작업목록 // attr(optional)
  List<String> tags; // 속성 : 태그 // attr(optional)
  List<TodoItem> subTasks; // 하위 작업들은 여기에 들어가는 구조 // subtasks stored here
  bool isCompleted; // 완료되었는가? // work for higher task's complete progress
  TodoItem? parent; // 자신의 부모 노드, root는 null을 가질 수 있음 // it's parent node(Item), root node can take parent 'null'
  double progress; // 하위 목록의 달성여부로 % 값 산정, 하위 100% 시 자동 완료판정 // progress percentage calculated by subTasks' complete or not, automatically change isComplete into true when subTasks are all done
  String url; // 추가정보 : URL // additional information : URL


  // 생성자 // constructor
  TodoItem({
    required this.title,
    this.description = '',
    this.priority = 0,
    this.location = '',
    required this.relatedTasks,
    required this.tags,
    required this.subTasks,
    this.isCompleted = false,
    this.parent,
    this.progress = 0.0, // 자식이 없다면 UI에서 프로그레스를 비활성화하는 방법도 생각중 // considering deactivate this option in UI when subtasks == 0
    this.url = '',
  });


  // 자신의 상위 아이템 반환(root 때문에 null값이 가능함, 이거 부를때 후처리 필요) // return parent's item(return value can be null, so post processing is needed)
  TodoItem? returnUpper() {
    return this.parent;
  }

  // 자식이 있는 경우, 자신의 progress 상태 갱신 // if subtask exsists, update it's progress
  void updateProgress() {
    if (this.subTasks.length == 0) {
      if(this.isCompleted == true)
        this.progress = 1.0;
      else this.progress = 0.0;
      return;
    }
    else {
      // Todo : 자식의 완료여부를 기준으로 상태 갱신 // update progress based on subtasks' completion
    }
  }

  // 자신의 하위 아이템 생성(생성 시 ) // create child item
  void createItem(
      String title, int priority, String location,
      List<TodoItem> relatedTasks, List<String> tags,
      List<TodoItem> subTasks,
      ) {
    TodoItem newItem = TodoItem(
        title:title, priority: priority, location: location,
        relatedTasks: relatedTasks, tags: tags,
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
  void editItem(String title, int priority, String location,
      List<TodoItem> relatedTasks, List<String> tags,
      ) {
    this.title = title;
    this.priority = priority;
    this.location = location;
    this.relatedTasks = relatedTasks;
    this.tags = tags;
    this.subTasks = subTasks;
  }
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
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        return _buildItem(widget.items, widget.items[index]); // 0층 빌드
      },
    );
  }

  // 재귀적으로 TodoItem을 빌드하여 계층구조 구현 // implement data structure by building TodoItem recursively
  Widget _buildItem(List<TodoItem> items, TodoItem item, [int depth = 0]) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.only(left:16.0 + depth * 16.0), // 하위작업 들여쓰기용 패딩 // inset padding for subtasks
          title: Row( // 필요한 속성이 있는 경우 제목 옆에 간략하게 표시
            children: [
              Text(item.title),
              SizedBox(width:8.0),
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
          onTap: () { // 클릭 시 속성 확인 및 수정 가능 페이지로 이동하는 것을 구상중 // thinking of onClick : check attr & editing page
            showDialog(
              context: context,
              barrierDismissible: true,
              builder: (BuildContext context){
                return AlertDialog(
                  title: Text(item.title + "Attributes"),
                  content: Column(
                    children: [
                      Text("Show here editable attrs, Description, Hyperlinks, File + preview"),
                      // 여기에 각종 속성 보기 및 수정작업 // attrs and editing features here
                      Text("Description : " + item.description), // 수정 가능한 블럭으로 바꿔야 함, 이것 말고 나머지들도 // needed to be change into editable block, others also
                      Text("Priority : " + item.priority.toString()),
                      Text("Tags : " + item.tags.toString()),
                      Text("Location : " + item.location.toString()),
                      Text("Related Tasks : " + item.relatedTasks.toString()), // 직접 클릭하는걸로 변경해야 보일듯 // it would visable if create option changes into clickable object
                      Text("Progress : " + (item.progress * 100).toString() + "%"),
                      SizedBox(height: 10, ),
                      Container(height: 10,color: Colors.black26,),
                      Text("Additional Informations",style: TextStyle(fontSize: 20,)),


                    ],
                  ),
                  actions: <Widget>[
                    Container( // 새 하위작업 생성 // create new subtask
                      child: ElevatedButton(
                        onPressed: () {
                          //Navigator.of(context).pop(); //창 닫기 // close Dialog with apply changes
                          // TextEditingController 추가로 Task 요소 관리하며 새 작업 생성 // managing TextField content : using controllers
                          final TaskNameController = TextEditingController();
                          final TaskPriorController = TextEditingController();
                          final TaskLocController = TextEditingController();
                          final TaskRelateController = TextEditingController();
                          final TaskTagController = TextEditingController();
                          // 이들 중 일부는 상황에 따라 쓰이지 않거나 바뀔 수도 있음 // some of these could be not used or changed
                          // myController.text 형식으로 접근 // access fields by like myController.text

                          showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (BuildContext context){
                              return AlertDialog(
                                title: Icon(Icons.add),
                                content: Container( // 너비지정용 // setting width by this
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
                                          )
                                      ),
                                      SizedBox(height: 10,),
                                      TextField(
                                          controller: TaskPriorController,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: 'Priority(need to be change into number input)',
                                          )
                                      ),
                                      SizedBox(height: 10,),
                                      TextField(
                                          controller: TaskLocController,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: 'location(optional)',
                                          )
                                      ),
                                      SizedBox(height: 10,),
                                      TextField(
                                          controller: TaskRelateController,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: 'related Tasks(optional)(need to be change into task select box)',
                                          )
                                      ),
                                      SizedBox(height: 10,),
                                      TextField(
                                          controller: TaskTagController,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            labelText: 'tags(optional)(no need to be change but need to parsing to use)',
                                          )
                                      ),
                                      // 하위작업은 루트작업 생성 후 진행 // subTask is not added at creating root Task
                                      SizedBox(height: 10,),
                                    ],
                                  ),
                                ),
                                actions: <Widget>[
                                  Container(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(); //창 닫기 // close Dialog with Create tasks
                                        // 작업 생성 시도
                                        setState(() {
                                          item.subTasks.add(TodoItem(title: TaskNameController.text, relatedTasks: [], // 임시 : 연관작업에 컨트롤러 연동시키기 // temp : allocate related job into controller
                                              tags: TaskTagController.text.split(","), subTasks: [], location: TaskLocController.text));
                                        });


                                      },
                                      child: Text("Create"),
                                    ),
                                  ),
                                  Container(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(); //창 닫기 // close Dialog with cancel
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
                          Navigator.of(context).pop(); //창 닫기 // close Dialog with apply changes
                        },
                        child: Text("Apply"),
                      ),
                    ),
                    Container(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); //창 닫기 // close Dialog with discard changes
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
                          showDialog(context: context, builder: (BuildContext context){
                            return AlertDialog(
                              content: Text("Do you really want to delete this task?\n All subtasks will also be deleted."),
                              actions: <Widget>[
                                Container(
                                  child: ElevatedButton(
                                    onPressed: (){
                                      // 삭제작업 진행
                                      setState(() {
                                        items.remove(item);
                                      });
                                      Navigator.of(parentDialogContext).pop();
                                      Navigator.of(context).pop();
                                    },
                                    child: Text("Yes"),
                                  ),
                                ),
                                Container(
                                  child: ElevatedButton(
                                    onPressed: (){
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
                  ],
                );
              },
            );
          },
        ),
        // 하위 작업을 여기서 빌드 // build subtasks here
        for (var subItem in item.subTasks) _buildItem(item.subTasks, subItem, depth + 1)
      ],
    );
  }
}



// 작업 생성, 드래그&드롭 및 표시 등 관리해주는 클래스 // Create, Drag&Drop, etc. managing Class
class ItemManager {
  // 자료구조 변수, 초기화는 나중에 생성하면서 진행 // Var : TodoItem, init later
  late TodoItem ItemTree;



}