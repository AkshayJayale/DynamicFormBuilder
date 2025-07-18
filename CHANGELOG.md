## 1.0.3+11
### Added
- FilterChipField: Added support for filter fields with both independent (main category) and dependent (subcategory) logic, using FilterChip UI and optionsMap for dynamic options.
- FormDataStore: Introduced a singleton class to manage form data globally, replacing local formData maps and enabling persistent, app-wide form state.

---

## 1.0.2+6
### Fixed
- Added missing `http` dependency to `pubspec.yaml` to resolve import error.
- Removed unused `_imageFile` field from `_ImagePickerFieldState` class.
- Fixed package validation issues for publication.

---

## 1.0.2
### Added
- Field-level `required` flag for all field types (text, dropdown, radio, checkbox, switch, slider, date, time, signature, rating).
- Support for `minLength`, `maxLength`, `minLines`, `maxLines`, and `regex` validation for text fields.
- Support for `minDate` and `maxDate` for date fields.
- Signature capture widget (browser and mobile compatible).
- Example for single field validation using `FieldFactory`.
- Improved validation logic: minLength and regex only validated if required or not empty.
- All field types now support required/optional logic from JSON config.

### Changed
- Refactored validators to respect the `required` flag and skip validation if not required and empty.
- Example app now includes both a dynamic form and a single field validation tab.

### Fixed
- Regex and length validation bugs for optional fields.

---

## 1.0.1

* Initial release.
