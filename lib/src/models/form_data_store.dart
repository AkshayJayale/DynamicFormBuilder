class FormDataStore {
  static final FormDataStore _instance = FormDataStore._internal();
  factory FormDataStore() => _instance;
  FormDataStore._internal();

  static FormDataStore get instance => _instance;

  final Map<String, dynamic> data = {};

  void clear() => data.clear();
}
