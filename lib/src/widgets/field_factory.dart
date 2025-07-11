import 'package:flutter/material.dart';
import '../models/form_field_config.dart';
import 'package:signature/signature.dart';
import 'dart:developer';
import 'package:image_picker/image_picker.dart'; // Add image_picker to pubspec.yaml
import 'package:file_picker/file_picker.dart'; // Add file_picker to pubspec.yaml
import 'package:flutter_pdfview/flutter_pdfview.dart'; // Add flutter_pdfview to pubspec.yaml
import 'dart:io';
import 'package:path_provider/path_provider.dart'; // Ensure this is available
import 'package:http/http.dart' as http;

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

      case 'image_picker':
        return _ImagePickerField(
          label: field.label,
          formData: formData,
          fieldKey: field.key,
          onChanged: onChanged,
        );

      case 'file_picker':
        return _FilePickerField(
          label: field.label,
          formData: formData,
          fieldKey: field.key,
          onChanged: onChanged,
        );

      case 'pdf_view':
        return _PDFViewField(
          label: field.label,
          formData: formData,
          fieldKey: field.key,
          onChanged: onChanged,
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

class _ImagePickerField extends StatefulWidget {
  final String label;
  final Map<String, dynamic> formData;
  final String fieldKey;
  final VoidCallback? onChanged;

  const _ImagePickerField({
    required this.label,
    required this.formData,
    required this.fieldKey,
    this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  State<_ImagePickerField> createState() => _ImagePickerFieldState();
}

class _ImagePickerFieldState extends State<_ImagePickerField> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        widget.formData[widget.fieldKey] = pickedFile.path;
        widget.onChanged?.call();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = widget.formData[widget.fieldKey];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label),
        const SizedBox(height: 8),
        if (imagePath != null) Image.file(File(imagePath), height: 120),
        ElevatedButton(
          onPressed: _pickImage,
          child: const Text('Pick Image'),
        ),
      ],
    );
  }
}

class _FilePickerField extends StatefulWidget {
  final String label;
  final Map<String, dynamic> formData;
  final String fieldKey;
  final VoidCallback? onChanged;

  const _FilePickerField({
    required this.label,
    required this.formData,
    required this.fieldKey,
    this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  State<_FilePickerField> createState() => _FilePickerFieldState();
}

class _FilePickerFieldState extends State<_FilePickerField> {
  String? _fileName;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      setState(() {
        _fileName = result.files.single.name;
        widget.formData[widget.fieldKey] = result.files.single.path;
        widget.onChanged?.call();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filePath = widget.formData[widget.fieldKey];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(widget.label),
        const SizedBox(height: 8),
        if (filePath != null)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              'Selected: ${_fileName ?? filePath.split('/').last}',
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ElevatedButton(
          onPressed: _pickFile,
          child: const Text('Pick File'),
        ),
      ],
    );
  }
}

class _PDFViewField extends StatefulWidget {
  final String label;
  final Map<String, dynamic> formData;
  final String fieldKey;
  final VoidCallback? onChanged;

  const _PDFViewField({
    required this.label,
    required this.formData,
    required this.fieldKey,
    this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  State<_PDFViewField> createState() => _PDFViewFieldState();
}

class _PDFViewFieldState extends State<_PDFViewField> {
  String? _fileName;
  var filePath;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initPdfSource();
  }

  Future<void> _initPdfSource() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final url = widget.formData[widget.fieldKey + '_url'];
    final asset = widget.formData[widget.fieldKey + '_asset'];
    if (url != null && url is String && url.isNotEmpty) {
      try {
        filePath = await _downloadPdf(url);
        _fileName = url.split('/').last;
      } catch (e) {
        _error = 'Failed to load PDF from URL.';
      }
    } else if (asset != null && asset is String && asset.isNotEmpty) {
      filePath = asset;
      _fileName = asset.split('/').last;
    } else {
      filePath = widget.formData[widget.fieldKey];
      if (filePath != null) {
        _fileName = filePath.split('/').last;
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<String> _downloadPdf(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      // Use getTemporaryDirectory from path_provider
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/${url.split('/').last}');
      await file.writeAsBytes(response.bodyBytes);
      return file.path;
    } else {
      throw Exception('Failed to download PDF');
    }
  }

  Future<void> _pickPdfFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      setState(() {
        filePath = result.files.single.path;
        _fileName = result.files.single.name;
        widget.formData[widget.fieldKey] = result.files.single.path;
        widget.onChanged?.call();
      });
    }
  }

  void _clearPdfFile() {
    setState(() {
      filePath = null;
      _fileName = null;
      widget.formData[widget.fieldKey] = null;
      widget.formData[widget.fieldKey + '_url'] = null;
      widget.formData[widget.fieldKey + '_asset'] = null;
      widget.onChanged?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Always re-check source in build in case formData changes
    final url = widget.formData[widget.fieldKey + '_url'];
    final asset = widget.formData[widget.fieldKey + '_asset'];
    if ((url != null && url is String && url.isNotEmpty) ||
        (asset != null && asset is String && asset.isNotEmpty)) {
      // If URL or asset, ensure filePath is set
      if (filePath == null) {
        _initPdfSource();
      }
    } else {
      filePath = widget.formData[widget.fieldKey];
      if (filePath != null) {
        _fileName = filePath.split('/').last;
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Row(
          children: [
            Text(widget.label),
            const SizedBox(width: 10),
            if (filePath == null && !_isLoading && widget.fieldKey == "pdf_file")
              ElevatedButton(
                onPressed: _pickPdfFile,
                child: const Text('Pick File'),
              ),
            if (filePath != null)
              ElevatedButton(
                onPressed: _clearPdfFile,
                child: const Text('Clear PDF'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (_isLoading) const CircularProgressIndicator(),
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.red)),
        if (filePath != null && _fileName != null && !_isLoading)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              'Selected: \\${_fileName}',
              softWrap: false,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        const SizedBox(height: 8),
        if (filePath != null &&
            filePath.toString().endsWith('.pdf') &&
            !_isLoading)
          SizedBox(
            height: 500,
            child: PDFView(
              filePath: filePath,
            ),
          )
        else if (!_isLoading && filePath == null)
          const Text('No PDF selected.'),
      ],
    );
  }
}
