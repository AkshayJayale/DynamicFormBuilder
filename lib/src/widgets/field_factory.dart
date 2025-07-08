import 'package:flutter/material.dart';
import '../models/form_field_config.dart';
import 'package:signature/signature.dart';
import 'dart:developer';

class FieldFactory {
  static Widget build(
    FormFieldConfig field,
    Map<String, dynamic> formData,
    BuildContext context, {
    void Function()? onChanged,
  }) {
    switch (field.type) {
      case 'text':
        return TextFormField(
          decoration:
              InputDecoration(labelText: field.label, hintText: field.hint),
          keyboardType: _getKeyboardType(field.inputType),
          maxLength: field.maxLength,
          maxLines: field.maxLines,
          minLines: field.minLines,
          validator: (value) {
            if ((field.required ?? false) && (value == null || value.isEmpty))
              return 'Required';
            // If not required and empty, skip further validation
            if (!(field.required ?? false) && (value == null || value.isEmpty))
              return null;
            if (field.minLength != null &&
                value != null &&
                value.length < field.minLength!) {
              return 'Minimum length is  ${field.minLength}';
            }
            if (field.regex != null &&
                value != null &&
                !RegExp(field.regex!).hasMatch(value)) {
              return field.error ?? 'Invalid';
            }
            return null;
          },
          onSaved: (val) => formData[field.key] = val,
        );

      case 'dropdown':
        return DropdownButtonFormField(
          decoration: InputDecoration(labelText: field.label),
          value: formData[field.key],
          items: field.options
              ?.map(
                  (e) => DropdownMenuItem(value: e, child: Text(e.toString())))
              .toList(),
          onChanged: (val) => formData[field.key] = val,
          validator: (val) =>
              (field.required ?? false) && val == null ? 'Required' : null,
        );

      case 'radio':
        return FormField(
          validator: (val) =>
              (field.required ?? false) && formData[field.key] == null
                  ? 'Required'
                  : null,
          builder: (state) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...field.options!.map((opt) => RadioListTile(
                    title: Text(opt.toString()),
                    value: opt,
                    groupValue: formData[field.key],
                    onChanged: (val) {
                      formData[field.key] = val;
                      onChanged?.call();
                      state.didChange(val);
                    },
                  )),
              if (state.hasError)
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                  child: Text(state.errorText!,
                      style: TextStyle(color: Colors.red)),
                ),
            ],
          ),
        );

      case 'checkbox':
        return FormField(
          validator: (val) =>
              (field.required ?? false) && !(formData[field.key] ?? false)
                  ? 'Required'
                  : null,
          builder: (state) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CheckboxListTile(
                title: Text(field.label),
                value: formData[field.key] ?? false,
                onChanged: (val) {
                  formData[field.key] = val;
                  onChanged?.call();
                  state.didChange(val);
                },
              ),
              if (state.hasError)
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                  child: Text(state.errorText!,
                      style: TextStyle(color: Colors.red)),
                ),
            ],
          ),
        );

      case 'switch':
        return FormField(
          validator: (val) =>
              (field.required ?? false) && !(formData[field.key] ?? false)
                  ? 'Required'
                  : null,
          builder: (state) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                title: Text(field.label),
                value: formData[field.key] ?? false,
                onChanged: (val) {
                  formData[field.key] = val;
                  onChanged?.call();
                  state.didChange(val);
                },
              ),
              if (state.hasError)
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                  child: Text(state.errorText!,
                      style: TextStyle(color: Colors.red)),
                ),
            ],
          ),
        );

      case 'slider':
        return FormField<double>(
          validator: (val) =>
              (field.required ?? false) && (formData[field.key] == null)
                  ? 'Required'
                  : null,
          initialValue: (formData[field.key] ?? field.min ?? 0.0).toDouble(),
          builder: (state) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(field.label),
              Slider(
                value: (formData[field.key] ?? field.min ?? 0.0).toDouble(),
                min: field.min ?? 0.0,
                max: field.max ?? 100.0,
                divisions: field.divisions,
                label: '${formData[field.key] ?? 0}',
                onChanged: (val) {
                  formData[field.key] = val;
                  onChanged?.call();
                  state.didChange(val);
                },
              ),
              if (state.hasError)
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                  child: Text(state.errorText!,
                      style: TextStyle(color: Colors.red)),
                ),
            ],
          ),
        );

      case 'date':
      case 'time':
        DateTime? minDate =
            field.minDate != null ? DateTime.tryParse(field.minDate!) : null;
        DateTime? maxDate =
            field.maxDate != null ? DateTime.tryParse(field.maxDate!) : null;
        return TextFormField(
          controller: TextEditingController(text: formData[field.key] ?? ''),
          readOnly: true,
          onTap: () async {
            var picked = field.type == 'date'
                ? await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: minDate ?? DateTime(2000),
                    lastDate: maxDate ?? DateTime(2100),
                  )
                : await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
            if (picked != null) {
              formData[field.key] = field.type == 'date'
                  ? (picked as DateTime).toIso8601String().split('T')[0]
                  : (picked as TimeOfDay).format(context);
              onChanged?.call();
            }
          },
          decoration: InputDecoration(labelText: field.label),
          validator: (value) {
            if ((field.required ?? false) && (value == null || value.isEmpty))
              return 'Required';
            return null;
          },
        );

      case 'signature':
        return _SignatureField(
          label: field.label,
          formData: formData,
          fieldKey: field.key,
          onChanged: onChanged,
        );

      case 'rating':
        final int rating = formData[field.key] ?? 0;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(field.label),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                return IconButton(
                  icon: Icon(
                    Icons.star,
                    color: rating >= starIndex ? Colors.amber : Colors.grey,
                  ),
                  onPressed: () {
                    formData[field.key] = starIndex;
                    onChanged?.call();
                  },
                );
              }),
            ),
          ],
        );

      default:
        return const SizedBox();
    }
  }

  static TextInputType _getKeyboardType(String? inputType) {
    switch (inputType) {
      case 'email':
        return TextInputType.emailAddress;
      case 'number':
        return TextInputType.number;
      case 'phone':
        return TextInputType.phone;
      case 'url':
        return TextInputType.url;
      case 'multiline':
        return TextInputType.multiline;
      case 'datetime':
        return TextInputType.datetime;
      default:
        return TextInputType.text;
    }
  }
}

