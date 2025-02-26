import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:task_manager/blocs/auth_bloc/auth_bloc.dart';
import 'package:task_manager/blocs/drifted_bloc/drifted_bloc.dart';
import 'package:task_manager/blocs/task_bloc/task_bloc.dart';
import 'package:task_manager/models/category.dart';
import 'package:task_manager/models/sync_item_error.dart';
import 'package:task_manager/models/sync_status.dart';

import '../../models/auth_credentials.dart';
import '../../services/firebase_service.dart';
import '../../services/locator_service.dart';

part 'category_event.dart';
part 'category_state.dart';

part 'category_bloc.g.dart';

class CategoryBloc extends DriftedBloc<CategoryEvent, CategoryState> {
  
  final bool inBackground;
  final AuthBloc authBloc;
  final TaskBloc taskBloc;
  StreamSubscription<List<Category>>? _categorySubscription;
  CategoryBloc({
    required this.inBackground,
    required this.authBloc,
    required this.taskBloc
  }) : super(CategoryState.initial){


    on<CategoryLoaded>((event, emit) async {
      _categorySubscription?.cancel();
      final currentUserId = authBloc.state.user?.id;
      if(currentUserId !=null){
        await emit.forEach<List<Category>>(
          locator<FirebaseService>().streamUserCategories(currentUserId), // Explicitly define type
          onData: (categories) => state.copyWith(
            categories: categories, // Ensures proper type recognition
            isLoading: false,
            syncStatus: SyncStatus.idle,
            userId: currentUserId,
          ),
          onError: (error, stackTrace) => state.copyWith(isLoading: false),
        );

      }else{
        authBloc.add(AuthCredentialsChanged(AuthCredentials.empty));
      }
    });
    add(CategoryLoaded());

    on<CategoryAdded>((event, emit) async{
      final categoryState = state;
      emit(categoryState.copyWith(
        categories: categoryState.categories..add(event.category)
      ));
      await Future.delayed(const Duration(milliseconds: 40000));
      await locator<FirebaseService>().createCategory(event.category);
    });

    on<CategoryUpdated>((event, emit) async{
      final categoryState = state;
      emit(categoryState.copyWith(categories: categoryState.categories.map((category){
        return category.id == event.category.id ? event.category : category;
      }).toList()));
      await Future.delayed(const Duration(milliseconds: 40000));
      await locator<FirebaseService>().updateCategory(event.category.id!,event.category.toJson());
    });

    on<CategoryDeleted>((event, emit) async{
      final categoryState = state;
      emit(categoryState.copyWith(
        categories: categoryState.categories..removeWhere((c) => c.id == event.category.id),
        deletedCategories: categoryState.deletedCategories..add(event.category.copyWith(deletedAt: DateTime.now()))
      ));
      
      final taskBlocState = taskBloc.state;
      taskBloc.add(TaskStateUpdated(taskBlocState.copyWith(
        tasks: taskBlocState.tasks.map((task){
          return task.categoryId == event.category.id ? task.copyWith(categoryId: null) : task;
        }).toList()
      )));
      await Future.delayed(const Duration(milliseconds: 40000));
      await locator<FirebaseService>().deleteCategory(event.category.id!);
    });

    on<CategoryStateUpdated>((event, emit){
      debugPrint("");
      emit(event.state.copyWith(
        isLoading: false,
        syncStatus: event.state.syncStatus
      ));
    },
    transformer: restartable());
  }

  @override
  Future<void> close() {
    _categorySubscription?.cancel();
    return super.close();
  }


  @override
  CategoryState? fromJson(Map<String, dynamic> json) {
    try{
      debugPrint("CategoryBloc fromJson");
      return CategoryState.fromJson(json);
    }
    catch(error) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(CategoryState state) {
    try{
      debugPrint("CategoryBloc toJson");
      return state.toJson();
    }
    catch(error) {
      return null;
    }
  }
}