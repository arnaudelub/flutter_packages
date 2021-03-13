import 'package:csv_picker_button/src/widgets/widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/helpers.dart';

class MockFilePicker extends Mock implements FilePicker {}

void main() {
  final child = Text('test');
  group('Testing the Widget CsvButton', () {
    testWidgets(
        'Should throw an exception if onStringReceived and onJsonReceived are null',
        (test) async {
      try {
        await test.pumpApp(CsvButton(child: child));
        fail("No assertion");
      } on AssertionError catch (e) {
        expect(e.message,
            'you can only choose to receive the data as String or as Json, not both');
      }
    });
    testWidgets(
        'Should throw an exception if onStringReceived and onJsonReceived are not null',
        (test) async {
      try {
        await test.pumpApp(CsvButton(
            onJsonReceived: (_) {}, onStringReceived: (_) {}, child: child));
        fail("No assertion");
      } on AssertionError catch (e) {
        expect(e.message,
            'you can only choose to receive the data as String or as Json, not both');
      }
    });
    testWidgets(
        'Should render the button is onStringReceived is null and onJsonReceived is not null',
        (test) async {
      try {
        await test.pumpApp(CsvButton(child: child));

        fail("No assertion");
      } on AssertionError catch (e) {
        expect(e.message,
            'you can only choose to receive the data as String or as Json, not both');
      }
    });
    testWidgets(
        'Should render the button is onStringReceived is not null and onJsonReceived is null',
        (test) async {
      await test.pumpApp(CsvButton(onStringReceived: (_) {}, child: child));

      expect(find.byType(CsvButton), findsWidgets);
    });
    testWidgets(
        'Should render the button is onStringReceived is  null and onJsonReceived is not null',
        (test) async {
      await test.pumpApp(CsvButton(onJsonReceived: (_) {}, child: child));

      expect(find.byType(CsvButton), findsWidgets);
    });
  });
}
