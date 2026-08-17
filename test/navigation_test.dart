import 'package:ecommerence_project/screens/admin/admin_shell.dart';
import 'package:ecommerence_project/screens/navigation/customer_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('admin navigation contains management tabs only', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AdminShell(
          screens: const [
            Text('Dashboard screen'),
            Text('Products screen'),
            Text('Orders screen'),
            Text('Account screen'),
          ],
        ),
      ),
    );

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Products'), findsOneWidget);
    expect(find.text('Orders'), findsOneWidget);
    expect(find.text('Account'), findsOneWidget);
    expect(find.text('Home'), findsNothing);
    expect(find.text('Search'), findsNothing);
    expect(find.text('Saved'), findsNothing);
    expect(find.text('Cart'), findsNothing);

    await tester.tap(find.text('Products'));
    await tester.pump();
    expect(find.text('Products screen'), findsOneWidget);
  });

  testWidgets('customer navigation keeps all shopping tabs', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CustomerShell(
          screens: const [
            Text('Home screen'),
            Text('Search screen'),
            Text('Saved screen'),
            Text('Cart screen'),
            Text('Account screen'),
          ],
        ),
      ),
    );

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Saved'), findsOneWidget);
    expect(find.text('Cart'), findsOneWidget);
    expect(find.text('Account'), findsOneWidget);
    expect(find.text('Dashboard'), findsNothing);
    expect(find.text('Products'), findsNothing);
    expect(find.text('Orders'), findsNothing);

    await tester.tap(find.text('Cart'));
    await tester.pump();
    expect(find.text('Cart screen'), findsOneWidget);
  });
}
