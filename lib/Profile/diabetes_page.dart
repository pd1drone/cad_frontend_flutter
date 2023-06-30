import 'package:cad_app/Services/save_state_selected_account.dart';
import 'package:flutter/material.dart';

import '../Services/device_endpoint_config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DiabetesPage extends StatefulWidget {
  @override
  _DiabetesPageState createState() => _DiabetesPageState();
}

class _DiabetesPageState extends State<DiabetesPage> {
  String _diabetic = 'No'; // set default value for diabetic dropdown
  String _gender = 'Female'; // set default value for gender dropdown
  int _age = 0;
  double _weight = 0.0;
  int _height = 0;

  @override
  void initState() {
    super.initState();
    // set default values for dropdowns
    _diabetic = 'No';
    _gender = 'Female';
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Add User"),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Diabetic',
                style: TextStyle(fontSize: 16.0),
              ),
              DropdownButton<String>(
                value: _diabetic,
                onChanged: (value) {
                  setState(() {
                    _diabetic = value!;
                  });
                },
                items: [
                  DropdownMenuItem(
                    child: Text('Yes'),
                    value: 'Yes',
                  ),
                  DropdownMenuItem(
                    child: Text('No'),
                    value: 'No',
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              Text(
                'Gender',
                style: TextStyle(fontSize: 16.0),
              ),
              DropdownButton<String>(
                value: _gender,
                onChanged: (value) {
                  setState(() {
                    _gender = value!;
                  });
                },
                items: [
                  DropdownMenuItem(
                    child: Text('Female'),
                    value: 'Female',
                  ),
                  DropdownMenuItem(
                    child: Text('Male'),
                    value: 'Male',
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              Text(
                'Age',
                style: TextStyle(fontSize: 16.0),
              ),
              TextField(
                 textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _age = int.parse(value);
                  });
                },
              ),
              SizedBox(height: 20.0),
              Text(
                'Weight',
                style: TextStyle(fontSize: 16.0),
              ),
              TextField(
                 textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _weight = double.parse(value);
                  });
                },
              ),
              SizedBox(height: 20.0),
              Text(
                'Height',
                style: TextStyle(fontSize: 16.0),
              ),
              TextField(
                 textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _height = int.parse(value);
                  });
                },
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () async{

                var endpoint = await getEndPoint();
                var id = await getCreatedAccountID();
                var url = Uri.parse('http://$endpoint:8081/postUserDetails');
                //var url = Uri.parse('http://192.168.43.123:8081/newpin');
                var name = await getCreatedUsername();
                Map<String, dynamic> jsonMap = {
                  'AccountID': id,
                  'Name': name,
                  'IsDiabetic': _diabetic == "Yes" ? true : false,
                  'Age': _age,
                  'Weight': _weight,
                  'Height' : _height,
                  'Gender' : _gender
                };

                print(jsonMap);

                http.Response response = await http.post(url,
                    headers: {
                      'Access-Control-Allow-Origin': '*',
                      'Content-Type': 'application/json'
                    },
                body: json.encode(jsonMap));

                if(response.statusCode==200){
                   //double _bmi = _weight/ ( _height/100) * (_height/100);
                   
                }else{
                        //show snackbar error
                         ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Something is wrong in adding a user, Please try again Later!'),
                                  duration: Duration(seconds: 3),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                      }
                Navigator.pop(context);
                Navigator.pop(context);
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}