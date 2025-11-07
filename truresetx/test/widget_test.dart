// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:truresetx/features/home/simple_home_screen.dart';

void main() {
  testWidgets('Simple home shows welcome', (WidgetTester tester) async {
    // Wrap the screen in a MaterialApp to provide Directionality, Theme, etc.
    await tester.pumpWidget(const MaterialApp(home: SimpleHomeScreen()));

    // Verify that our home screen shows the welcome text.
    expect(find.text('Welcome to Your Wellness Journey'), findsOneWidget);
    expect(find.text('TruResetX'), findsOneWidget);
  });
}
