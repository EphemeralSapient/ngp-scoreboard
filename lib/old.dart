import 'dart:typed_data';

import 'package:control_app/global.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'global.dart' as globals;

bool askedOnce = false;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  BluetoothState _bState = BluetoothState.UNKNOWN;
  List<BluetoothDevice> bondedDevices = [];

  @override
  void initState() {
    Permission.bluetoothConnect.request();
    Permission.bluetoothScan.request();
    super.initState();
    checkConnected();
    FlutterBluetoothSerial.instance.onStateChanged().listen((event) {
      setState(() {
        _bState = event;
      });
    });
  }

  void checkConnected() async {
    debugPrint("Checking connected...");
    _bState = await FlutterBluetoothSerial.instance.state;
    setState(() {});
    if (_bState == BluetoothState.STATE_ON) {
      // Get the list of bonded devices only when Bluetooth is enabled
      debugPrint("Fetching bonded devices");
      List<BluetoothDevice> devices =
          await FlutterBluetoothSerial.instance.getBondedDevices();
      debugPrint(devices.toString());
      setState(() {
        bondedDevices = devices;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_bState == BluetoothState.STATE_ON) {
      askedOnce = false;
      return FindDevicesScreen(bondedDevices: bondedDevices);
    } else {
      return BluetoothOffScreen(state: _bState);
    }
  }
}

class FindDevicesScreen extends StatefulWidget {
  final List<BluetoothDevice> bondedDevices;

  const FindDevicesScreen({Key? key, required this.bondedDevices})
      : super(key: key);

  @override
  State<FindDevicesScreen> createState() => _FindDevicesScreenState();
}

class _FindDevicesScreenState extends State<FindDevicesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Connect the bluetooth device"),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: ListView.builder(
          itemCount: widget.bondedDevices.length,
          itemBuilder: (context, index) {
            return BluetoothConnectionOption(
                device: widget.bondedDevices[index]);
          },
        ),
      ),
    );
  }
}

class BluetoothConnectionOption extends StatefulWidget {
  final BluetoothDevice device;

  const BluetoothConnectionOption({Key? key, required this.device})
      : super(key: key);

  @override
  _BluetoothConnectionOptionState createState() =>
      _BluetoothConnectionOptionState();
}

class _BluetoothConnectionOptionState extends State<BluetoothConnectionOption> {
  bool connected = false; // Status of Bluetooth connection
  bool connecting = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.device.name ?? "what"),
      trailing: _buildBluetoothIcon(),
      onTap: () {
        setState(() {
          connected = !connected;
          if (connected) {
            _connectToDevice(widget.device);
          } else {
            _disconnect();
          }
        });
      },
    );
  }

  Widget _buildBluetoothIcon() {
    if (connected && connecting == false) {
      return Icon(Icons.bluetooth_connected);
    } else if (connecting == true) {
      return Icon(Icons.bluetooth_searching);
    } else {
      return Icon(Icons.bluetooth_disabled);
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      connection = await BluetoothConnection.toAddress(device.address);
      setState(() {
        connecting = true;

        connected = true;
      });

      // Send "A" in ASCII bytes (65 is the ASCII code for "A")
      // connection!.output.add(Uint8List.fromList([65]));

      // To send a string, you can use the following:
      // String message = "A";
      // connection.output.add(Uint8List.fromList(message.codeUnits));
      connection!.input!.listen((event) {
        try {
          globals.callback(event);
        } catch (e) {
          debugPrint("CALLBACK FAILED : " + e.toString());
        }
      });
      // When done, close the connection
      // connection.dispose();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error : ${e.toString().substring(0, 140)}')));
      setState(() {
        connected = false;
        connecting = false;
      });
    }
    // setState(() {
    //   connecting = false;
    // });
  }

  Future<void> _disconnect() async {
    // Implement disconnection logic here
    // You may need to keep a reference to the connected BluetoothConnection
    // object to call 'dispose()' on it when disconnecting.
    // Example:
    // if (connection != null && connection.isConnected) {
    //   await connection.dispose();
    // }
    setState(() {
      connected = false;
    });
  }
}

