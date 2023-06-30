import 'dart:async';

import 'package:flutter/material.dart';


import '../../../main.dart';
import '../Services/cancel_timer.dart';
import '../Services/device_endpoint_config.dart';
import 'package:http/http.dart' as http;

showLogoutAlert(BuildContext context ) {

  // set up the buttons
  Widget cancelButton = ElevatedButton(
    style: TextButton.styleFrom(
      backgroundColor: Colors.white, // Background Color
    ),
    child: const Text(
      "No",
      style: TextStyle(color: Colors.black),
    ),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );
  Widget continueButton = ElevatedButton(
    style: TextButton.styleFrom(
      backgroundColor: Colors.red, // Background Color
    ),
    onPressed: () async{

      saveTimerState(true);

      var endpoint = await getEndPoint();
      var url = Uri.parse("http://$endpoint:8081/logout");

      http.Response response = await http.get(url, headers:{
        'Access-Control-Allow-Origin' : "*",
        'Content-Type' : "application/json",
      });

      if (response.statusCode == 200){
        Navigator.of(context).pop();
        Navigator.of(context).pushNamed('loadingpage');
        _onLoading(context);
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.of(context).pop();

          Navigator.of(context).pushNamed('frontpage');
          snackbarKey.currentState?.showSnackBar(SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            shape: const StadiumBorder(),
            content: Row(
              children: const [
                Icon(Icons.logout, color: Colors.white),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Text(
                    'Successfully Logged-out.',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ));
          // Navigator.pushReplacement(context,
          //     MaterialPageRoute(builder: (context) => const LoginPage()));
        });
      }else{
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Something is wrong in logging out, Please try again Later!'),
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    },
    child: const Text(
      "Yes",
      style: TextStyle(color: Colors.black),
    ),
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: const Text("Logout"),
    content: const Text(
      "Are you sure you want to logout",
    ),
    actions: [
      cancelButton,
      continueButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

void _onLoading(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        child: SizedBox(
          height: 60,
          width: 30,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: const [
              CircularProgressIndicator(color: Colors.red),
              SizedBox(
                width: 20,
              ),
              Text(
                "Logging out...",
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
        ),
      );
    },
  );
}