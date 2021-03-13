/// enum for separator value which are:
/// [coma]: ','
/// [semiColumn]: ';'
/// [pipe]: '|'
enum Separator { coma, semiColumn, pipe }

class CsvConfiguration {
  @deprecated
  final Separator separator;
  final bool hasTitle;
  final List<String> titles;

  CsvConfiguration(
      {this.separator = Separator.coma,
      this.hasTitle = true,
      this.titles = const []})
      : assert((!hasTitle && titles.isNotEmpty) || (hasTitle && titles.isEmpty),
            'if hasTitle is false, then you have to pass titles as a List of String');
}
