// dati da ottenere
/// nome
/// address
///

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import '../shared.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  String _address = "...";
  String _name = "...";
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  Timer _discoverableTimeoutTimer;
  int _discoverableTimeoutSecondsLeft = 0;
  BluetoothDevice selectedDevice;

  @override
  void initState() {
    super.initState();
    selectedDevice = null;
    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    Future.doWhile(() async {
      // Wait if adapter not enabled
      if (await FlutterBluetoothSerial.instance.isEnabled) {
        return false;
      }
      await Future.delayed(Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {
      // Update the address field
      FlutterBluetoothSerial.instance.address.then((address) {
        setState(() {
          _address = address;
        });
      });
    });

    FlutterBluetoothSerial.instance.name.then((name) {
      setState(() {
        _name = name;
      });
    });

    // Listen for futher state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;

        // Discoverable mode is disabled when Bluetooth gets disabled
        _discoverableTimeoutTimer = null;
        _discoverableTimeoutSecondsLeft = 0;
      });
    });
  }

  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    _discoverableTimeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      body: Container(
        child: ListView(
          children: [
            SwitchListTile(
              title: const Text('Abilità Bluetooth'),
              value: _bluetoothState.isEnabled,
              onChanged: (bool value) {
                // Do the request and update with the true value then
                future() async {
                  // async lambda seems to not working
                  if (value)
                    await FlutterBluetoothSerial.instance.requestEnable();
                  else
                    await FlutterBluetoothSerial.instance.requestDisable();
                }

                future().then((_) {
                  setState(() {
                    selectedDevice = null;
                    messaggi = [];
                  });
                });
              },
            ),
            ListTile(
              title: const Text('Bluetooth status'),
              subtitle: Text(_bluetoothState.toString()),
              trailing: RaisedButton(
                child: const Text('Impostazioni'),
                onPressed: () {
                  FlutterBluetoothSerial.instance.openSettings();
                },
              ),
            ),
            ListTile(
              title: const Text('Indirizzo Bluetooth'),
              subtitle: Text(_address),
            ),
            ListTile(
              title: const Text('Nome dispositivo'),
              subtitle: Text(_name),
              onLongPress: null,
            ),
            Divider(),
            ListTile(
              title: Text("Scansiona dispositivi"),
              subtitle: Text(selectedDevice?.name.toString()),
              trailing: RaisedButton(
                onPressed: () async {
                  final selectedDevice =
                      await Navigator.pushNamed(context, '/discovery');
                  messaggi = [];
                  setState(() {
                    this.selectedDevice = selectedDevice;
                  });
                },
                child: Text("Scan"),
              ),
            ),
            if (selectedDevice != null)
              ListTile(
                title: Text("Controlla dispositivo"),
                subtitle: Text(selectedDevice?.name.toString()),
                trailing: RaisedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/joystick',
                        arguments: {"device": selectedDevice});
                  },
                  child: Text("PLAY"),
                ),
              ),
            if (selectedDevice != null)
              ListTile(
                title: Text("Apri terminale"),
                subtitle: Text(selectedDevice?.name.toString()),
                trailing: RaisedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/terminal',
                        arguments: {"device": selectedDevice});
                  },
                  child: Text("Debug"),
                ),
              )
          ],
        ),
      ),
    );
  }
}
