import 'package:shared_preferences/shared_preferences.dart';

Future<bool> saveTimerState(bool value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool("timerstate", value);
  print('timerstate Value saved $value');
  return prefs.setBool("timerstate", value);
}

Future<bool?> getTimerState() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? pinState = prefs.getBool("timerstate");
  print(pinState);

  return pinState;
}

