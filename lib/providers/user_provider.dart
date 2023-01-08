import 'package:flutter/cupertino.dart';
import 'package:instagram_clone/models/user_model.dart' as UserModel;
import 'package:instagram_clone/resources/auth_methods.dart';

class UserProvider with ChangeNotifier {
  //UserProvider class is a provider inherited from ChangeNotifier class that is used to provide user-data
  //what is ChangeNotifier? --> to set as a provider in main.dart inside 'ChangeNotifierProvider'
  UserModel.User?
      _user; //setting a global variable for containing user-data in form of UserModel.User model
  final AuthMethods _auth = AuthMethods();

  UserModel.User? get getUser =>
      _user; //a getter fn to obtain current user-data by other widgets in the widget-tree

  Future<void> refreshUser() async {
    UserModel.User user = await _auth.getUserDetails();
    _user = user;
    notifyListeners(); //what notifyListeners() does???
  }
}
