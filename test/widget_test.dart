import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unit_converter/main.dart';

void main() {
  testWidgets('navigates into a reusable length converter and converts units',
      (tester) async {
    await tester.pumpWidget(const ConverterApp());
    await tester.tap(find.text('Length'));
    await tester.pumpAndSettle();
    expect(find.text('Length Converter'), findsOneWidget);
    expect(find.text('0.0010 km'), findsOneWidget);

    await tester.tap(find.byType(DropdownButtonFormField<UnitOption>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('km').last);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<UnitOption>).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('m').last);
    await tester.pumpAndSettle();
    expect(find.text('1000.0000 m'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('What would you like to convert?'), findsOneWidget);
  });

  testWidgets('converts temperature and reports invalid input', (tester) async {
    await tester.pumpWidget(const ConverterApp());
    await tester.tap(find.text('Temperature'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '0');
    await tester.pump();
    expect(find.text('32.0000 °F'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'not a number');
    await tester.pump();
    expect(find.text('Enter a valid number to convert.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

