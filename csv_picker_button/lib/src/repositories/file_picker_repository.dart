import 'dart:async';
import 'dart:convert';

import 'package:rxdart/rxdart.dart';
import 'package:file_picker/file_picker.dart';

const lineNumberMapField = 'lineNumber';
const dataMapField = 'data';

abstract class IFilePickerRepository {
  Stream<Map<String, dynamic>> getCsvStream();
  Stream<bool> getCloseStream();
  Future<void> call();
}

class FilePickerRepository implements IFilePickerRepository {
  final StreamController<Map<String, dynamic>> _csvStreamController =
      BehaviorSubject<Map<String, dynamic>>();

  final StreamController<bool> _closerStreamController =
      BehaviorSubject<bool>();

  @override
  Stream<Map<String, dynamic>> getCsvStream() {
    return _csvStreamController.stream;
  }

  @override
  Stream<bool> getCloseStream() {
    return _closerStreamController.stream;
  }

  @override
  Future<void> call() async {
    try {
      int lineCounter = 1;
      final file = await FilePicker.platform
          .pickFiles(allowedExtensions: ['csv'], withReadStream: true);
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

  Future<void> _close() async {
    await _csvStreamController.close();
    _closerStreamController.add(true);
    await _closerStreamController.close();
  }
}
