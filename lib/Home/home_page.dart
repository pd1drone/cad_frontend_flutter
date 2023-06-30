import 'package:cad_app/Services/cancel_timer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import '../Services/device_endpoint_config.dart';
import '../Services/save_state_selected_account.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _classification = '';
  int _glucoseLevel = 0;
  List<String> _recommendation = [];
  List<String> _highBloodrecommendation = [];
  Timer? timer;

  bool addBloodpressure = false;

  bool diabetic = false;
  int age = 0;
  String weight = "";
  String height = "";
  String gender = "";
  double _bmi = 0.0;
  String date = "";
  int _bloodPressure =0;
  String _scenario = "";

  TextEditingController BloodPressurecontroller = TextEditingController();


  @override
  void initState(){
    super.initState();
    
    GetUserDetails();
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      // This function will be called every 5 seconds
      GetLastUserHistory();
      UpdateRecommendation();
    });
    
  }

  void cancelTimer() {
    if (timer != null) {
      timer?.cancel();
    }
  }


  void UpdateRecommendation() async{

    var endpoint = await getEndPoint();
    var id = await getAccountID();
    var url = Uri.parse('http://$endpoint:8081/getActiveRecommendations');
    //var url = Uri.parse('http://192.168.43.123:8081/newpin');
    Map<String, dynamic> jsonMap = {
      'AccountID': id,
    };

    print(jsonMap);

    http.Response response = await http.post(url,
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Content-Type': 'application/json'
        },
        body: json.encode(jsonMap));
    final Map parsed = json.decode(response.body);
    print("${response.statusCode}");
    print(parsed);
    print("RESPONSEBODY:");
    print(response.body);

    if (response.statusCode == 200){
      List<String> stringListRecommendation = [];
      for (var item in parsed["Recommendations"]) {
        stringListRecommendation.add(item.toString());
      }
      List<String> stringListHBRecommendation = [];
      for (var item in parsed["HighBloodRecommendations"]) {
        stringListHBRecommendation.add(item.toString());
      }
      setState(() {
        _recommendation = stringListRecommendation;
        _highBloodrecommendation = stringListHBRecommendation;
      });

    }
    
  }

  void GetUserDetails() async{
    var name = await getUsername();

    var endpoint = await getEndPoint();
    var id = await getAccountID();
    var url = Uri.parse('http://$endpoint:8081/getUserDetails');
    //var url = Uri.parse('http://192.168.43.123:8081/newpin');
    Map<String, dynamic> jsonMap = {
      'AccountID': id,
    };

    print(jsonMap);

    http.Response response = await http.post(url,
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Content-Type': 'application/json'
        },
        body: json.encode(jsonMap));
    final Map parsed = json.decode(response.body);
    print("${response.statusCode}");
    print(parsed);

    if (response.statusCode == 200){
      setState(() {
        diabetic = parsed["IsDiabetic"];
        age = parsed["Age"];
        weight = parsed["Weight"];
        height = parsed["Height"];
        gender = parsed["Gender"];

        _bmi = double.parse(weight) / ( (int.parse(height)/100) * (int.parse(height)/100));
      });

    }
  }

  void GetLastUserHistory() async{

    var timerState = await getTimerState();
    if (timerState!){
      cancelTimer();
    }
    
    var endpoint = await getEndPoint();
    var id = await getAccountID();
    var url = Uri.parse('http://$endpoint:8081/getLastUserHistory');

    Map<String, dynamic> jsonMap = {
      'AccountID': id,
    };

    print(jsonMap);

    http.Response response = await http.post(url,
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Content-Type': 'application/json'
        },
        body: json.encode(jsonMap));
   

    if (response.statusCode == 200) {
      final Map parsed = json.decode(response.body);
      int timestamp = parsed["Timestamp"];

      setState(() {
        _classification = parsed["Classification"];
        _glucoseLevel = parsed["GlucoseLevel"];
        date = DateFormat('MM-dd-yyyy HH:MM').format(DateTime.fromMillisecondsSinceEpoch(timestamp*1000));
      });
    }else {
        setState(() {
        _classification = "";
        _glucoseLevel = 0;
        date = "";
      });
    }
  }

  @override
  void dispose() {
    // Cancel the Timer when the page is no longer active
    timer?.cancel();
    super.dispose();
  }

  Widget build(BuildContext context) {

    if (_glucoseLevel == 0){
      return Scaffold(body: Center(child:  Text(
               'No Glocuse Data',
                style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                ),
              ),),);
    }else{
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 30,
              ),
              Text(
                'Classification: $_classification',
                style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                  color: _classification == "Low" ? Colors.blue : _classification == "Normal" ? Colors.green :Colors.red,
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'Blood Glucose Level: $_glucoseLevel mg/dl',
                style: TextStyle(
                  fontSize: 23.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'Timestamp: $date',
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'Recommendation:',
                style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Visibility(visible: _recommendation.length == 0 ? true : false,child: SizedBox(height: 8.0)),
              Visibility(visible: _recommendation.length == 0 ? true : false, child: Center(child:  ElevatedButton(onPressed: () async{
                setState(() {
                  addBloodpressure = true;
                });

              },child: Text('Add Blood Pressure before getting Recommendations'),),)),
              Visibility(visible: addBloodpressure,child: SizedBox(height: 8.0)),
              Visibility(visible: addBloodpressure, child:Row(
                  children: [
                    Text('Bloodpressure (systolic):'),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: BloodPressurecontroller,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ) 
              ),              
              Visibility(visible: addBloodpressure,child: SizedBox(height: 8.0)),
              Visibility(visible: addBloodpressure, child:Row(
                  children: [
                    Text('Bloodpressure (diastolic):'),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ) 
              ),
              Visibility(visible: addBloodpressure,child: SizedBox(height: 8.0)),
              Visibility(visible: addBloodpressure, child:Row(
                  children: [
                    Text('Scenario:'),
                    SizedBox(width: 10),
                    DropdownButton<String>(
                      value: _scenario,
                      onChanged: (value) {
                        setState(() {
                          _scenario = value!;
                        });
                      },
                      items: [
                        DropdownMenuItem(
                          child: Text(''),
                          value: '',
                        ),
                        DropdownMenuItem(
                          child: Text('After Meal'),
                          value: 'After Meal',
                        ),
                       DropdownMenuItem(
                          child: Text('Feeling Weak'),
                          value: 'Feeling Weak',
                        ),
                        DropdownMenuItem(
                          child: Text('Has vices'),
                          value: 'Has vices',
                        ),
                      ],
                    ),
                  ],
                ) 
              ),
              Visibility(visible: _recommendation.length == 0 ? true : false,child: SizedBox(height: 8.0)),
              Visibility(visible: _recommendation.length == 0 ? true : false, child: Center(child:  ElevatedButton(onPressed: () async{
                  var endpoint = await getEndPoint();
                  var id = await getAccountID();
                  var url = Uri.parse('http://$endpoint:8081/getRecommendations');

                  setState(() {
                    if (BloodPressurecontroller.text == ""){
                      _bloodPressure = 0;
                    }else{
                    _bloodPressure = int.parse(BloodPressurecontroller.text);
                    }
                  });

                  bool IsHighBlood = false;
                  int BloodPressure = 0;
                  String Scenario = "";
                  if (addBloodpressure){
                    IsHighBlood = addBloodpressure;
                    BloodPressure = _bloodPressure;
                    Scenario = _scenario;
                  }

                  Map<String, dynamic> jsonMap = {
                    'AccountID': id,
                    'Age': age,
                    'BMI': _bmi,
                    'Classification': _classification,
                    'IsHighBlood': IsHighBlood,
                    'BloodPressure': BloodPressure,
                    'Scenario': Scenario,
                  };

                  setState(() {
                    addBloodpressure = false;
                  });

                  print(jsonMap);

                  http.Response response = await http.post(url,
                      headers: {
                        'Access-Control-Allow-Origin': '*',
                        'Content-Type': 'application/json'
                      },
                      body: json.encode(jsonMap));
                  final Map parsed = json.decode(response.body);
                  print("${response.statusCode}");
                  print(parsed);

                  setState(() {
                     List<String> stringListRecommendation = [];
                      for (var item in parsed["Recommendations"]) {
                        stringListRecommendation.add(item.toString());
                      }
                      List<String> stringListHBRecommendation = [];
                      for (var item in parsed["HighBloodRecommendations"]) {
                        stringListHBRecommendation.add(item.toString());
                      }
                    _recommendation = stringListRecommendation;
                    _highBloodrecommendation = stringListHBRecommendation;
                  });
              },child: Text('Get Recommendations'),),)),
              for (int i = 0; i < _recommendation.length; i++)
                Text(
                  '${i + 1}. ${_recommendation[i]}',
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
                 Visibility(
                  visible: _highBloodrecommendation.isEmpty ? false :true,
                   child: Text(
                                 'Recommendation on High Blood Pressure:',
                                 style: TextStyle(
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold,
                                 ),
                               ),
                 ),
              for (int i = 0; i < _highBloodrecommendation.length; i++)
                Text(
                  '${i + 1}. ${_highBloodrecommendation[i]}',
                  style: TextStyle(
                    fontSize: 20.0,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    }
  }
}
