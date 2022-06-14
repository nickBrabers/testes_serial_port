import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:testes_lib_serial/app_controller.dart';
import 'package:usb_serial/usb_serial.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatefulWidget {
  const ExampleApp({Key? key}) : super(key: key);

  @override
  _ExampleAppState createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  final appController = AppController();

  @override
  void initState() {
    super.initState();
    appController.initPorts();
  }

  @override
  void dispose() {
    super.dispose();
    appController.disposePorts();
    appController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Serial Port example'),
        ),
        body: Scrollbar(
          child: StreamBuilder<List<UsbDevice>>(
              stream: appController.devicesController,
              builder: (context, sDevices) {
                return StreamBuilder<List<SerialPort>>(
                  stream: appController.portsController,
                  builder: (context, sPorts) {
                    return ListView(
                      children: [
                        if (sPorts.hasData && !sPorts.hasError)
                          for (final port in sPorts.requireData)
                            Builder(
                              builder: (context) {
                                return ExpansionTile(
                                  title: Text(port.address.toString()),
                                  children: [
                                    CardListTile(
                                        'Description', port.description),
                                    CardListTile('Transport',
                                        port.transport.toTransport()),
                                    CardListTile(
                                        'USB Bus', port.busNumber?.toPadded()),
                                    CardListTile('USB Device',
                                        port.deviceNumber?.toPadded()),
                                    CardListTile(
                                        'Vendor ID', port.vendorId?.toHex()),
                                    CardListTile(
                                        'Product ID', port.productId?.toHex()),
                                    CardListTile(
                                        'Manufacturer', port.manufacturer),
                                    CardListTile(
                                        'Product Name', port.productName),
                                    CardListTile(
                                        'Serial Number', port.serialNumber),
                                    CardListTile(
                                        'MAC Address', port.macAddress),
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      height: 0.5,
                                      color: Colors.black,
                                    ),
                                  ],
                                );
                              },
                            ),
                        if (sDevices.hasData && !sDevices.hasError)
                          for (final device in sDevices.requireData)
                            CardListTile(
                                device.deviceName, device.manufacturerName)
                      ],
                    );
                  },
                );
              }),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.refresh),
          onPressed: () async {
            // appController.initPorts();
            final devices = await UsbSerial.listDevices();
            debugPrint(devices.toString());
            await appController.initDevicesController();
          },
        ),
      ),
    );
  }
}

class CardListTile extends StatelessWidget {
  final String name;
  final String? value;

  const CardListTile(this.name, this.value, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(value ?? 'N/A'),
        subtitle: Text(name),
      ),
    );
  }
}