class _SignatureField extends StatefulWidget {
  final String label;
  final Map<String, dynamic> formData;
  final String fieldKey;
  final VoidCallback? onChanged;

  const _SignatureField({
    required this.label,
    required this.formData,
    required this.fieldKey,
    this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  State<_SignatureField> createState() => _SignatureFieldState();
}

class _SignatureFieldState extends State<_SignatureField> {
  late SignatureController _controller = SignatureController(
    penStrokeWidth: 10,
    strokeCap: StrokeCap.butt,
    strokeJoin: StrokeJoin.miter,
    penColor: Colors.red,
    exportBackgroundColor: Colors.transparent,
    exportPenColor: Colors.black,
    onDrawStart: () => log('onDrawStart called!'),
    onDrawEnd: () => log('onDrawEnd called!'),
  );
  @override
  void initState() {
    super.initState();
    _controller
      ..addListener(() => log('Value changed'))
      ..onDrawEnd = () => setState(
            () {
              // setState for build to update value of "empty label" in gui
            },
          );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveSignature() async {
    if (_controller.isNotEmpty) {
      final image = await _controller.toPngBytes();
      if (image != null) {
        widget.formData[widget.fieldKey] = image;
        widget.onChanged?.call();
        setState(() {});
      }
    }
  }

  void _clearSignature() {
    _controller.clear();
    widget.formData[widget.fieldKey] = null;
    widget.onChanged?.call();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final hasSignature = widget.formData[widget.fieldKey] != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label),
        const SizedBox(height: 8),
        Container(
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Signature(
            controller: _controller,
            backgroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ElevatedButton(
              onPressed: _controller.isNotEmpty ? _saveSignature : null,
              child: const Text('Save'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _controller.isNotEmpty || hasSignature
                  ? _clearSignature
                  : null,
              child: const Text('Clear'),
            ),
            if (hasSignature) ...[
              const SizedBox(width: 8),
              const Icon(Icons.check, color: Colors.green),
              const Text('Saved'),
            ]
          ],
        ),
      ],
    );
  }
}
