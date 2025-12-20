import 'package:flutter/widgets.dart';

/// Mixin for tracking form state changes
mixin FormStateTrackerMixin<T extends StatefulWidget> on State<T> {
  Map<String, dynamic>? _initialFormState;
  Map<String, dynamic>? _currentFormState;

  /// Initialize form state with initial values
  void initializeFormState(Map<String, dynamic> initialState) {
    _initialFormState = Map.from(initialState);
    _currentFormState = Map.from(initialState);
  }

  /// Update a specific form field value
  void updateFormState(String key, dynamic value) {
    _currentFormState ??= {};
    _currentFormState![key] = value;
  }

  /// Check if form has unsaved changes
  bool hasUnsavedChanges() {
    if (_initialFormState == null || _currentFormState == null) {
      return false;
    }
    return _initialFormState.toString() != _currentFormState.toString();
  }

  /// Reset form state to initial values
  void resetFormState() {
    _currentFormState = _initialFormState != null
        ? Map.from(_initialFormState!)
        : null;
  }

  /// Clear form state tracking
  void clearFormState() {
    _initialFormState = null;
    _currentFormState = null;
  }
}