class BluetoothOffScreen extends StatelessWidget {
  final BluetoothState state;

  const BluetoothOffScreen({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () async {
      if (askedOnce == false) {
        askedOnce = true;
        try {
          FlutterBluetoothSerial.instance.requestEnable();
        } catch (e) {}
      }
    });
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bluetooth_disabled,
              size: 100,
              color: Colors.grey,
            ),
            SizedBox(height: 20),
            Text(
              'Bluetooth is ${state != null ? state.toString().substring(15) : 'not available'}.',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}

List<BluetoothDeviceUI> devices = [
  BluetoothDeviceUI(
    name: 'TEAM A',
    uiElements: [
      BluetoothUIElement(type: UIElementType.integer, label: 'Score', value: 0),
      BluetoothUIElement(
          type: UIElementType.string, label: 'Team name', value: 'Team A'),
    ],
  ),
  BluetoothDeviceUI(
    name: 'TEAM B',
    uiElements: [
      BluetoothUIElement(type: UIElementType.integer, label: 'Score', value: 0),
      BluetoothUIElement(
          type: UIElementType.string, label: "Team name", value: "Team B"),
    ],
  ),
  BluetoothDeviceUI(name: "Timer", uiElements: [
    BluetoothUIElement(
        type: UIElementType.timer, label: 'Game Timer', value: 0),
  ])
];

class ScoreboardScreen extends StatefulWidget {
  @override
  _ScoreboardScreenState createState() => _ScoreboardScreenState();
}

class _ScoreboardScreenState extends State<ScoreboardScreen> {
  Brightness _brightness = Brightness.light;

  void _toggleBrightness() {
    setState(() {
      _brightness =
          _brightness == Brightness.light ? Brightness.dark : Brightness.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      darkTheme: ThemeData(
        brightness: _brightness,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: _brightness,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      theme: ThemeData(
        brightness: _brightness,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: _brightness,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.latoTextTheme(
            Theme.of(context).textTheme), // Use 'Lato' font
        primarySwatch: Colors.deepPurple,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: GoogleFonts.lato().fontFamily, // Use 'Lato' font
          ),
        ),
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: Scaffold(
        appBar: AppBar(title: Text('Scoreboard'), actions: [
          PopupMenuButton<Brightness>(
            onSelected: (brightness) {
              setState(() {
                _brightness = brightness;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: Brightness.light,
                child: Text('Light theme'),
              ),
              const PopupMenuItem(
                value: Brightness.dark,
                child: Text('Dark theme'),
              ),
            ],
          )
        ]),
        body: ListView(
          children: [
            if (connection == null) SizedBox(height: 130, child: Home()),
            Divider(),
            ...devices
                .map((device) => BluetoothDeviceContainer(device: device))
                .toList(),
          ],
        ),
      ),
    );
  }
}

class BluetoothDeviceUI {
  final String name;
  final List<BluetoothUIElement> uiElements;

  BluetoothDeviceUI({required this.name, required this.uiElements});
}

enum UIElementType { integer, string, timer }

class BluetoothUIElement {
  final UIElementType type;
  final String label;
  dynamic value;

  BluetoothUIElement(
      {required this.type, required this.label, required this.value});
}

class BluetoothDeviceContainer extends StatefulWidget {
  final BluetoothDeviceUI device;

  BluetoothDeviceContainer({required this.device});

  @override
  _BluetoothDeviceContainerState createState() =>
      _BluetoothDeviceContainerState();
}

class _BluetoothDeviceContainerState extends State<BluetoothDeviceContainer>
    with SingleTickerProviderStateMixin {
  bool expanded = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(widget.device.name),
          onTap: () {
            setState(() {
              expanded = !expanded;
              if (expanded) {
                _controller.forward();
              } else {
                _controller.reverse();
              }
            });
          },
        ),
        SizeTransition(
          sizeFactor: _animation,
          child: Column(
            children: widget.device.uiElements
                .map((element) => buildUIElement(element))
                .toList(),
          ),
        ),
        Divider(),
      ],
    );
  }

  Widget buildUIElement(BluetoothUIElement element) {
    switch (element.type) {
      case UIElementType.integer:
        return ListTile(
          title: Text(element.label),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: () {
                  setState(() {
                    element.value -= 1;
                  });
                },
              ),
              // Text('${element.value}'),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    element.value += 1;
                    connection!.output.add(Uint8List.fromList([65]));
                  });
                },
              ),
            ],
          ),
        );
      case UIElementType.string:
        return ListTile(
          title: Text(element.label),
          trailing: GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => EditStringDialog(value: element.value),
              ).then((newValue) {
                if (newValue != null) {
                  setState(() {
                    element.value = newValue;
                  });
                }
              });
            },
            child: Text('${element.value}'),
          ),
        );
      case UIElementType.timer:
        return ListTile(
          title: Text(element.label),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: () {
                  setState(() {
                    element.value -= 1;
                  });
                },
              ),
              // Text('${element.value}'),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    element.value += 1;
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.play_arrow),
                onPressed: () {
                  // Start timer logic
                },
              ),
              IconButton(
                icon: Icon(Icons.stop),
                onPressed: () {
                  // Stop timer logic
                },
              ),
            ],
          ),
        );
    }
  }
}

