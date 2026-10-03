import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:depo_sayim/presentation/screens/login_screen.dart';

void main() {
  testWidgets('Login screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    await tester.pumpAndSettle();

    expect(find.text('GİRİŞ YAP'), findsOneWidget);
    expect(find.text('Beni hatırla'), findsOneWidget);
    expect(find.text('E-POSTA'), findsOneWidget);
  });
}
