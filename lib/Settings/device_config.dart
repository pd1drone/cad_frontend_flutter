import 'dart:async';
import 'dart:io';

import 'package:cad_app/Services/device_endpoint_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DeviceConfigPage extends StatefulWidget {
  @override
  _DeviceConfigPageState createState() => _DeviceConfigPageState();
}

class _DeviceConfigPageState extends State<DeviceConfigPage> {
  final ipController = TextEditingController(text: "");

  @override
  void dispose() {
    ipController.dispose();
    super.dispose();
  }

  Future<void> _handleConnect() async {
    
    var ipadd = ipController.text;
    var url = Uri.parse("http://$ipadd:8081/check");

      try {
        print("try");
        final response = await http.get(url, headers:{
          'Access-Control-Allow-Origin' : "*",
          'Content-Type' : "application/json",
        }).timeout(const Duration(seconds: 2));

        if (response.statusCode==200){
            saveEndPoint(ipadd);
            Navigator.of(context).pop();
          }else{
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Invalid Device IP Address. Please enter the correct IP and connect again'),
                duration: Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
      } on SocketException catch (e) {
        print("catch");
        print('Error fetching data: $e');
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid Device IP Address. Please enter the correct IP and connect again'),
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (e){
        print('Error fetching data: $e');
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid Device IP Address. Please enter the correct IP and connect again'),
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          ),
        );
      } on TimeoutException catch (e){
                print('Error fetching data: $e');
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid Device IP Address. Please enter the correct IP and connect again'),
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          ),
        );
      }


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Device Config"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Enter Device IP Address:",
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 300,
              child: TextField(
                controller: ipController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: _handleConnect,
                child: Text("Connect"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
