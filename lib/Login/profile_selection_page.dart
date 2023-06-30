import 'dart:convert';

import 'package:cad_app/Services/save_state_selected_account.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../Services/cancel_timer.dart';
import '../Services/device_endpoint_config.dart';
import '../Settings/device_config.dart';
import '../main.dart';


class ProfileSelectionPage extends StatefulWidget {
  late final List<Profile> profiles;
  final Function(Profile) onProfileSelected;
  final Function() onCreateProfile;
  final Function() onDeleteProfile;
  //final Function() onLoginSelectedProfile;
  final Function() onConfigDevice;

  ProfileSelectionPage({
    required this.profiles,
    required this.onProfileSelected,
    required this.onCreateProfile,
    required this.onDeleteProfile,
    //required this.onLoginSelectedProfile,
    required this.onConfigDevice,
  });

  @override
  _ProfileSelectionPageState createState() => _ProfileSelectionPageState();
}

class _ProfileSelectionPageState extends State<ProfileSelectionPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFD01919),
              Color(0xFFFC774C),
              Color(0xFFFFD11A),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [ 
            SizedBox(
              height: 50),
            SizedBox(
              height: 80.0,
              child: Image.asset('images/FinalLogo.png'),
            ),
            SizedBox(height: 30.0),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                          SizedBox(
                      height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Center(
                            child: Text(
                              widget.profiles.isEmpty ? "Create Profile" : 'Select/Create Profile',
                              style: TextStyle(
                                fontSize: 30.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: widget.onConfigDevice,
                          icon: const Icon(Icons.settings),
                        ),
                      ],
                    ),
                    SizedBox(height: 50.0),
                    Expanded(
                      child: ListView.builder(
                        itemCount: widget.profiles.length,
                        itemBuilder: (BuildContext context, int index) {
                          Profile profile = widget.profiles[index];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedIndex = index;
                              });
                              widget.onProfileSelected(profile);
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: 40.0,
                                vertical: 10.0,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(10.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(10.0),
                                    child: CircleAvatar(
                                      radius: 40.0,
                                      backgroundImage:
                                          AssetImage(profile.imageUrl),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 10.0,
                                        horizontal: 20.0,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            profile.name,
                                            style: TextStyle(
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          SizedBox(height: 5.0),
                                          Text(
                                            'Profile',
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (_selectedIndex == index)
                                    Padding(
                                      padding: EdgeInsets.all(10.0),
                                              child: Icon(
                                        Icons.check,
                                        color: Colors.red,
                                        size: 30.0,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: widget.profiles.isEmpty ? MainAxisAlignment.center : MainAxisAlignment.spaceEvenly,
                      children: [
                        OutlinedButton(
                          onPressed: widget.onCreateProfile,
                          child: const Text(
                            'Add Profile',
                            style: TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        Visibility(
                          visible: widget.profiles.length == 0 ? false : true,
                          child: OutlinedButton(
                            onPressed: () async{

                              saveAccountID(widget.profiles[_selectedIndex].accountID);
                              saveUsername(widget.profiles[_selectedIndex].name);


                              Map<String,dynamic> jsonMap ={
                                "AccountID": widget.profiles[_selectedIndex].accountID
                              };
                              var endpoint = await getEndPoint();
                              var url = Uri.parse("http://$endpoint:8081/login");

                              http.Response response = await http.post(url, headers:{
                                'Access-Control-Allow-Origin' : "*",
                                'Content-Type' : "application/json",
                              },body: json.encode(jsonMap));
                              print(jsonMap);

                              if (response.statusCode == 200) {
                                saveTimerState(false);
                                print(response.statusCode);
                                Navigator.of(context).pushNamed('dashboard');
                              }else{
                                ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Something is wrong in selecting a user profile, Please try again Later!'),
                                  duration: Duration(seconds: 3),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              }
   
                            },
                            child: const Text(
                              'Select Profile',
                              style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: widget.profiles.isEmpty ? false : true,
                          child: OutlinedButton(
                            onPressed: () async{
                              Map<String,dynamic> jsonMap ={
                                "AccountID": widget.profiles[_selectedIndex].accountID
                              };
                              var endpoint = await getEndPoint();
                              var url = Uri.parse("http://$endpoint:8081/deleteUserProfile");

                              http.Response response = await http.post(url, headers:{
                                'Access-Control-Allow-Origin' : "*",
                                'Content-Type' : "application/json",
                              },body: json.encode(jsonMap));

                              if (response.statusCode == 200) {
                                
                                print(response.statusCode);
                                Navigator.of(context).pushNamed('deleteuser').then((_) => setState(() {
                                }));
                              }else{
                                //show snackbar error
                                print(response.statusCode);
                                print("error");
                                ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Something is wrong in deleting user, Please try again Later!'),
                                  duration: Duration(seconds: 3),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              }
                            },
                            child: const Text(
                              'Delete profile',
                              style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                        
                      ],
                    ),
                    SizedBox(height: 30.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Profile {
  final int accountID;
  final String name;
  final String imageUrl;

  Profile({required this.accountID, required this.name, required this.imageUrl});
}

