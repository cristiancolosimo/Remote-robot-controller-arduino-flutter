import 'package:control_pad/views/joystick_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:robot_remote/routes/discoverSelect.dart';
import 'package:robot_remote/routes/home.dart';
import 'package:robot_remote/routes/joystick.dart';
import 'package:robot_remote/routes/terminal.dart';

void main() {
  runApp(
    MaterialApp(
      initialRoute: '/',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/': (context) => HomePage(),
        // When navigating to the "/second" route, build the SecondScreen widget.
        '/discovery': (context) => DiscoverSelect(),
        '/terminal': (context) => TerminalPageProxy(),
        '/joystick': (context) => JoystickPageProxy(),
      },
    ),
  );
}

//Home
//**Select bluetooth
//Joystick
//Terminal

class HomePagef extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Control Pad Example'),
      ),
      body: Container(
        color: Colors.white,
        child: JoystickView(
          size: 300,
          onDirectionChanged: (double value, double value2) {
            if (value2 > 0.5) {
              //esegui resto
              if (value > 315 || value < 45) {
                //avanti
              } else if (value > 45 || value < 135) {
                //destra
              } else if (value > 135 || value < 225) {
                //indietro
              } else if (value > 225 || value < 315) {
                //sinistra
              }
            } else if (value2 < 0.5) {
              //stop
            }
            //print("  " + value.toString());
          },
        ),
      ),
    );
  }
}
