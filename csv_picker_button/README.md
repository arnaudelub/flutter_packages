# csv_picker_button

A simple button to pick a csv file and parse it as String or Json

# Use this package as a library

## 1. Depend on it

Add this to your package's pubspec.yaml file:

```
dependencies:
  csv_picker_button: latest_version
```

### 2. Install it

You can install packages from the command line:

with Flutter:

```
$ flutter pub get
```

### 3. Import it

Now in your Dart code, you can use:

```
import 'package:csv_picker_button/csv_picker_button.dart';
```

### 4. use it

Pass the csvConfiguration, only needed if the CSV has titles and the separator is not a ',';
CsvConfiguration accept 3 properties:

- ``` Separator separator ``` with default set to Separator.coma (',')
- ``` bool hasTitle ``` with default set to true
- ``` List<String> titles ``` only needed if hasTitle is set to False but you want to get each lines returned as a Map<String, dynamic> with the title of the column has the key;

CsvButton can return two types of callBacks:

onJsonReceived which return each line as Map<String, dynamic> and
onStringReceived which return each line as String so you can parse it yourself;

CsvButton is a TextButton, so it also accept buttonStyle to style the button
and a child.

```
CsvButton(
  onJsonReceived: (Map<String, dynamic> data) => print("$data"),
  child: Text('pick a csv')
  );
```

# Dependencies

- [FilePicker](https://pub.dev/packages/file_picker)
- [csv](https://pub.dev/packages/csv/versions/5.0.0-nullsafety.0)
