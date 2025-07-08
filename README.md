# Dynamic Form Builder

A Flutter package to dynamically generate multi-step forms using JSON configuration or render single fields independently.

## ✨ Features
- Stepper UI based on JSON-defined steps
- All standard input fields (TextField, Dropdown, Checkbox, Radio, Switch, Slider, Date/Time)
- Plugin-based fields: Image Picker, File Picker, Signature Pad, Rating Bar
- Custom validation via regex
- Alignment and layout customization
- **Render any single field independently (without JSON)**

## 🚀 Getting Started

### 1. Add dependency
```yaml
dependencies:
  dynamic_form_builder:
    git:
      url: https://github.com/your_username/dynamic_form_builder.git
```

### 2. Import the package
```dart
import 'package:dynamic_form_builder/dynamic_form_builder.dart';
```

### 3. Define your JSON config (for full form)
```dart
const formJson = [
  {
    "type": "text",
    "label": "Name",
    "key": "name",
    "hint": "Enter your name",
    "regex": "^[a-zA-Z ]+",
    "step": 0
  },
  {
    "type": "signature",
    "label": "Signature",
    "key": "signature",
    "step": 1
  }
];
```

### 4. Use `DynamicFormBuilder` (Multi-step Form)
```dart
DynamicFormBuilder(
  jsonConfig: formJson,
  onSubmit: (result) {
    print(result);
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
    regex: r'^[^@]+@[^@]+\.[^@]+\$',
    error: 'Invalid email',
  ),
  onSaved: (value) => print('Saved: \$value'),
)
```

## 📦 Supported Field Types
| Type           | Widget           |
|----------------|------------------|
| `text`         | TextFormField    |
| `dropdown`     | DropdownButton   |
| `radio`        | RadioListTile    |
| `checkbox`     | CheckboxListTile |
| `switch`       | SwitchListTile   |
| `slider`       | Slider           |
| `date`         | showDatePicker   |
| `time`         | showTimePicker   |
| `image`        | image_picker     |
| `file`         | file_picker      |
| `signature`    | signature pad    |
| `rating`       | RatingBar        |

## 📝 License
MIT

---

> Built with by Akshay
