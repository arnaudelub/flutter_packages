import 'dart:async';
import 'dart:convert';

import 'package:rxdart/rxdart.dart';
import 'package:file_picker/file_picker.dart';

/// This is the key name for the lin number: 'lineNumber'
const lineNumberMapField = 'lineNumber';

/// This is the key name for data: 'data'
const dataMapField = 'data';

/// abstract class, do not instanciate IFilePickerRepository,
/// but it can be used as a type
abstract class IFilePickerRepository {
  Stream<Map<String, dynamic>> getCsvStream();
  Stream<bool> getCloseStream();
  Future<void> call();
}

/// This class will handle the FilePicker action and implements IFilePickerRepository
class FilePickerRepository implements IFilePickerRepository {
  final StreamController<Map<String, dynamic>> _csvStreamController =
      BehaviorSubject<Map<String, dynamic>>();

  final StreamController<bool> _closerStreamController =
      BehaviorSubject<bool>();

  /// listen to this stream with a [StreamSubscription] to get
  /// each line of the csv file
  @override
  Stream<Map<String, dynamic>> getCsvStream() {
    return _csvStreamController.stream;
  }

  /// listen to this stream with a [StreamSubscription] to know
  /// when this csvStream is done
  @override
  Stream<bool> getCloseStream() {
    return _closerStreamController.stream;
  }

  /// IFilePickerRepository repository = FilePickerRepository();
  /// then just use repository() to init and call this method.
  @override
  Future<void> call() async {
    try {
      int lineCounter = 1;
      final file = await FilePicker.platform.pickFiles(
          allowedExtensions: ['csv'],
          withReadStream: true,
          type: FileType.custom);
      if (file != null) {
        final stream = file.files.first.readStream!;
        stream
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .listen((line) {
          _csvStreamController
              .add({lineNumberMapField: lineCounter, dataMapField: line});
          lineCounter++;
        }).onDone(() => _close());
      }
    } catch (e) {
      print(e);
    }
  }

  /// Closing the streams
  Future<void> _close() async {
    await _csvStreamController.close();
    _closerStreamController.add(true);
    await _closerStreamController.close();
  }
}
