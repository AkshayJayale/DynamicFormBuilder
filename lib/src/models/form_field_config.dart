class FormFieldConfig {
  final String type;
  final String label;
  final String key;
  final String? hint;
  final String? regex;
  final String? error;
  final String? inputType;
  final String? alignment;
  final List<dynamic>? options;
  final int? step;
  final double? min;
  final double? max;
  final int? divisions;
  final String? title;
  final int? maxLength;
  final int? minLength;
  final int? maxLines;
  final int? minLines;
  final String? minDate;
  final String? maxDate;
  final bool? required;
  final String? filterType; // 'independent' or 'dependent'
  final String? dependsOn;
  final Map<String, List<dynamic>>? optionsMap;
  final Map<String, dynamic>? validation;

  FormFieldConfig({
    required this.type,
    required this.label,
    required this.key,
    this.hint,
    this.regex,
    this.error,
    this.inputType,
    this.alignment,
    this.options,
    this.step,
    this.min,
    this.max,
    this.divisions,
    this.title,
    this.maxLength,
    this.minLength,
    this.maxLines,
    this.minLines,
    this.minDate,
    this.maxDate,
    this.required,
    this.filterType,
    this.dependsOn,
    this.optionsMap,
    this.validation,
  });

  factory FormFieldConfig.fromJson(Map<String, dynamic> json) {
    return FormFieldConfig(
      type: json['type'],
      label: json['label'],
      key: json['key'],
      hint: json['hint'],
      regex: json['regex'],
      error: json['error'],
      inputType: json['inputType'],
      alignment: json['alignment'],
      options: json['options'],
      step: json['step'],
      min: (json['min'] as num?)?.toDouble(),
      max: (json['max'] as num?)?.toDouble(),
      divisions: json['divisions'],
      title: json['title'],
      maxLength: json['maxLength'],
      minLength: json['minLength'],
      maxLines: json['maxLines'],
      minLines: json['minLines'],
      minDate: json['minDate'],
      maxDate: json['maxDate'],
      required: json['required'],
      filterType:
          json['type'] == 'filter' ? json['filterType'] ?? json['type'] : null,
      dependsOn: json['dependsOn'],
      optionsMap: json['optionsMap'] != null
          ? Map<String, List<dynamic>>.from((json['optionsMap'] as Map)
              .map((k, v) => MapEntry(k as String, List<dynamic>.from(v))))
          : null,
      validation: json['validation'],
    );
  }
}
