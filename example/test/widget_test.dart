// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:drifter/drifter.dart';
import 'package:drifter_example/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Verify Platform version', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that platform version is retrieved.
    expect(
      find.byWidgetPredicate(
        (Widget widget) => widget is Text && widget.data.startsWith('IDFA'),
      ),
      findsOneWidget,
    );

    expect(await Drifter.debug(true), equals(false));

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      expect(await Drifter.idfa(), isNot(null));
      expect(await Drifter.idfv(), isNot(null));
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      expect(await Drifter.idfv(), equals(null));
      expect(await Drifter.wifiMacAddress(), isNot(null));
    }
  });
}
