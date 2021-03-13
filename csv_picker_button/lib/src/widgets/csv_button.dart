import 'dart:async';

import 'package:csv_picker_button/src/repositories/csv_parser_repository.dart';
import 'package:csv_picker_button/src/repositories/repositories.dart';
import 'package:csv_picker_button/src/styles/styles.dart';
import 'package:flutter/material.dart';

/// This is a simple button to bu used to pick
/// a csv file.
/// use [onStringReceived] if you want to receive each line as a string
/// or use [onJsonReceived] to receive it as a json if the CSV has titles
class CsvButton extends StatelessWidget {
  final ButtonStyle? buttonStyle;
  final CsvConfiguration? csvConfiguration;
  final Function(String data)? onStringReceived;
  final Function(Map<String, dynamic> data)? onJsonReceived;
  final Widget child;

  const CsvButton(
      {Key? key,
      this.buttonStyle,
      this.csvConfiguration,
      required this.child,
      this.onJsonReceived,
      this.onStringReceived})
      : assert(
            (onJsonReceived == null && onStringReceived != null) ||
                (onJsonReceived != null && onStringReceived == null),
            'you can only choose to receive the data as String or as Json, not both'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      key: const Key('csv_picker_textbutton'),
      style: buttonStyle ?? DefaultStyle.buttonStyle,
      onPressed: _getAndParse,
      child: child,
    );
  }

  Future<void> _getAndParse() async {
    final IFilePickerRepository _repository = FilePickerRepository();
    final config = csvConfiguration ?? CsvConfiguration();
    final ICsvParserRepository _csvRepository =
        CsvParserRepository(csvConfiguration ?? CsvConfiguration());
    StreamSubscription<Map<String, dynamic>>? _csvStreamSubscription;
    await _repository();
    _csvRepository();
    _repository.getCloseStream().listen((bool data) {
      if (data) {
        _csvStreamSubscription?.cancel();
      }
    });
    _csvStreamSubscription = _repository
        .getCsvStream()
        .listen((data) => _onFileReceived(data, _csvRepository, config));
  }

  _onFileReceived(Map<String, dynamic> data,
      ICsvParserRepository csvParserRepository, CsvConfiguration config) {
    if (config.hasTitle &&
        data[lineNumberMapField] == 1 &&
        onJsonReceived != null) {
      csvParserRepository.setTitles(data[dataMapField]);
    } else {
      if (onStringReceived != null) {
        onStringReceived!(data[dataMapField]);
      } else {
        onJsonReceived!(csvParserRepository.stringToJson(data[dataMapField]));
      }
    }
  }
}
