import 'package:cad_app/Services/device_endpoint_config.dart';
import 'package:cad_app/Services/save_state_selected_account.dart';
import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  bool diabetic = false;
  int age = 0;
  String weight = "";
  String height = "";
  String gender="";
  String bmi = "";


  bool _isEditing = false;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  TextEditingController _weightController = TextEditingController();
  TextEditingController _heightController = TextEditingController();
  String _diabeticValue = "Yes";
  String _genderValue = "Male";
  double _bmi = 0.0;

  @override

    void initState() {
    super.initState();

    //saveButtonState(false);
    GetNbnDetails(context);
  }

  void GetNbnDetails(BuildContext context) async {
    var name = await getUsername();

    setState(() {
      _nameController.text = name!;
    });

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

    setState(() {
      diabetic = parsed["IsDiabetic"];
      age = parsed["Age"];
      weight = parsed["Weight"];
      height = parsed["Height"];
      gender = parsed["Gender"];

      _bmi = double.parse(weight) / ( (int.parse(height)/100) * (int.parse(height)/100));
      bmi = _bmi.toStringAsFixed(2);

      _diabeticValue = diabetic ? "Yes" : "No";
      _ageController.text = age.toString();
      _weightController.text = weight;
      _heightController.text = height;
      _genderValue = gender == "Male" ? "Male" : "Female";

    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const SizedBox(
              height: 30,
              width: 150,
            ),
            Image.asset(
              'images/FinalLogo.png',
              width: 200,
            ),
          ],
        ),
        toolbarHeight: 90,
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: [
          IconButton(
            icon: _isEditing ? Icon(Icons.cancel) : Icon(Icons.edit),
            onPressed: () async {
              if(_isEditing){
                var endpoint = await getEndPoint();
                var id = await getAccountID();
                var url = Uri.parse('http://$endpoint:8081/postUserDetails');
                //var url = Uri.parse('http://192.168.43.123:8081/newpin');
                Map<String, dynamic> jsonMap = {
                  'AccountID': id,
                  'Name': _nameController.text,
                  'IsDiabetic': _diabeticValue == "Yes" ? true : false,
                  'Age': int.parse(_ageController.text),
                  'Weight': double.parse(_weightController.text),
                  'Height' : int.parse(_heightController.text),
                  'Gender' : _genderValue
                };

                print(jsonMap);

                http.Response response = await http.post(url,
                    headers: {
                      'Access-Control-Allow-Origin': '*',
                      'Content-Type': 'application/json'
                    },
                body: json.encode(jsonMap));

                if(response.statusCode==200){
                  saveUsername(_nameController.text);
                  setState(() {
                    _bmi = double.parse(_weightController.text) / ( (int.parse(_heightController.text)/100) * (int.parse(_heightController.text)/100));
                    bmi = _bmi.toStringAsFixed(2);
                  });
                }

              }
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          )
        ]
        ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.0),
              Center(
                child: Row(
                  children: [
                    Text("Name:  ", style: TextStyle(fontSize: 18.0)),
                  SizedBox(
                    height: 40,
                    width: 250,
                    child: Center(
                      child: TextField(
                      controller: _nameController,
                      enabled: _isEditing,
                      decoration: InputDecoration(
                        hintText: " Enter your name",
                      ),
                                    ),
                    ),
                  ),
                  ],
                ),
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Text("Diabetic:  ", style: TextStyle(fontSize: 18.0)),
                  DropdownButton(
                value: _diabeticValue,
                items: [
                  DropdownMenuItem(child: Text("Yes"), value: "Yes"),
                  DropdownMenuItem(child: Text("No"), value: "No"),
                ],
                onChanged: _isEditing
                    ? (value) {
                        setState(() {
                          _diabeticValue = value.toString();
                        });
                      }
                    : null,
              ),
                ],
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Text("Gender:  ", style: TextStyle(fontSize: 18.0)),
                  DropdownButton(
                value: _genderValue,
                items: [
                  DropdownMenuItem(child: Text("Male"), value: "Male"),
                  DropdownMenuItem(child: Text("Female"), value: "Female"),
                ],
                onChanged: _isEditing
                    ? (value) {
                        setState(() {
                          _genderValue = value.toString();
                        });
                      }
                    : null,
              ),
                ],
              ),
              
              SizedBox(height: 16.0),
              Row(
                children: [
                  Text("Age:  ", style: TextStyle(fontSize: 18.0)),
                  SizedBox(
                    height: 40,
                    width: 105,
                    child: TextField(
                controller: _ageController,
                enabled: _isEditing,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Enter your age",
                ),
              ),
                  )
                ],
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Text("Weight:  ", style: TextStyle(fontSize: 18.0)),
                  SizedBox( height: 40,
                    width: 250,
                    child:  TextField(
                controller: _weightController,
                enabled: _isEditing,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Enter your weight in kg",
                ),
              ),)
                ],
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Text("Height:  ", style: TextStyle(fontSize: 18.0)),
                  SizedBox(height: 40,
                    width: 250,
                    child:TextField(
                controller: _heightController,
                enabled: _isEditing,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Enter your height in cm",
                ),
            ),
                  )
                ],
              ),
            const SizedBox(
              height: 20,
            ),
            Text(
               'BMI: $bmi',
              style: TextStyle(fontSize: 18),
            ),
        ],
          ),
        ),
      ),
);
}
}