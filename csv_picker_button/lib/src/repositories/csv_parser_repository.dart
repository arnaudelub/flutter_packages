import 'package:csv_picker_button/src/repositories/repositories.dart';
import 'package:csv/csv.dart';

/// Abstract class, do not instanciate this class as it is abstract
abstract class ICsvParserRepository {
  void setTitles(String line);
  void call();
  Map<String, dynamic> stringToJson(String line);
}

/// This is where the magic happens and  this implementation of ICsvParserRepository
/// using the csv library which will detect automatically the separator
/// and string delimiter
class CsvParserRepository implements ICsvParserRepository {
  final CsvConfiguration csvConfiguration;

  /// CsvConfiguration has to be passed to the constructor
  CsvParserRepository(this.csvConfiguration);

  /// used to store the titles
  late List<String> titles;

  /// used to be able to split the titleString into a list of Strings
  late String separatorString;

  /// use ICsvParserRepository repository = CsvParserRepository();
  /// repository();
  /// to call this method
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
      case Separator.tab:
        separatorString = '\t';
        break;
      default:
        separatorString = ',';
    }
  }

  /// Set the titles property
  /// so they can be used when passing the string to json
  @override
  void setTitles(String line) {
    titles = line.split(separatorString);
  }

  /// This will convert the current line string to
  /// a map<String, dynamic> with the title from the column as the key
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
