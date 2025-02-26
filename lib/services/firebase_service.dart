import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rxdart/rxdart.dart';

import '../models/category.dart';
import '../models/task.dart';





// Custom exception class
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => "AuthException: $message";
}





class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // 🔹 Get Current User
  User? get currentUser => _auth.currentUser;
 FirebaseService(){
   _firestore.settings=const Settings(persistenceEnabled: true);
 }
  // 🔹 Sign Up with Email & Password
  Future<User?> signUpWithEmail(String email, String password,String userName) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = credential.user;
       if(user!=null){
         // Save user data to Firestore
         bool exists=await doesUserExist(user.uid);
         if(!exists){
           await _firestore.collection('smartTaskUsers').doc(credential.user!.uid).set({
             'id': credential.user!.uid,
             'email': email,
             'name': userName,
             'createdAt': FieldValue.serverTimestamp(),
             "imageUrl":"",
             "verified":false,
             "updatedAt": FieldValue.serverTimestamp(),
           });
         }

       }


      return credential.user;
    } on FirebaseAuthException catch(e){
       throw AuthException(e.toString());
    }on FirebaseException catch(e){
      throw AuthException("Firestore Error: ${e.message}");
    }
    catch (e) {
      throw AuthException("Unknown Error: $e");
      return null;
    }
  }

  // 🔹 Sign In with Email & Password
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      print("Error in signInWithEmail: $e");
      return null;
    }
  }

  // 🔹 Google Sign-In
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;
      debugPrint("Google SignIn");
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential userCredential =
      await _auth.signInWithCredential(credential);
      debugPrint("credential: ${credential.token}  ${credential.providerId}");
      User? user = userCredential.user;
      if(user !=null){
        bool exists=await doesUserExist(user.uid);
        // Save user data to Firestore
        if(!exists){
          await _firestore.collection('smartTaskUsers').doc(userCredential.user!.uid).set({
            'id': userCredential.user!.uid,
            'email': userCredential.user!.email,
            'name': userCredential.user!.displayName,
            'imageUrl': userCredential.user!.photoURL,
            'createdAt': FieldValue.serverTimestamp(),
            "verified":true,
            "updatedAt": FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }

      }
      debugPrint("done: ${userCredential.user?.displayName}");
      return userCredential.user;
    }
    on FirebaseAuthException catch(e){throw AuthException(e.toString());}on FirebaseException catch(e){
      debugPrint("Error: ${e.message}  ${e.code}");
     throw AuthException("Firestore Error: ${e.message}");
   }
  catch (e) {
    debugPrint("Error: ${e.toString()}  ");
  throw AuthException("Unknown Error: $e");

  }
  }

  // 🔹 Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  // 🔹 Create or Update Firestore Document
  Future<void> saveData(String collection, String docId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collection).doc(docId).set(data, SetOptions(merge: true));
    } catch (e) {
      print("Error in saveData: $e");
    }
  }

  /// Create a new task
  Future<void> createTask(Task task) async {
    try {
      await _firestore.collection('tasks').doc(task.id).set(task.toJson());
    } catch (e) {
      print("Error creating task: $e");
    }
  }

  /// Update a task
  Future<void> updateTask(String taskId, Map<String, dynamic> updatedData) async {
    try {
      await _firestore.collection('tasks').doc(taskId).update(updatedData);
    } catch (e) {
      print("Error updating task: $e");
    }
  }
  /// Delete a task
  Future<void> deleteTask(String taskId) async {
    try {
      await _firestore.collection('tasks').doc(taskId).delete();
    } catch (e) {
      print("Error deleting task: $e");
    }
  }

  Stream<List<Task>> getUserTasksStream(String userId) {
    try {
      // Stream for tasks assigned to the user
      final assignedTasksStream = _firestore
          .collection('tasks')
          .where('assignedTo', isEqualTo: userId)
          .snapshots();

      // Stream for tasks created by the user
      final createdTasksStream = _firestore
          .collection('tasks')
          .where('createdBy', isEqualTo: userId)
          .snapshots();
      // Merge both streams into one
      return Rx.combineLatest2<QuerySnapshot<Map<String, dynamic>>,
          QuerySnapshot<Map<String, dynamic>>, List<Task>>(
        assignedTasksStream,
        createdTasksStream,
            (assignedSnapshot, createdSnapshot) {
          final assignedTasks = assignedSnapshot.docs
              .map((doc) => Task.fromJson(doc.data()))
              .toList();

          final createdTasks = createdSnapshot.docs
              .map((doc) => Task.fromJson(doc.data()))
              .toList();
          // Combine both lists and remove duplicates
          return {...assignedTasks, ...createdTasks}.toList();
        },
      );
    } catch (e) {
      print("Error fetching user tasks: $e");
      return Stream.value([]); // Return an empty stream in case of error
    }
  }
  // 🔹 Read Firestore Document
  Future<DocumentSnapshot?> getData(String collection, String docId) async {
    try {
      return await _firestore.collection(collection).doc(docId).get();
    } catch (e) {
      print("Error in getData: $e");
      return null;
    }
  }


  /// 🔥 Get real-time stream of categories for a user
  Stream<List<Category>> streamUserCategories(String userId) {
    return _firestore.collection('categories')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Category.fromJson(doc.data())).toList());
  }

  /// ✅ Create a new category
  Future<void> createCategory(Category category) async {
    await _firestore.collection('categories').add(category.toJson());
  }

  /// ✏️ Update an existing category
  Future<void> updateCategory(String categoryId, Map<String, dynamic> updates) async {
    await _firestore.collection('categories').doc(categoryId).update(updates);
  }

  /// ❌ Delete a category
  Future<void> deleteCategory(String categoryId) async {
    await _firestore.collection('categories').doc(categoryId).delete();
  }






















  Future<bool> doesUserExist(String uid) async {
    DocumentSnapshot userDoc =
    await FirebaseFirestore.instance.collection('smartTaskUsers').doc(uid).get();

    return userDoc.exists; //  Returns true if the user exists
  }


}
