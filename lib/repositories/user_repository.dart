import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:task_manager/helpers/response_errors.dart';
import 'package:task_manager/models/user.dart';
import 'package:task_manager/services/firebase_service.dart';

class UserRepository {

  final FirebaseService firebaseService;
  UserRepository({required this.firebaseService});
  Future<User?> getUser() async {
    try{
      final userId=firebaseService.currentUser?.uid;
      final response = await firebaseService.getData("smartTaskUsers",userId ?? "");
      if(response ==null){
        await ResponseError.validate("No UserData", null);
      }
      return User.fromJson(response?.data() as Map<String,dynamic>);
    }
    catch (error){
      debugPrint("Log In | $error");
      await ResponseError.validate(error, null);
      return null;
    }
  }

  Future<User?> updateUser({
    String? name,
    String? imageUrl
  }) async {

    try{
      // // final dio = await base.dioAccessToken;
      // final response = await dio.patch(
      //   "/user/",
      //   data: {
      //     if(name != null) "name": name,
      //     if(imageUrl != null) "imageUrl": imageUrl
      //   }
      // );
      // return User.fromJson(response.data);
    }
    catch (error){
      await ResponseError.validate(error, null);
      return null;
    }
  }
}