import 'package:flutter/material.dart';
import 'package:task_manager_without_getx/data/models/task_model.dart';
import 'package:task_manager_without_getx/data/service/network_caller.dart';
import 'package:task_manager_without_getx/data/urls.dart';
import 'package:task_manager_without_getx/ui/widgets/centered_circular_progress_indicator.dart';
import 'package:task_manager_without_getx/ui/widgets/snack_bar_message.dart';
import 'package:task_manager_without_getx/ui/widgets/task_card.dart';

class CompletedTaskListScreen extends StatefulWidget {
  const CompletedTaskListScreen({super.key});

  @override
  State<CompletedTaskListScreen> createState() => _CompletedTaskListScreenState();
}

class _CompletedTaskListScreenState extends State<CompletedTaskListScreen> {

  bool _getCompletedTasksInProgress = false;
  List<TaskModel> _completedTaskList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCompletedTaskList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Visibility(
        visible: _getCompletedTasksInProgress == false,
        replacement: CenteredCircularProgressIndicator(),
        child: ListView.builder(
          itemCount: _completedTaskList.length,
          itemBuilder: (context, index) {
            return TaskCard(
              taskType: TaskType.completed,
              taskModel: _completedTaskList[index],
              onStatusUpdate: () {
                _getCompletedTaskList();
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _getCompletedTaskList() async {
    _getCompletedTasksInProgress = true;
    setState(() {});

    NetworkResponse response = await NetworkCaller
        .getRequest(url: Urls.getCompletedTasksUrl);

    if (response.isSuccess) {
      List<TaskModel> list = [];
      for (Map<String, dynamic> jsonData in response.body!['data']) {
        list.add(TaskModel.fromJson(jsonData));
      }
      _completedTaskList = list;
    } else {
      showSnackBarMessage(context, response.errorMessage!);
    }

    _getCompletedTasksInProgress = false;
    setState(() {});
  }
}
