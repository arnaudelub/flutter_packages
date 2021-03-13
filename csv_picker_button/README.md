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

```
CsvButton(
  onJsonReceived: (Map<String, dynamic> data) => print("$data"),
  child: Text('pick a csv')
  );
```

# Dependencies

- [FilePicker](https://pub.dev/packages/file_picker)
- [csv](https://pub.dev/packages/csv/versions/5.0.0-nullsafety.0)
