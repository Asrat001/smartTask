import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:task_manager/blocs/auth_bloc/auth_bloc.dart';
import 'package:task_manager/blocs/drifted_bloc/drifted_bloc.dart';
import 'package:task_manager/blocs/notifications_cubit/notifications_cubit.dart';
import 'package:task_manager/models/sync_item_error.dart';
import 'package:task_manager/models/sync_status.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/services/firebase_service.dart';

import '../../models/auth_credentials.dart';
import '../../services/locator_service.dart';

part 'task_event.dart';
part 'task_state.dart';

part 'task_bloc.g.dart';

class TaskBloc extends DriftedBloc<TaskEvent, TaskState> {

  final bool inBackground;
  final AuthBloc authBloc;
  final NotificationsCubit notificationsCubit;
  
  StreamSubscription<void>? taskNotificationsConfigChangeSubscription;
  StreamSubscription<List<Task>>? _taskSubscription;

  TaskBloc({
    required this.inBackground,
    required this.authBloc,
    required this.notificationsCubit
  }) : super(TaskState.initial){

    taskNotificationsConfigChangeSubscription = notificationsCubit.settingsCubit
      .taskNotificationsConfigChange.listen((_) => add(ScheduleTaskNotificationsRequested()));
    final currentUserId = authBloc.state.user?.email;


    on<TaskLoaded>((event, emit)async {
   _taskSubscription?.cancel();
      if(currentUserId !=null){
        await emit.forEach<List<Task>>(
          locator<FirebaseService>().getUserTasksStream(currentUserId),
          onData: (tasks) => state.copyWith(
            tasks: tasks,
            isLoading: false,
            syncStatus: SyncStatus.idle,
            userId: currentUserId,
          ),
          onError: (error, stackTrace) => state.copyWith(isLoading: false),
        );

      }else{
        authBloc.add(AuthCredentialsChanged(AuthCredentials.empty));
      }
      // final currentUserId = authBloc.state.user?.id;
      // if(state.userId != currentUserId){
      //   emit(TaskState.initial.copyWith(
      //     isLoading: false,
      //     userId: currentUserId,
      //     syncStatus: SyncStatus.idle
      //   ));
      // }
      //
      // }
    });
    add(TaskLoaded());

    on<TaskAdded>((event, emit) async{
     try{
       await locator<FirebaseService>().createTask(event.task);
       // final updatedTasks=List<Task>
     }catch(e){

     }
    });

    on<TaskUpdated>((event, emit) async{
      await locator<FirebaseService>().updateTask(event.task.id,event.task.toJson());
      // emit(taskState.copyWith(tasks: taskState.tasks.map((task){
      //   return task.id == event.task.id ? event.task : task;
      // }).toList()));
    });

    on<TaskDeleted>((event, emit) async{
      await locator<FirebaseService>().deleteTask(event.task.id);

    });

    on<TaskUndoDeleted>((event, emit){
      final taskState = state;
      emit(taskState.copyWith(
        tasks: taskState.tasks..add(event.task.copyWith(deletedAt: null)),
        deletedTasks: taskState.deletedTasks..removeWhere((t) => t.id == event.task.id)
      ));
    });
    
    on<TasksUpdated>((event, emit){
      emit(state.copyWith(tasks: event.tasks));
    });

    on<TaskStateUpdated>((event, emit){
      debugPrint("");
      emit(event.state.copyWith(
        isLoading: false,
        syncStatus: event.state.syncStatus
      ));
    },
    transformer: restartable());

    on<ScheduleTaskNotificationsRequested>((event, emit){
      notificationsCubit.scheduleTasksNotificatons(state.tasks);
    });
  }

  @override
  void onChange(change) async {
    super.onChange(change);
    add(ScheduleTaskNotificationsRequested());
  }

  @override
  Future<void> close() async {
    await taskNotificationsConfigChangeSubscription?.cancel();
    await _taskSubscription?.cancel();
    return super.close();
  }

  @override
  TaskState? fromJson(Map<String, dynamic> json) {
    try{
      debugPrint("TaskBloc fromJson");
      return TaskState.fromJson(json);
    }
    catch(error) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(TaskState state) {
    try{
      debugPrint("TaskBloc toJson");
      return state.toJson();
    }
    catch(error) {
      return null;
    }
  }
}