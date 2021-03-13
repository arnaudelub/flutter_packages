import 'package:csv_picker_button/csv_picker_button.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import './helpers/helpers.dart';

void main() {
  testWidgets('Should render the button', (tester) async {
    await tester
        .pumpApp(CsvButton(onJsonReceived: (_) {}, child: const Text('test')));
    expect(find.byType(CsvButton), findsOneWidget);
  });
}
