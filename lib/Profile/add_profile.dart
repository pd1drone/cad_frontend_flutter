import 'package:flutter/material.dart';

import '../Services/device_endpoint_config.dart';
import '../Services/save_state_selected_account.dart';
import '../Settings/device_config.dart';
import '../main.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class AddUserPage extends StatefulWidget {
  const AddUserPage({Key? key}) : super(key: key);

  @override
  _AddUserPageState createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  String? _selectedImage;
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Add User"),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: "Name"),
            ),
            const SizedBox(height: 16),
            const Text("Select Profile Picture:"),
            const SizedBox(height: 8),
            SizedBox(
              height: 400,
              width: 400,
              child: SingleChildScrollView(
                child: GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  children: List.generate(
                    4,
                    (index) => GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedImage = "images/profile$index.png";
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _selectedImage == "images/profile$index.png"
                                ? Colors.blue
                                : Colors.grey,
                            width: 5,
                          ),
                        ),
                        child: Image.asset("images/profile$index.png"),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, null);
                  },
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final name = _nameController.text.trim();
                    if (name.isNotEmpty && _selectedImage != null) {
                      
                      var endpoint = await getEndPoint();
                      Map<String,dynamic> jsonMap ={
                        "Name": name,
                        "ProfileImg": _selectedImage
                      };

                      var url = Uri.parse("http://$endpoint:8081/addUserProfile");

                      http.Response response = await http.post(url, headers:{
                        'Access-Control-Allow-Origin' : "*",
                        'Content-Type' : "application/json",
                      },body: json.encode(jsonMap));

                      if (response.statusCode == 200) {
                        final Map parsed = json.decode(response.body);
                        print(parsed["AccountID"]);
                        saveCreatedAccountID(parsed["AccountID"]);
                        saveCreatedUsername(name);

                        Navigator.of(context).pushNamed('diabetispage');
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

                    }
                  },
                  child: const Text("Next"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
