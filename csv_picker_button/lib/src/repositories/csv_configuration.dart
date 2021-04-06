/// enum for separator value which are:
/// [coma]: ','
/// [semiColumn]: ';'
/// [pipe]: '|'
enum Separator { comma, semicolon, pipe, tab }

/// Set the titles manually by passing a List<String> to title and set hasTitle to false
/// or use the flag hasTitle = true to parse the first line as title.
/// onJsonReceived will return a map with title of the column as key
/// default separator is ',' [Separator.coma]
class CsvConfiguration {
  final Separator separator;
  final bool hasTitle;
  final List<String> titles;

  CsvConfiguration(
      {this.separator = Separator.comma,
      this.hasTitle = true,
      this.titles = const []})
      : assert((!hasTitle && titles.isNotEmpty) || (hasTitle && titles.isEmpty),
            'if hasTitle is false, then you have to pass titles as a List of String');
}
