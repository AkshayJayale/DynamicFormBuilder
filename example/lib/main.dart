import 'package:dynamic_ui_builder/dynamic_ui_builder.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_ui_builder/src/widgets/field_factory.dart';
import 'package:dynamic_ui_builder/src/models/form_field_config.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Dynamic UI Example'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Dynamic Form'),
                Tab(text: 'Single Field'),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              DynamicFormTab(),
              SingleFieldForm(),
            ],
          ),
        ),
      ),
    );
  }
}

class DynamicFormTab extends StatelessWidget {
  const DynamicFormTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (innerContext) => DynamicUiBuilder(
        jsonConfig: formJson,
        onSubmit: (result) {
          showDialog(
            context: innerContext,
            builder: (_) => AlertDialog(
              title: const Text('Form Submitted'),
              content: Text(result.toString()),
            ),
          );
        },
      ),
    );
  }
}

class SingleFieldForm extends StatefulWidget {
  const SingleFieldForm({super.key});

  @override
  State<SingleFieldForm> createState() => _SingleFieldFormState();
}

class _SingleFieldFormState extends State<SingleFieldForm> {
  final _formKey = GlobalKey<FormState>();
  String? _fullName;
  final Map<String, dynamic> _formData = {};
  var fullNameField = {
    "type": "text",
    "label": "Full Name",
    "key": "name",
    "hint": "Enter your full name",
    "regex": "^[a-zA-Z ]+\$",
    "error": "Only alphabets allowed",
    "step": 0,
    "title": "Personal Information",
    "required": false
  };
  late final FormFieldConfig _config = FormFieldConfig.fromJson(fullNameField);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FieldFactory.build(
              _config,
              context,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  _fullName = _formData['name'];
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Success'),
                      content: Text('Full Name: $_fullName'),
                    ),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

final formJson = [
  {
    "type": "filter",
    "label": "Category",
    "key": "category",
    "filterType": "independent",
    "options": ["Electronics", "Clothing", "Books"],
    "validation": {"required": true},
    "step": 0,
    "title": "Filters"
  },
  {
    "type": "text",
    "label": "Full Name",
    "key": "name",
    "hint": "Enter your full name",
    "regex": "^[a-zA-Z ]+\$",
    "error": "Only alphabets allowed",
    "step": 0,
    "title": "Personal Information",
    "required": true
  },
  {
    "type": "text",
    "label": "Mobile Number",
    "key": "mobile",
    "hint": "Enter your mobile number",
    "inputType": "phone",
    "regex": "^[0-9]{10}\$",
    "error": "Please enter a valid 10-digit mobile number",
    "maxLength": 10,
    "minLength": 10,
    "maxLines": 1,
    "minLines": 1,
    "step": 0,
    "title": "Personal Information",
    "required": true
  },
  {
    "type": "dropdown",
    "label": "Gender",
    "key": "gender",
    "options": ["Male", "Female", "Other"],
    "step": 0,
    "title": "Personal Information",
    "required": true
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
    "validation": {"required": true},
    "step": 1,
    "title": "Filters"
  },
  {
    "type": "radio",
    "label": "Preferred Contact Method",
    "key": "contact_method",
    "options": ["Email", "Phone", "SMS"],
    "step": 1,
    "title": "Contact Preferences",
    "required": true
  },
  {
    "type": "checkbox",
    "label": "Subscribe to Newsletter",
    "key": "newsletter",
    "step": 1,
    "title": "Contact Preferences",
    "required": true
  },
  {
    "type": "switch",
    "label": "Enable Notifications",
    "key": "notifications",
    "step": 1,
    "title": "Contact Preferences",
    "required": true
  },
  {
    "type": "slider",
    "label": "Satisfaction Level",
    "key": "satisfaction",
    "min": 0,
    "max": 10,
    "divisions": 10,
    "step": 1,
    "title": "Contact Preferences",
    "required": true
  },
  {
    "type": "text",
    "label": "Address",
    "key": "address",
    "hint": "Enter your complete address",
    "inputType": "multiline",
    "step": 2,
    "title": "Personal Information",
    "required": true
  },
  {
    "type": "date",
    "label": "Date of Birth",
    "key": "dob",
    "step": 2,
    "minDate": "2022-01-01",
    "maxDate": "2025-12-31",
    "required": true
  },
  {
    "type": "signature",
    "label": "Your Signature",
    "key": "signature",
    "step": 3,
    "title": "Personal Information",
    "required": true
  },
  {
    "type": "rating",
    "label": "Rate Us",
    "key": "rating",
    "step": 3,
    "title": "Personal Information",
    "required": true
  },
  {
    "type": "image_picker",
    "label": "Profile Image",
    "key": "profile_image",
    "step": 4,
    "title": "Attachments",
    "required": false
  },
  {
    "type": "file_picker",
    "label": "Resume (PDF, DOC, etc.)",
    "key": "resume_file",
    "step": 4,
    "title": "Attachments",
    "required": false
  },
  {
    "type": "pdf_view",
    "label": "View PDF",
    "key": "pdf_file",
    "step": 4,
    "title": "Attachments",
    "required": false
  },
  {
    "type": "pdf_view",
    "label": "View PDF Using Url",
    "key": "pdf_file_url",
    "step": 4,
    "title": "Attachments",
    "pdf_file_url": "https://example.com/yourfile.pdf",
    "required": false
  },
  {
    "type": "pdf_view",
    "label": "View PDF Using Assets",
    "key": "pdf_file_asset",
    "step": 4,
    "title": "Attachments",
    'pdf_file_asset': 'assets/yourfile.pdf',
    "required": false
  }
];
