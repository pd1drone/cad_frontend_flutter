
import 'package:cad_app/Dashboard/dashboard_logout.dart';
import 'package:cad_app/Home/home_page.dart';
import 'package:flutter/material.dart';

import '../Calendar/calendar.dart';
import '../History/history_logs.dart';
import '../Profile/profile_page.dart';


class DashBoardPage extends StatefulWidget {
  const DashBoardPage({super.key});

  @override
  State<DashBoardPage> createState() => _DashBoardPageState();
}

class _DashBoardPageState extends State<DashBoardPage> {
  int currentPage = 0;
  List<Widget> pages = [
     HomePage(),
     HistoryListLogs(),
     CalendarPage(),
     ProfilePage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getAppBar(context, currentPage),
        bottomNavigationBar: NavigationBar(
          destinations: const [
            NavigationDestination(
                icon: Icon(
                  Icons.home,
                  color: Colors.black,
                  size: 30,
                ),
                label: 'Home'),
            NavigationDestination(
                icon:  Icon(
                  Icons.history,
                  color: Colors.black,
                  size: 30,
                ),
                label: 'Logs'),
            NavigationDestination(
                icon:  Icon(
                  Icons.calendar_month,
                  color: Colors.black,
                  size: 30,
                ),
                label: 'Calendar'),
                NavigationDestination(
                icon:  Icon(
                  Icons.people,
                  color: Colors.black,
                  size: 30,
                ),
                label: 'Profile'),
          ],
          onDestinationSelected: (int index) {
            setState(() {
              currentPage = index;
            });
          },
          selectedIndex: currentPage,
        ),
        body: pages[currentPage]);
  }
}

Widget? getLogoutButton(BuildContext context, currPage){
  if (currPage == 0){
    return IconButton(onPressed: (){
      showLogoutAlert(context);
    }, icon: const Icon(Icons.logout));
  }
}
AppBar? getAppBar(BuildContext context, currPage) {
  if(currPage != 3){
    return AppBar(
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
        leading: getLogoutButton(context, currPage),
        backgroundColor: Colors.red,
        centerTitle: true,
      );
  }
  return null;
}