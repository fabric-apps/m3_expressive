import 'package:flutter_test/flutter_test.dart';
import 'package:m3_expressive/m3_expressive.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('M3LoadingIndicator renders without error', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Center(child: M3LoadingIndicator()))),
    );
    expect(find.byType(M3LoadingIndicator), findsOneWidget);
  });

  testWidgets('M3UndoPill renders with required params', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              M3UndoPill(
                label: 'Item removed',
                onComplete: () {},
                onCancel: () {},
              ),
            ],
          ),
        ),
      ),
    );
    expect(find.text('Item removed'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);
  });

  testWidgets('M3DismissibleListItem renders child', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: M3DismissibleListItem(
            onDismissed: () {},
            onTap: () {},
            child: const Text('Test item'),
          ),
        ),
      ),
    );
    expect(find.text('Test item'), findsOneWidget);
  });
}
