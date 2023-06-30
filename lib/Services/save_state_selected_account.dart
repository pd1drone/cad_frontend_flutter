import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> saveUsername(String value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("Username", value);
  print('Username Value saved $value');
  return prefs.setString("Username", value);
}

Future<String?> getUsername() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? username = prefs.getString("Username");
  print(username);

  return username;
}

Future<bool> saveAccountID(int value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt("AccountID", value);
  print('AccountID Value saved $value');
  return prefs.setInt("AccountID", value);
}

Future<int?> getAccountID() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? accountID = prefs.getInt("AccountID");
  print(accountID);

  return accountID;
}


Future<bool> saveCreatedAccountID(int value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt("CreatedAccountID", value);
  print('CreatedAccountID Value saved $value');
  return prefs.setInt("CreatedAccountID", value);
}

Future<int?> getCreatedAccountID() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? accountID = prefs.getInt("CreatedAccountID");
  print(accountID);

  return accountID;
}



Future<bool> saveCreatedUsername(String value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("CreatedUsername", value);
  print('CreatedUsername Value saved $value');
  return prefs.setString("CreatedUsername", value);
}

Future<String?> getCreatedUsername() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? username = prefs.getString("CreatedUsername");
  print(username);

  return username;
}



Future<bool> saveBMI(double value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setDouble("BMI", value);
  print('BMI Value saved $value');
  return prefs.setDouble("BMI", value);
}

Future<double?> getBMI() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  double? bmi = prefs.getDouble("BMI");
  print(bmi);

  return bmi;
}
