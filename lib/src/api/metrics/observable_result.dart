// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:opentelemetry_api/opentelemetry_api.dart';

/// Interface for recording observations from observable instruments.
abstract class ObservableResult {
  /// Records a measurement with the given value and attributes.
  void observe(num value, Attributes attributes);

  /// Records a measurement with the given value and attributes as a map.
  void observeWithMap(num value, Map<String, Object> attributes);
}

/// API implementation of ObservableResult
class APIObservableResult implements ObservableResult {
  final List<Measurement> _measurements = [];

  @override
  void observe(num value, Attributes attributes) {
    _measurements.add(Measurement(value, attributes));
  }

  @override
  void observeWithMap(num value, Map<String, Object> attributes) {
    observe(value, attributes.toAttributes());
  }

  /// Get all recorded measurements
  List<Measurement> get measurements => List.unmodifiable(_measurements);
}
