import 'package:flutter/material.dart';
import 'package:dynamic_ui_builder/src/widgets/field_factory.dart';
import 'models/form_field_config.dart';

class DynamicUiBuilder extends StatefulWidget {
  final List<Map<String, dynamic>> jsonConfig;
  final void Function(Map<String, dynamic> result)? onSubmit;

  const DynamicUiBuilder(
      {super.key, required this.jsonConfig, this.onSubmit});

  @override
  State<DynamicUiBuilder> createState() => _DynamicUiBuilderState();
}

class _DynamicUiBuilderState extends State<DynamicUiBuilder> {
  final Map<String, dynamic> formData = {};
  final List<GlobalKey<FormState>> _formKeys = [];
  late final List<List<FormFieldConfig>> steps;
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    final allFields = widget.jsonConfig.map(FormFieldConfig.fromJson).toList();
    final stepGroups = <int, List<FormFieldConfig>>{};
    for (var field in allFields) {
      final step = field.step ?? 0;
      stepGroups.putIfAbsent(step, () => []).add(field);
    }
    final sortedEntries = stepGroups.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    steps = sortedEntries.map((entry) => entry.value).toList();
    for (var _ in steps) {
      _formKeys.add(GlobalKey<FormState>());
    }
    _pageController = PageController();
  }

  void _nextPage() {
    if (_formKeys[_currentPage].currentState!.validate()) {
      _formKeys[_currentPage].currentState!.save();
      if (_currentPage < steps.length - 1) {
        setState(() => _currentPage++);
        _pageController.nextPage(
            duration: const Duration(milliseconds: 300), curve: Curves.ease);
      } else {
        widget.onSubmit?.call(formData);
      }
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
      _pageController.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.ease);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: steps.length,
            itemBuilder: (context, i) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKeys[i],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        steps[i].isNotEmpty &&
                                steps[i][0].title != null &&
                                steps[i][0].title!.isNotEmpty
                            ? steps[i][0].title!
                            : 'Step ${i + 1}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      for (var field in steps[i])
                        FieldFactory.build(field, formData, context,
                            onChanged: () => setState(() {})),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentPage > 0)
                ElevatedButton(
                  onPressed: _previousPage,
                  child: const Text('Previous'),
                ),
              if (_currentPage < steps.length - 1)
                ElevatedButton(
                  onPressed: _nextPage,
                  child: const Text('Next'),
                ),
              if (_currentPage == steps.length - 1)
                ElevatedButton(
                  onPressed: _nextPage,
                  child: const Text('Submit'),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
