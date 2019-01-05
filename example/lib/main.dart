import 'dart:async';

import 'package:drifter/drifter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var _values = <String, Object>{};

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  reassemble() {
    super.reassemble();
    this.initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    _values['Last Debug State'] = await Drifter.debug(true);

    if (defaultTargetPlatform == TargetPlatform.android) {
      if (!await Drifter.hasPermission('android.permission.READ_PHONE_STATE')) {
        _values['request READ_PHONE_STATE'] = await Drifter.requestPermission('android.permission.READ_PHONE_STATE');
      }
    }

    try {
      _values.addAll(<String, Object>{
        'IDFA': await Drifter.idfv(),
        'IDFV': await Drifter.idfa(),
        'IMEI': await Drifter.imei(),
        'IMSI': await Drifter.imsi(),
        'MEID': await Drifter.meid(),
        'DeviceId': await Drifter.deviceId(),
        'bluetoothAddress': await Drifter.bluetoothAddress(),
        'wifiMacAddress': await Drifter.wifiMacAddress(),
        'generateRandomUuid': await Drifter.generateRandomUuid(),
      });
      for (var v in [
        'android.permission.READ_PHONE_STATE',
        'android.permission.BLUETOOTH',
      ]) {
        _values[v] = await Drifter.hasPermission(v);
      }
    } catch (e, st) {
      _values['ERROR'] = '$e';
      _values['StackTrace'] = '$st';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Drifter plugin example app'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[]..addAll(
              _values.entries.map((v) => Text('${v.key}\n${v.value}', maxLines: 2)).toList(),
            ),
        ),
      ),
    );
  }
}
