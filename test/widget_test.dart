// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hvv_meldapplicatie/main.dart';

void main() {
  testWidgets('App starts with StartScreen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HartVoorVerkeerApp());

    // Verify that the slogan is displayed
    expect(find.text('Samen maken we het verkeer veiliger'), findsOneWidget);
    
    // Verify that the buttons are present
    expect(find.text('Aanmelden'), findsOneWidget);
    expect(find.text('Over ons'), findsOneWidget);
  });
}