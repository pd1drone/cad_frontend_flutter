import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cad_app/Dashboard/dashboard.dart';
import 'package:cad_app/Dashboard/whitebackground.dart';
import 'package:flutter/material.dart';
//import 'package:netflix_clone/profile_selection_page.dart';

import 'Login/profile_selection_page.dart';
import 'package:http/http.dart' as http;

import 'Profile/add_profile.dart';
import 'Profile/diabetes_page.dart';
import 'Services/device_endpoint_config.dart';
import 'Settings/device_config.dart';
import 'package:intl/intl.dart';


final GlobalKey<ScaffoldMessengerState> snackbarKey = GlobalKey<ScaffoldMessengerState>();

void main() async{

AwesomeNotifications().initialize('resource://drawable/ic_launcher', [
    NotificationChannel(
      channelKey: 'basic_channel',
      channelName: 'basic_channel',
      channelDescription: 'Notification channel for basic tests',
      defaultColor: Colors.blue,
      ledColor: Colors.white,
      importance: NotificationImportance.High,
      playSound: true,
      enableLights: true,
      enableVibration: true,
      channelShowBadge: true,
    )
  ], channelGroups: [
    NotificationChannelGroup(
        channelGroupName: 'basic_channel', channelGroupkey: 'basic_channel')
  ]);


  // Initialize the AwesomeNotifications plugin
  await AwesomeNotifications().initialize(
    'resource://drawable/ic_launcher',
    [
      NotificationChannel(
        channelKey: 'scheduled',
        channelName: 'Scheduled Notifications',
        channelDescription: 'Notifications for scheduled events',
        defaultColor: Colors.blue,
        ledColor: Colors.white,
      ),
    ],
  );

  // Register the background handler
  AwesomeNotifications().actionStream.listen((receivedNotification) {
    if (receivedNotification.createdSource == NotificationSource.Schedule) {
      // Handle the received notification here
    }
  });
  
  
  runApp(MyStartApp());
  
  var endpoint = await getEndPoint();
  if (endpoint == ""){
    saveEndPoint("192.168.254.123");
  }
}


class MyStartApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CAD',
      theme: ThemeData(primarySwatch: Colors.red),
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: snackbarKey,
      home: const MyApp(),
      routes: {
        'adduser': (context) => const AddUserPage(),
        'deleteuser': (context) => const MyApp(),
        'frontpage': (context) => const MyApp(),
        'configureip': (context) => DeviceConfigPage(),
        'dashboard': (context) => const DashBoardPage(),
        'loadingpage': (context) => const WhiteBackgroundScreen(),
        'diabetispage': (context) =>  DiabetesPage(),
      },
    );
  }
}

class MyApp extends StatefulWidget{
  const MyApp({super.key});
  @override

  State<MyApp> createState() => _MyApp();
}

class _MyApp extends State<MyApp>{
  List<Profile> profiledata = [];
  @override
  void initState() {
    super.initState();
    GetProfiles();

    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        showDialog(context: context, builder: (BuildContext context) {
          return AlertDialog(title: Text("Allow Notifications"),
        content: Text("Our app would like to send you notifications"),
        actions: [
          TextButton(onPressed: (){
            Navigator.pop(context);
          }, child: Text("Don't Allow",style: TextStyle(color: Colors.grey, fontSize: 18),)),
          TextButton(onPressed: (){
            AwesomeNotifications().requestPermissionToSendNotifications().then((_) => Navigator.pop(context));
          }, child: Text("Allow",style: TextStyle(color: Colors.teal, fontSize: 18,fontWeight: FontWeight.bold),))
        ],
        );
      });
      }
    });
  }


  void resetState() {
    // Reset the page's state here
    GetProfiles();
  }
  void GetProfiles() async{
    var endpoint = await getEndPoint();
    var url = Uri.parse("http://$endpoint:8081/getUserProfile");

    http.Response response = await http.get(url, headers:{
      'Access-Control-Allow-Origin' : "*",
      'Content-Type' : "application/json",
    });

    final Map parsed = json.decode(response.body);

  List<Profile> profile = [];
    if(response.statusCode == 200){
      if (parsed.isNotEmpty) {
        for(int i=0;i<=parsed["UserProfiles"].length -1;i++){
          var data = parsed["UserProfiles"][i];
          profile.add(Profile(accountID: data["AccountID"], name: data["Name"], imageUrl: data["ProfileImg"]));
        }
      }
    }

    setState((){
      profiledata = profile;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: ProfileSelectionPage(
        profiles:profiledata ,
        onProfileSelected: (selectedProfile) {
          // Handle profile selection
        },
        onCreateProfile: () async{
          // Handle profile creation
          print("PRESSED CREATE PROFILE!");
          Navigator.of(context).pushNamed('adduser').then((_) => setState(() {
            GetProfiles();
          }));
        },
        onDeleteProfile: (){

        },
        onConfigDevice:(){
          Navigator.of(context).pushNamed("configureip").then((_) => setState(() {
            GetProfiles();
          }));
        }
      ),

    );
  }
}