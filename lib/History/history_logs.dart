import 'dart:convert';

import 'package:cad_app/Services/device_endpoint_config.dart';
import 'package:cad_app/Services/save_state_selected_account.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';


import 'package:http/http.dart' as http;

import '../main.dart';
import 'history_model.dart';


Future<void> _refresh() {
  return Future.delayed(
    const Duration(seconds: 1),
    () async {
      var dateNow = DateTime.now();
      String formattedDate = DateFormat('MM/dd/yyyy hh:mm a').format(dateNow);
      snackbarKey.currentState?.showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        shape: const StadiumBorder(),
        content: Row(
          children: [
            const Icon(Icons.refresh, color: Colors.red),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Text(
                'Page has been refreshed at: $formattedDate',
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ));
    },
  );
}

class HistoryListLogs extends StatefulWidget {
  const HistoryListLogs({super.key});

  @override
  State<HistoryListLogs> createState() => _HistoryListLogsState();
}

class _HistoryListLogsState extends State<HistoryListLogs> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getLogs(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          } else {
            var notify = snapshot.data;
            int itemCount = notify!.length;

            if (itemCount == 0) {
              return Scaffold(
                //appBar: _updateAppBarOnNotification(),
                body: SingleChildScrollView(
                    child: Column(
                  children: const [
                    SizedBox(
                      height: 250,
                    ),
                    Center(child: Text("There are no History Logs to be viewed!")),
                    SizedBox(
                      height: 500,
                    ),
                  ],
                )),
              );
            }
            return Scaffold(
                //appBar: _updateAppBarOnNotification(),
                body: SingleChildScrollView(
                    child: Column(
                  children: [
                    const SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                            ),
                            children: [
                              TextSpan(
                                  text: "History Logs",
                                  style:
                                      TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                      SizedBox(
                        height: 385,
                        child: RefreshIndicator(
                          color: Colors.red,
                          onRefresh: () async {
                            notify = await getLogs();
                            await Future.delayed(const Duration(seconds: 2));
                            _refresh();
                            setState(() {
                              itemCount = notify!.length;
                            });
                          },
                          edgeOffset: 15,
                          displacement: 75,
                          strokeWidth: 4,
                          triggerMode: RefreshIndicatorTriggerMode.onEdge,
                          child: ListView.builder(
                            itemCount: itemCount,
                            itemBuilder: (BuildContext context, int index) {
                              return ListTile(
                                title: _buildNotifTitle(
                                    context, index, notify![index]),
                                leading: _buildLeadingIcon(
                                    context, notify![index].Classification),
                                trailing: Column(
                                  children: [
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                        DateFormat('HH:MM dd-MM-yyyy').format(
                                            DateTime.fromMillisecondsSinceEpoch(
                                                notify![index].Timestamp * 1000)),
                                        style: TextStyle(
                                            fontSize: 14)),
                                  ],
                                ),
                                onTap: () async {
                                  debugPrint("item ${(index + 1)} selected");
                                },
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                )));
          }
        });
  }
}


Widget _buildLeadingIcon(BuildContext context, String Severity) {
  switch (Severity) {
    case "Low":
      {
        return const Icon(
          Icons.health_and_safety,
          size: 30,
          color: Colors.blue,
        );
      }
    case "High":
      {
        return const Icon(
          Icons.health_and_safety,
          size: 30,
          color: Colors.red,
        );
      }
    case "Normal":
      {
        return const Icon(
          Icons.health_and_safety,
          size: 30,
          color: Colors.green,
        );
      }
  }

  return const Scaffold();
}

Widget _buildNotifTitle(BuildContext context, int index, Logs logs) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        ("Classification: "+logs.Classification),
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold,),
      ),
      Text(("Glucose Level: " + logs.GlocuseLevel.toString() + "mg/dl"),
          style: TextStyle(
            fontSize: 16,
          ))
    ],
  );
}

// PreferredSizeWidget _updateAppBarOnNotification() {
//   return AppBar(
//     title: Column(
//       children: [
//         const SizedBox(
//           height: 30,
//           width: 150,
//         ),
//         Image.asset(
//           'images/FinalLogo.png',
//           width: 200,
//         ),
//       ],
//     ),
//     toolbarHeight: 90,
//     elevation: 0,
//     automaticallyImplyLeading: false,
//     backgroundColor: Colors.orange,
//     centerTitle: true,
//   );
// }

Future<List<Logs>> getLogs() async {
  // parse url
  var id = await getAccountID();
  var endpoint = await getEndPoint();
  var url = Uri.parse('http://$endpoint:8081/getUserHistory');

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


  // map response from server
  final Map parsed = json.decode(response.body);
  print(parsed["UserHistory"][0]["GlucoseLevel"]);
  print(Logs.fromMap(parsed["UserHistory"][0]));

  List<Logs> logs = [];
  // check if response is successful
  if (response.statusCode == 200) {
    // return parsed response of server
    for (int i = 0; i <= parsed["UserHistory"].length - 1; i++) {
      logs.add(Logs.fromMap(parsed["UserHistory"][i]));
    }

    print(logs[0].GlocuseLevel);
    print(logs[0].Timestamp);
    print(logs[0].Classification);
    print(logs.length);

    print("HELLO");
    return logs;
  }
  return logs;
}