import 'dart:io';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:timer_builder/timer_builder.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'requirement_1.dart';







// 실험 : 체크박스 상태변경 확인용 (현재 우선순위뷰)
class ViewWidget_temp extends StatefulWidget {
  final TodoItem item;
  final List<TodoItem> items;
  final List<TodoItem> items_arr;

  ValueNotifier<List<TodoItem>> itemsNotifier;

  ViewWidget_temp({
    Key? key,
    required this.item,
    required this.items,
    required this.items_arr,
    required this.itemsNotifier,
  }) : super(key: key);

  @override
  _ViewWidget_temp_State createState() => _ViewWidget_temp_State();
}

class _ViewWidget_temp_State extends State<ViewWidget_temp> {


  // 상태변경 콜백 메소드 : 작업생성 // setState callback : create task
  void createTask(TodoItem item,
      TextEditingController TaskNameController,
      TextEditingController TaskTagController,
      TextEditingController TaskLocController,
      TextEditingController TaskPriorController,
      List<TodoItem> temp
      ) {

    print("우선순위 : ${TaskPriorController.text}");

    TodoItem newSubTask = TodoItem(
        title: TaskNameController.text,
        tags: TaskTagController.text
            .split(","),
        subTasks: [],
        superTask: item,
        location:
        TaskLocController.text,
        priority: TaskPriorController.text.isEmpty ? 0 : int.parse(TaskPriorController.text));

    setState(() {
      item.subTasks.add(newSubTask);
      item.updateProgress();
    });
    // 우선순위 뷰에도 추가하고 재정렬?
    List<TodoItem> updatedList = List.from(widget.itemsNotifier.value);
    updatedList.add(newSubTask); // 새 subTask 추가
    updatedList.sort((a, b) => a.priority.compareTo(b.priority));

    Fluttertoast.showToast(msg: "Created Task!");
    // 현재 뷰에도 적용시키기!
    widget.itemsNotifier.value = updatedList; // ValueNotifier는 새 객체의 할당여부를 갖고 갱신을 시도함!
  }

  // 상태변경 콜백 메소드 : 작업삭제 // setState callback : remove task
  void removeTask(List<TodoItem> items, TodoItem item, List<TodoItem> items_arr) {
    setState(() {
      // 원본 리스트에서 삭제 : 직접 순회하면서 진행
      //items.remove(item) == true ? print("제거성공") : print("제거실패");

      print("제거대상 ID : ${item.ID}");
      findAndRemoveTask(items, item.ID);


      items_arr.remove(item) == true ? print("제거성공") : print("제거실패"); // 다른 뷰에선 전용 array에서도 아이템을 빼야 함
      item.updateProgress();
    });
    setState(() {
      widget.itemsNotifier.value = widget.itemsNotifier.value.where((i) => i != item).toList();
    });
  }

  // 재귀적으로 ID에 해당하는 작업 찾고 삭제
  bool findAndRemoveTask(List<TodoItem> items, int target_id) {
    bool check = false;
    for (TodoItem suspect in items) {
      if (check) return true;
      print("suspect ID : ${suspect.ID}, title : ${suspect.title}");
      if (suspect.ID == target_id) {
        // 찾았으니 제거
        if(items.remove(suspect)) {
          print("원본에서 제거성공!");
          return true;
        } else {
          print("FATAL ERROR : 원본에서 제거실패");
          return false;
        }
      } else if (suspect.subTasks.isNotEmpty) {
        findAndRemoveTask(suspect.subTasks, target_id);
      }
    }

    print("FATAL ERROR : 일치하는 ID가 없음!!");
    return false;
  }

  // 상태변경 콜백 메소드 : 파일명 갱신 // setState callback : refresh filename
  void updateFileName(TodoItem item) {
    setState(() {
      print("파일명 변경완료");
    });
  }




  @override
  Widget build(BuildContext context) {

    return ListTile(
      title: Text(widget.item.title),
      subtitle: Text("priority: ${widget.item.priority}"),
      trailing: Checkbox(
        value: widget.item.isCompleted,
        onChanged: (bool? value) {
          setState(() {
            widget.item.isCompleted = value!;
            widget.item.updateProgress();
          });
        },
      ),
      onTap: (){
        // 여기서도 클릭시 정보페이지 볼 수 있게 할 수 있을까?
        informWindow(context, widget.item, widget.items, widget.items_arr, createTask,removeTask, updateFileName); // 이거부터 수정해야 함 : 콜백으로 변경
      },
    );
  }
}








// 트리구조로 이뤄진 할 일 목록을 배열로 변환하는 함수
List<TodoItem> collectTasks(List<TodoItem> items) {
  List<TodoItem> list = [];

  for(TodoItem item in items) {
    collectTasks_inner(item, list);
  }

  return list;
}

// 리스트 배열은 사실상 계층구조가 없음에 유의!!
void collectTasks_inner(TodoItem root, List<TodoItem> list) {
  list.add(root); // 현재 노드 추가
  for (TodoItem subTask in root.subTasks) {
    collectTasks_inner(subTask, list); // 하위 노드 순회
  }
}

Widget buildView_Calendar (List<TodoItem> items) {
  return Column(
    children: [
      Text("임시 : 캘린더뷰 들어가야 함"),
    ],
  );
}

Widget buildView_Priority (List<TodoItem> items) {
  List<TodoItem> items_arr = collectTasks(items); // items 내부 요소를 우선순위 기준으로 재정렬 : 트리구조에서 배열로..

  items_arr.sort((a, b) => a.priority.compareTo(b.priority)); // 내부 할 일 인스턴스의 우선순위 기준 정렬

  ValueNotifier<List<TodoItem>> itemsNotifier = ValueNotifier<List<TodoItem>>(items_arr);


  return ValueListenableBuilder(
    valueListenable: itemsNotifier,
    builder: (context, _, child) {
      return ListView.builder(
        itemCount: itemsNotifier.value.length,
        itemBuilder: (context, index){
          // 임시 : _TodoListState 인스턴스 생성해서 그 내부 함수 쓸 수 있는지 확인

          return ViewWidget_temp(
            item: itemsNotifier.value[index],
            items: items,
            items_arr: itemsNotifier.value,
            itemsNotifier: itemsNotifier,
          );
        });
    }
  );
}

Widget buildView_DueDate (List<TodoItem> items) {
  List<TodoItem> items_arr = collectTasks(items); // items 내부 요소를 우선순위 기준으로 재정렬 : 트리구조에서 배열로..

  // 내부 할 일 인스턴스의 마감일 기준 정렬
  items_arr.sort((a, b) {
    // 마감일이 없는 경우는 무조건 후순위로 두기!
    DateTime time_a, time_b;
    time_a = (a.deadline ?? DateTime.parse("9999-12-30"))!;
    time_b = (b.deadline ?? DateTime.parse("9999-12-30"))!;
    return time_a.compareTo(time_b);
  });

  return Column(
    children: [
      Text("임시 : 마감일뷰 들어가야 함"),
      
    ],
  );
}