class EditStringDialog extends StatefulWidget {
  final String value;

  const EditStringDialog({required this.value});

  @override
  _EditStringDialogState createState() => _EditStringDialogState();
}

class _EditStringDialogState extends State<EditStringDialog> {
  late TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: widget.value);
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit String'),
      content: TextFormField(
        controller: _textEditingController,
        autofocus: true,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
        ),
        style: TextStyle(
          fontSize: 16.0,
          color: Colors.black87,
        ),
      ),
      actions: [
        TextButton.icon(
          icon: Icon(Icons.cancel),
          label: Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton.icon(
          icon: Icon(Icons.save),
          label: Text('Save'),
          onPressed: () {
            final newValue = _textEditingController.text;
            Navigator.pop(context, newValue);
          },
        ),
      ],
    );
  }
}

class BluetoothScreen extends StatefulWidget {
  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  BluetoothConnection? connection;
  List<BluetoothDevice> devices = [];
  BluetoothDevice? selectedDevice;

  @override
  void initState() {
    super.initState();
    initBluetooth();
  }

  void initBluetooth() async {
    try {
      await FlutterBluetoothSerial.instance.requestEnable();
    } catch (e) {
      print('Error enabling Bluetooth: $e');
    }

    FlutterBluetoothSerial.instance.startDiscovery().listen((device) {
      setState(() {
        debugPrint(device.toString());
        if (!devices.contains(device)) {
          devices.add(device.device);
        }
      });
    });
  }

  void connectToDevice() async {
    if (selectedDevice == null) {
      return;
    }

    if (connection != null) {
      connection!.close();
    }

    try {
      connection = await BluetoothConnection.toAddress(selectedDevice!.address);
      print('Connected to ${selectedDevice!.name}');
    } catch (e) {
      print('Error connecting to device: $e');
    }
  }

  void sendData(String data) async {
    if (connection == null) {
      print('Not connected to any device');
      return;
    }

    try {
      //connection!.output.add(ascii.encodesource data.codeUnits);
      await connection!.output.allSent;
      print('Data sent: $data');
    } catch (e) {
      print('Error sending data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HC-05 Communication'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Available Devices:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index];
                return ListTile(
                  title: Text(device.name!),
                  subtitle: Text(device.address),
                  onTap: () {
                    setState(() {
                      selectedDevice = device;
                    });
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: connectToDevice,
              child: Text('Connect'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                sendData('Hello, HC-05!');
              },
              child: Text('Send Data'),
            ),
          ),
        ],
      ),
    );
  }
}
