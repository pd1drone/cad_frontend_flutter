import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedStartTime = TimeOfDay(hour: 0, minute: 0);
  TimeOfDay _selectedEndTime = TimeOfDay(hour: 0, minute: 0);
  int _selectedFrequencyValue = 1;
  String _selectedFrequencyUnit = 'Minutes';
  bool IsInMinutes = true;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedStartTime,
    );
    if (picked != null && picked != _selectedStartTime) {
      setState(() {
        _selectedStartTime = picked;
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedEndTime,
    );
    if (picked != null && picked != _selectedEndTime) {
      setState(() {
        _selectedEndTime = picked;
      });
    }
  }

//   Future<void> _scheduleNotification() async {
//   // Calculate the duration between the start and end time
//   final start = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _selectedStartTime.hour, _selectedStartTime.minute);
//   final end = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _selectedEndTime.hour, _selectedEndTime.minute);
//   final duration = end.difference(start);

//   // Schedule the first notification
//   await AwesomeNotifications().createNotification(
//     content: NotificationContent(
//       id: 0,
//       channelKey: 'scheduled',
//       title: 'Event started',
//       body: 'Your event has started!',
//       notificationLayout: NotificationLayout.BigPicture,
//       bigPicture: 'asset://assets/images/event.png',
//     ),
//     schedule: NotificationInterval(
//       interval: _selectedFrequencyValue,
//       //timeUnit: _selectedFrequencyUnit == 'Minutes' ? IntervalUnit.MINUTE : IntervalUnit.HOUR,
//       //initialDateTime: start,
//       allowWhileIdle: true,
//       preciseAlarm: true,
//       repeats: true,
//     ),
//   );
// }

Future<void> _createEvent() async {
  // get the start time and end time
  final DateTime startTime = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _selectedStartTime.hour, _selectedStartTime.minute);
  final DateTime endTime = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _selectedEndTime.hour, _selectedEndTime.minute);
  
  print(startTime);
  print(endTime);
  // calculate the duration between the start time and end time
  final Duration duration = endTime.difference(startTime);
  
  // schedule the notification using AwesomeNotifications
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 0,
      channelKey: 'scheduled',
      title: 'Event reminder',
      body: 'Your event is ongoing!',
      notificationLayout: NotificationLayout.Default,
      displayOnForeground: true,
      //largeIcon: 'https://png.pngtree.com/png-vector/20220612/ourmid/pngtree-medical-icon-with-stethoscope-vector-illustration-png-image_5031757.png',
      //bigPicture: 'https://png.pngtree.com/png-vector/20220612/ourmid/pngtree-medical-icon-with-stethoscope-vector-illustration-png-image_5031757.png',
    ),
    schedule: NotificationCalendar(
      weekday: startTime.weekday,
      hour: startTime.hour,
      minute: startTime.minute,
      second: 0,
      millisecond: 0,
      //repeatInterval: _selectedFrequencyUnit == 'Minutes' ? Duration(minutes: _selectedFrequencyValue) : Duration(hours: _selectedFrequencyValue),
      repeats: true,
    ),
  );
  // schedule the periodic notification using Timer.periodic()
  Timer timer = Timer.periodic(_selectedFrequencyUnit == 'Minutes' ? Duration(minutes: _selectedFrequencyValue) : Duration(hours: _selectedFrequencyValue), (timer) async {

      
    DateTime now = DateTime.now();
    if (now.isBefore(endTime)) {
      Duration timeUntilEnd = endTime.difference(now);
      Timer endTimer = Timer(timeUntilEnd, () {
        timer.cancel();
      });
    } else {
      timer.cancel();
    }

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: timer.tick,
        channelKey: 'scheduled',
        title: 'Notification reminder: Measure Patient Glocuse count',
        body: 'Please measure your Glocuse count now!',
        notificationLayout: NotificationLayout.Default,
        displayOnForeground: true,
      //largeIcon: 'https://png.pngtree.com/png-vector/20220612/ourmid/pngtree-medical-icon-with-stethoscope-vector-illustration-png-image_5031757.png',
      //bigPicture: 'https://png.pngtree.com/png-vector/20220612/ourmid/pngtree-medical-icon-with-stethoscope-vector-illustration-png-image_5031757.png',
      ),
    );
  });
}


  Widget _buildFrequencyDropdown() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Frequency: ', style: TextStyle(fontSize: 20),),
          SizedBox(width: 10),
          DropdownButton<int>(
            value: _selectedFrequencyValue,
            items: List.generate(
              IsInMinutes ? 60 : 24,
              (index) => DropdownMenuItem(
                child: Text('${index + 1}'),
                value: index + 1,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _selectedFrequencyValue = value!;
              });
            },
          ),
          SizedBox(width: 10),
          DropdownButton<String>(
            value: _selectedFrequencyUnit,
            items: ['Minutes', 'Hours']
                .map((unit) => DropdownMenuItem(
                      child: Text(unit, style: TextStyle(fontSize: 20),),
                      value: unit,
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedFrequencyUnit = value!;
              });
              if (_selectedFrequencyUnit == 'Hours'){
                setState(() {
                IsInMinutes = false;
                });
              }else{
                setState(() {
                IsInMinutes = true;
                });
              }
            },
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: Text('Select Date'),
                ),
                SizedBox(height: 20),
                Text('Selected Date: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}', style: TextStyle(fontSize: 25),),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _selectStartTime(context),
                  child: Text('Select Start Time'),
                ),
                SizedBox(height: 20),
                Text('Selected Start Time: ${_selectedStartTime.format(context)}', style: TextStyle(fontSize: 25),),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _selectEndTime(context),
                  child: Text('Select End Time'),
                ),SizedBox(height: 20),
        Text('Selected End Time: ${_selectedEndTime.format(context)}', style: TextStyle(fontSize: 25),),
        SizedBox(height: 20),
        _buildFrequencyDropdown(),
        SizedBox(height: 20),
        ElevatedButton(
        onPressed: () {
          _createEvent();
        },
        child: Text('Create Event'),
        ),
        ],
        ),
        ),
        ),
),
);
}
}

