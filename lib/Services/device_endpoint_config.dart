import 'package:shared_preferences/shared_preferences.dart';


Future<bool> saveEndPoint(String value) async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("endpoint", value);
  print('Endpoint: $value');
  return prefs.setString("endpoint", value);
}

Future<String?> getEndPoint() async{
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? endpoint = prefs.getString("endpoint");
  return endpoint;
}


