import 'package:csv_picker_button/src/repositories/repositories.dart';
import 'package:csv/csv.dart';

abstract class ICsvParserRepository {
  void setTitles(String line);
  void call();
  Map<String, dynamic> stringToJson(String line);
}

class CsvParserRepository implements ICsvParserRepository {
  final CsvConfiguration csvConfiguration;

  CsvParserRepository(this.csvConfiguration);

  late List<String> titles;
  late String separatorString;
  late Map<String, dynamic> lineToJson;

  @override
  void call() {
    switch (csvConfiguration.separator) {
      case Separator.coma:
        separatorString = ',';
        break;
      case Separator.pipe:
        separatorString = '|';
        break;
      case Separator.semiColumn:
        separatorString = ';';
        break;
      default:
        separatorString = ',';
    }
  }

  @override
  void setTitles(String line) {
    titles = line.split(separatorString);
  }

  @override
  Map<String, dynamic> stringToJson(String line) {
    List<List<dynamic>> rowsAsListOfValues =
        const CsvToListConverter().convert(line);

    final listOfString = rowsAsListOfValues[0];
    final Map<String, dynamic> map = {};
    for (int i = 0; i < listOfString.length; i++) {
      final title = titles[i];
      final value = listOfString[i];
      map[title] = value;
    }
    return map;
  }
}
