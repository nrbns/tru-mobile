// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:truresetx/main.dart';

void main() {
  testWidgets('App builds smoke test', (WidgetTester tester) async {
    // Build the app and ensure it renders without throwing.
    await tester.pumpWidget(const ProviderScope(child: TruResetXApp()));
    await tester.pumpAndSettle();

    // The app widget should be present in the widget tree.
    expect(find.byType(TruResetXApp), findsOneWidget);
  });
}
