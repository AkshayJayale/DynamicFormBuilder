# dynamic_ui_builder Example

This example demonstrates how to use the `dynamic_ui_builder` package to build dynamic forms and UIs in Flutter.

## Getting Started

1. Ensure you have Flutter installed. For setup instructions, see the [Flutter documentation](https://docs.flutter.dev/get-started/install).
2. In this directory, run:
   ```sh
   flutter pub get
   flutter run
   ```

This will launch the example app showcasing dynamic UI building capabilities, including:
- Multi-step forms
- All standard and plugin-based fields
- **Filter fields with FilterChip UI (independent/dependent)**
- **Global form data store**

## Example: Using Filter Fields

Add filter fields to your JSON config as follows:

```dart
final formJson = [
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

## Accessing Form Data Globally

All form values are stored in a singleton:

```dart
import 'package:dynamic_ui_builder/src/models/form_data_store.dart';

// Access all form data
topLevelMap = FormDataStore.instance.data;

// Clear all form data
FormDataStore.instance.clear();
```

For more details, see the main package [README](../README.md).
