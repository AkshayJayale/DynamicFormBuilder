# Dynamic UI Builder

A Flutter package to dynamically generate multi-step forms or single fields from JSON configuration. Easily build complex forms with validation, custom layouts, and plugin-based fields.

[![pub package](https://img.shields.io/pub/v/dynamic_ui_builder.svg)](https://pub.dev/packages/dynamic_ui_builder)

## ✨ Features
- Multi-step form UI from JSON
- All standard input fields (Text, Dropdown, Checkbox, Radio, Switch, Slider, Date/Time)
- Plugin-based fields: Image Picker, File Picker, Signature Pad, Rating Bar
- **Filter fields with FilterChip UI:** Support for both independent (main category) and dependent (subcategory) filters, with dynamic options via `optionsMap`.
- **Global form data store:** All form values are managed in a singleton (`FormDataStore`), accessible app-wide.
- Custom validation (regex, min/max, required, etc.)
- Alignment and layout customization
- **Render any single field independently (without JSON)**

## 🚀 Installation
Add to your `pubspec.yaml`:
```yaml
dependencies:
  dynamic_ui_builder: ^1.0.3+10
```
Then run:
```sh
flutter pub get
```

## 🛠️ Usage

### 1. Import the package
```dart
import 'package:dynamic_ui_builder/dynamic_ui_builder.dart';
```

### 2. Define your JSON config (for a full form)
```dart
const formJson = [
  {
    "type": "filter",
    "label": "Category",
    "key": "category",
    "filterType": "independent",
    "options": ["Electronics", "Clothing", "Books"],
    "validation": {"required": true}
  },
  {
    "type": "filter",
    "label": "Subcategory",
    "key": "subcategory",
    "filterType": "dependent",
    "dependsOn": "category",
    "optionsMap": {
      "Electronics": ["Mobiles", "Laptops"],
      "Clothing": ["Shirts", "Pants"],
      "Books": ["Fiction", "Non-fiction"]
    },
    "validation": {"required": true}
  },
  // ... other fields ...
];
```

### 3. Use `DynamicUiBuilder` (Multi-step Form)
```dart
DynamicUiBuilder(
  jsonConfig: formJson,
  onSubmit: (result) {
    print(result); // result is a Map<String, dynamic>
  },
)
```

### ✅ Use Single Field Without JSON
```dart
DynamicFormField(
  config: FormFieldConfig(
    type: 'text',
    label: 'Email',
    key: 'email',
    regex: r'^[^@]+@[^@]+\.[^@]+',
    error: 'Invalid email',
  ),
  onSaved: (value) => print('Saved: $value'),
)
```

### 🌐 Global Form Data Store
All form values are stored in a singleton:
```dart
import 'package:dynamic_ui_builder/src/models/form_data_store.dart';

// Access all form data
topLevelMap = FormDataStore.instance.data;

// Clear all form data
FormDataStore.instance.clear();
```

## 📦 Supported Field Types
| Type         | Widget             | Options/Notes                |
|--------------|--------------------|------------------------------|
| `text`       | TextFormField      | inputType, minLength, maxLength, regex, required |
| `dropdown`   | DropdownButton     | options, required            |
| `radio`      | RadioListTile      | options, required            |
| `checkbox`   | CheckboxListTile   | required                     |
| `switch`     | SwitchListTile     | required                     |
| `slider`     | Slider             | min, max, divisions, required|
| `date`       | showDatePicker     | minDate, maxDate, required   |
| `time`       | showTimePicker     | required                     |
| `image`      | image_picker       |                              |
| `file`       | file_picker        |                              |
| `signature`  | signature pad      |                              |
| `rating`     | RatingBar          |                              |
| `filter`     | FilterChipField    | filterType (independent/dependent), options, optionsMap, dependsOn |

## 🧩 Field Configuration Options
- `type` (String): Field type (see above)
- `label` (String): Field label
- `key` (String): Unique key for result map
- `hint` (String): Placeholder/hint text
- `regex` (String): Validation regex
- `error` (String): Custom error message
- `inputType` (String): 'text', 'email', 'number', etc.
- `options` (List): For dropdown/radio/filter
- `optionsMap` (Map): For dependent filter fields
- `dependsOn` (String): For dependent filter fields
- `filterType` (String): 'independent' or 'dependent' for filter fields
- `step` (int): Step number (for multi-step)
- `min`, `max`, `divisions`: For slider
- `minLength`, `maxLength`, `minLines`, `maxLines`: For text
- `minDate`, `maxDate`: For date
- `required` (bool): Required field
- `title` (String): Step title (optional)

## 📋 Example Output
On submit, you get a `Map<String, dynamic>` with all field values:
```dart
{
  "category": "Electronics",
  "subcategory": "Mobiles",
  "name": "John Doe",
  // ...
}
```

## 📝 License
MIT

---
> Built with by Akshay
