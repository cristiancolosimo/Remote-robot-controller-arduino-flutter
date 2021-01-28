import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:control_pad/views/joystick_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:match/match.dart';

import '../shared.dart';

String operation(int angolo, int raggio) {
  if (raggio > 70) {
    //esegui resto
    final result = angolo.match({
      range(225, 315): () => "go left!",
      range(45, 135): () => "go right!",
      range(135, 225): () => "Back!",
      any: () => "Forward!"
    });

    return result;
  } else if (raggio < 70) {
    //stop
    return "Stop!";
  }
  return "Stop!";
}

class JoystickPageProxy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return JoystickPage(
        device: (ModalRoute.of(context).settings.arguments as Map)["device"]);
  }
}

class JoystickPage extends StatefulWidget {
  final BluetoothDevice device;
  const JoystickPage({Key key, this.device}) : super(key: key);

  @override
  JoystickPageState createState() => JoystickPageState();
}

class JoystickPageState extends State<JoystickPage> {
  static final clientID = 0;
  BluetoothConnection connection;
  String lastPosition = "Stop!";
  String _messageBuffer = '';

  final TextEditingController textEditingController =
      new TextEditingController();
  final ScrollController listScrollController = new ScrollController();

  bool isConnecting = true;
  bool get isConnected => connection != null && connection.isConnected;

  bool isDisconnecting = false;

  @override
  void initState() {
    super.initState();
    textEditingController.clear();
    BluetoothConnection.toAddress(widget.device.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Joystick"),
      ),
      body: Container(
        child: Column(
          children: [
            Flexible(
              child: JoystickView(
                size: 300,
                onDirectionChanged: (double value, double value2) {
                  //print("  " + value.toString());
                  _sendMessage(
                      operation(value.toInt(), (value2 * 100).toInt()));
                },
              ),
            ),
            Container(
              child: Text(isConnecting
                  ? 'Aspettando la connessione...'
                  : isConnected
                      ? 'Puoi giocare...'
                      : 'Sei stato disconesso'),
            )
          ],
        ),
      ),
    );
  }

  void _sendMessage(String text) async {
    text = text.trim();
    textEditingController.clear();
    //print(text);
    if (text.length > 0 && lastPosition != text) {
      lastPosition = text;
      try {
        connection.output.add(utf8.encode(text + "\r\n"));
        await connection.output.allSent;

        setState(() {
          messaggi.add(text);
        });
      } catch (e) {
        // Ignore error, but notify state
        setState(() {});
      }
    }
  }
}
