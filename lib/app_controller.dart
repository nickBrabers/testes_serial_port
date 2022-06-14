import 'dart:async';

import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:rxdart/subjects.dart';
import 'package:usb_serial/usb_serial.dart';

class AppController {
  static final _singleton = AppController._();
  AppController._();
  factory AppController() {
    return _singleton;
  }

  // final permissionController = BehaviorSubject<PermissionStatus>();
  //
  // Future<void> initPermission() async {
  //   final permissionStatus = await Permission.storage.request();
  //   if(permissionStatus == PermissionStatus.granted) {
  //     permissionController.add(permissionStatus);
  //     return;
  //   }
  //   initPermission();
  // }
  //
  final portsController = BehaviorSubject<List<SerialPort>>();
  final devicesController = BehaviorSubject<List<UsbDevice>>();

  late StreamSubscription usbEventController;

  void initPorts() {
      final ports = <SerialPort>[];
      try {
        for (final name in SerialPort.availablePorts) {
                ports.add(SerialPort(name));
              }
      } catch (e) {
        portsController.addError(e);
      }
  }

  Future<void> disposePorts() async {
    final controller = portsController.stream;
    final subscription = controller.listen((event) {
      for (final port in event) {
        port.dispose();
      }
    });
    await subscription.cancel();
  }

  Future<void> initDevicesController() async {
    usbEventController = UsbSerial.usbEventStream!.listen((event) async {
      final devices = await UsbSerial.listDevices();
      devicesController.add(devices);
    });
  }
  Future<void> dispose() async {
    await usbEventController.cancel();
  }
}

extension IntToString on int {
  String toHex() => '0x${toRadixString(16)}';
  String toPadded([int width = 3]) => toString().padLeft(width, '0');
  String toTransport() {
    switch (this) {
      case SerialPortTransport.usb:
        return 'USB';
      case SerialPortTransport.bluetooth:
        return 'Bluetooth';
      case SerialPortTransport.native:
        return 'Native';
      default:
        return 'Unknown';
    }
  }
}
