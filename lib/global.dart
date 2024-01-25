library global;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

BluetoothConnection? connection;

dynamic connectionChangeFnNotify;

dynamic callback;

bool winSet = false;

bool foul = false;

String? bg;

bool isConnected = false;

void loopCheck(dynamic a) async {
  debugPrint(a.toString());
  while (true) {
    sleep(const Duration(milliseconds: 100));
    try {
      bool status = connection?.isConnected ?? false;
      debugPrint(status.toString());
      if (status != isConnected) {
        connectionChangeFnNotify(status);
        isConnected = status;
        debugPrint("Changed the status to : ${status.toString()}");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
