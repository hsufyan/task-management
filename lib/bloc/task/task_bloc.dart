import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:taskify/bloc/task/task_event.dart';
import 'package:taskify/bloc/task/task_state.dart';

import '../../data/model/task/task_model.dart';
import '../../data/repositories/task/task_repo.dart';
import '../../api_helper/api.dart';
import '../../utils/widgets/toast_widget.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  int _offset = 0; // Start with the initial offset
  final int _limit = 10;
  bool _hasReachedMax = false;
  bool _isLoading = false;
  TaskBloc() : super(TaskInitial()) {
    on<TaskCreated>(_createTask);
    on<AllTaskList>(_allTask);
    on<AllTaskListOnTask>(_allTaskListOnProject);
    on<TodaysTaskList>(_todaysTask);
    on<UpdateTask>(_updateTask);
    on<SearchTasks>(_onSearchTask);
    on<DeleteTask>(_deleteTasks);
    on<LoadMore>(_onLoadMoreTask);
    on<LoadMoreToday>(_onLoadMoreTodaysTask);
    on<TaskDashBoardFavList>(_getTaskFavLists);
  }
  Future<void> _createTask(TaskCreated event, Emitter<TaskState> emit) async {
    try {
      emit(TaskCreateSuccessLoading());

      Map<String, dynamic> result = await TaskRepo().createTask(
          title: event.title,
          statusId: event.statusId,
        //  priorityId: event.priorityId,
          startDate: event.startDate,
          dueDate: event.dueDate,
          desc: event.desc,
         // project: event.project,
          note: event.note,
          userId: event.userId);

      if (result['error'] == false) {
        emit(TaskCreateSuccess());
        add(AllTaskList());
      }
      if (result['error'] == true) {
        emit(TaskCreateError(result['message']));
        add(AllTaskList());

        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((TaskError("Error: $e")));
    }
  }

  Future<void> _getTaskFavLists(
      TaskDashBoardFavList event, Emitter<TaskState> emit) async {
    try {
      _offset = 0; // Reset offset for the initial load
      _hasReachedMax = false;
      emit(TaskLoading());
      List<Tasks> fav = [];
      Map<String, dynamic> result = await TaskRepo().getTasksFav(
        isFav: event.isFav,
        limit: _limit,
        offset: _offset,
        search: '',
      );
      fav = List<Tasks>.from(
          result['data'].map((projectData) => Tasks.fromJson(projectData)));
      _offset += _limit;
      _hasReachedMax = fav.length >= result['total'];

      if (result['error'] == false) {
        emit(TaskFavPaginated(
          task: fav,
          hasReachedMax: _hasReachedMax,
        ));
      }
      if (result['error'] == true) {
        emit((TaskError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((TaskError("Error: $e")));
    }
  }

  Future<void> _allTaskListOnProject(
      AllTaskListOnTask event, Emitter<TaskState> emit) async {
    try {
      List<Tasks> task = [];
      _offset = 0; // Reset offset for the initial load
      _hasReachedMax = false;
      Map<String, dynamic> result = {};
      emit(TaskLoading());
      print("njfvkml,c ${event.id}");
      _offset = 0;
      result = await TaskRepo().getTask(
          subtask: event.isSubtask,
          limit: _limit,
          offset: _offset,
          search: '',
          token: true,
          id: event.id,
          userId: event.userId,
          clientId: event.clientId,
          projectId: event.projectId,
          statusId: event.statusId,
          priorityId: event.priorityId,
          fromDate: event.fromDate,
          toDate: event.toDate);
      task = List<Tasks>.from(
          result['data'].map((projectData) => Tasks.fromJson(projectData)));

      _offset += _limit;
      _hasReachedMax = task.length < _limit;

      if (result['error'] == false) {
        emit(TaskPaginated(task: task, hasReachedMax: _hasReachedMax));
      }
      if (result['error'] == true) {
        emit((TaskError(result['message'])));
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((TaskError("Error: $e")));
    }
  }

  Future<void> _onSearchTask(SearchTasks event, Emitter<TaskState> emit) async {
    try {
      List<Tasks> task = [];
      emit(TaskLoading());
      _offset = 0;
      _hasReachedMax = false;

      Map<String, dynamic> result = await TaskRepo().getTask(
          limit: _limit,
          offset: _offset,
          search: event.searchQuery,
          token: true);
      task = List<Tasks>.from(
          result['data'].map((projectData) => Tasks.fromJson(projectData)));
      bool hasReachedMax = task.length < _limit;
      if (result['error'] == false) {
        emit(TaskPaginated(task: task, hasReachedMax: hasReachedMax));
      }
      if (result['error'] == true) {
        emit((TaskError(result['message'])));
      }
    } on ApiException catch (e) {
      emit(TaskError("Error: $e"));
    }
  }

  Future<void> _allTask(AllTaskList event, Emitter<TaskState> emit) async {
    try {
      List<Tasks> task = [];
      _offset = 0; // Reset offset for the initial load
      _hasReachedMax = false;
      emit(TaskLoading());
      Map<String, dynamic> result = await TaskRepo()
          .getTask(limit: _limit, offset: _offset, search: '', token: true);
      task = List<Tasks>.from(
          result['data'].map((projectData) => Tasks.fromJson(projectData)));

      _offset += _limit;
      _hasReachedMax = task.length < _limit;
      if (result['error'] == false) {
        emit(TaskPaginated(task: task, hasReachedMax: _hasReachedMax));
      }
      if (result['error'] == true) {
        emit((TaskError(result['message'])));
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((TaskError("Error: $e")));
    }
  }

  Future<void> _todaysTask(
      TodaysTaskList event, Emitter<TaskState> emit) async {
    try {
      List<Tasks> task = [];
      _offset = 0; // Reset offset for the initial load
      _hasReachedMax = false;
      emit(TodaysTaskLoading());
      Map<String, dynamic> result = await TaskRepo().getTask(
          limit: _limit,
          offset: _offset,
          search: '',
          token: true,
          fromDate: event.fromDate,
          toDate: event.fromDate);
      task = List<Tasks>.from(
          result['data'].map((projectData) => Tasks.fromJson(projectData)));
      _offset += _limit;

      _hasReachedMax = result['total'] < _limit;
      if (result['error'] == false) {
        emit(TaskPaginated(task: task, hasReachedMax: _hasReachedMax));
      }
      if (result['error'] == true) {
        emit((TaskError(result['message'])));
      }
    } on ApiException catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit((TaskError("Error: $e")));
    }
  }

  void _deleteTasks(DeleteTask event, Emitter<TaskState> emit) async {
    final int note = event.taskId;
    try {
      Map<String, dynamic> result = await TaskRepo().getDeleteTask(
        id: note.toString(),
        token: true,
      );
      if (result['error'] == false) {
        emit(TaskDeleteSuccess());
      }
      if (result['error'] == true) {
        emit((TaskDeleteError(result['message'])));
        flutterToastCustom(msg: result['message']);
      }
    } catch (e) {
      emit(TaskError(e.toString()));
    }
  }

 void _updateTask(UpdateTask event, Emitter<TaskState> emit) async {
  if (state is TaskPaginated) {
    final id = event.id;
    final title = event.title;
    final statusId = event.statusId;
    // final priorityId = event.priorityId ?? 0; // Default to 0 if null
    final startDate = event.startDate;
    final dueDate = event.dueDate;
    final desc = event.desc;
    final note = event.note;
    final userId = event.userId;
    emit(TaskEditSuccessLoading());
    try {
      // Log request payload for debugging
      if (kDebugMode) {
        print('UpdateTask Payload: {id: $id, title: $title, statusId: $statusId, startDate: $startDate, dueDate: $dueDate, desc: $desc, note: $note, userId: $userId}');
      }
      Map<String, dynamic> result = await TaskRepo().updateTask(
        id: id,
        title: title,
        statusId: statusId,
        // priorityId: priorityId,
        startDate: startDate,
        dueDate: dueDate,
        desc: desc,
        note: note,
        userId: userId,
      );
      if (result['error'] == false) {
        emit(TaskEditSuccess());
        add(AllTaskList());
      } else {
        emit(TaskEditError(result['message']));
       // flutterToastCustom(msg: result['message']);
        add(AllTaskList());
      }
    } catch (e) {
      if (kDebugMode) {
        print('UpdateTask Error: $e');
      }
      emit(TaskEditError('Failed to update task: $e'));
      //flutterToastCustom(msg: 'Failed to update task: $e');
      add(AllTaskList());
    }
  }
}

  Future<void> _onLoadMoreTask(LoadMore event, Emitter<TaskState> emit) async {
    if (state is TaskPaginated && !_hasReachedMax && !_isLoading) {
      _isLoading = true; // Start loading
      try {
        final currentState = state as TaskPaginated;
        final updatedNotes = List<Tasks>.from(currentState.task);

        // Fetch additional tasks
        Map<String, dynamic> result = await TaskRepo().getTask(
            limit: _limit,
            offset: _offset,
            search: event.searchQuery,
            token: true,
            userId: event.userId,
            clientId: event.clientId,
          //  projectId: event.projectId,
            statusId: event.statusId,
          //  priorityId: event.priorityId,
            fromDate: event.fromDate,
            toDate: event.toDate,
            isFav: event.isFav);

        if (result['error'] == false) {
          final additionalNotes = List<Tasks>.from(
            result['data'].map((projectData) => Tasks.fromJson(projectData)),
          );

          // Increment the offset only if new items are fetched
          if (additionalNotes.isNotEmpty) {
            _offset += additionalNotes.length; // Update offset
          }
          if (updatedNotes.length >= result['total']) {
            _hasReachedMax = true;
          } else {
            _hasReachedMax = false;
          }

          updatedNotes.addAll(additionalNotes);
        } else if (result['error'] == true) {
          emit(TaskError(result['message']));
          flutterToastCustom(msg: result['message']);
        }

        emit(TaskPaginated(task: updatedNotes, hasReachedMax: _hasReachedMax));
      } on ApiException catch (e) {
        emit(TaskError("Error: $e"));
      } finally {
        _isLoading = false; // End loading
      }
    }
  }

  Future<void> _onLoadMoreTodaysTask(
      LoadMoreToday event, Emitter<TaskState> emit) async {
    if (state is TaskPaginated && !_hasReachedMax && !_isLoading) {
      _isLoading = true;
      try {
        final currentState = state as TaskPaginated;
        final updatedTask = List<Tasks>.from(currentState.task);

        // Fetch additional tasks from the repository
        Map<String, dynamic> result = await TaskRepo().getTask(
          limit: _limit,
          offset: _offset, // Use the current offset
          search: '',
          token: true,
          fromDate: event.fromDate,
          toDate: event.toDate,
        );

        final additionalTask = List<Tasks>.from(
          result['data'].map((taskData) => Tasks.fromJson(taskData)),
        );

        // Update the offset only if the fetch is successful
        if (additionalTask.isNotEmpty) {
          _offset += additionalTask.length; // Increment by fetched items
        }

        // Check if the maximum number of items has been reached
        _hasReachedMax = additionalTask.length < _limit;

        updatedTask.addAll(additionalTask);

        if (result['error'] == false) {
          emit(TaskPaginated(task: updatedTask, hasReachedMax: _hasReachedMax));
        } else {
          emit(TaskError(result['message']));
        }
      } on ApiException catch (e) {
        emit(TaskError("Error: $e"));
      } finally {
        _isLoading = false; // End loading
      }
    }
  }
}
