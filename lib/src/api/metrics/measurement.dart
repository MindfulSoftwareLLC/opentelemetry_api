// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import '../common/attributes.dart';
import '../otel_api.dart';

/// Represents a data point reported via the metrics API.
///
/// A Measurement includes a value and optional attributes.
class Measurement {
  /// The value of the measurement.
  final num value;

  /// Attributes associated with this measurement.
  final Attributes attributes;

  /// Creates a new Measurement with the specified value and attributes.
  ///
  /// [value] The value of the measurement.
  /// [attributes] Optional attributes to associate with the measurement.
  /// If null, empty attributes will be used.
  Measurement(this.value, [Attributes? attributes])
      : attributes = attributes ?? OTelAPI.attributes();

  /// Creates a new Measurement from a value and a map of attribute key-value pairs.
  ///
  /// [value] The value of the measurement.
  /// [attributeMap] A map of attribute key-value pairs.
  factory Measurement.fromMap(num value, Map<String, Object> attributeMap) {
    return Measurement(value, attributeMap.isEmpty
        ? OTelAPI.attributes()
        : attributeMap.toAttributes());
  }

  @override
  String toString() {
    return 'Measurement{value: $value, attributes: $attributes}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Measurement &&
          runtimeType == other.runtimeType &&
          value == other.value &&
          attributes == other.attributes;

  @override
  int get hashCode => value.hashCode ^ attributes.hashCode;
}
