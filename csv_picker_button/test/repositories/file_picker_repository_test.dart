import 'package:csv_picker_button/src/repositories/repositories.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFilePicker extends Mock implements FilePicker {}

void main() {
  FilePickerRepository filePickerRepository = FilePickerRepository();
  MockFilePicker mockFilePicker = MockFilePicker();
  group('Testing FilePickerRepository', () {
    test('Should return a Map from string', () async {
      when(() => mockFilePicker.pickFiles()).thenAnswer((_) async =>
          FilePickerResult([PlatformFile(path: '../fixtures/test.csv')]));
      await filePickerRepository();
    });
  });
}
