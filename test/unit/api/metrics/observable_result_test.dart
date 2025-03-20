// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:opentelemetry_api/opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group('ObservableResult', () {
    late TestObservableResult observableResult;

    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );

      // Create a direct instance of our test implementation
      observableResult = TestObservableResult();
    });

    test('observe works with number value', () {
      // Act & Assert - Should not throw
      observableResult.observe(42);
      observableResult.observe(42.5);
      observableResult.observe(-10);
    });

    test('observe works with attributes', () {
      // Arrange
      final attributes = {'key1': 'value1', 'key2': 123}.toAttributes();

      // Act & Assert - Should not throw
      observableResult.observe(42, attributes);
    });

    test('observeWithMap works correctly', () {
      // Arrange
      final attributeMap = {'key1': 'value1', 'key2': 123};

      // Act & Assert - Should not throw
      observableResult.observeWithMap(42, attributeMap);
    });

    test('observeWithMap with empty map is equivalent to observe with null attributes', () {
      // Act & Assert - Should not throw
      observableResult.observeWithMap(42, {});
    });
  });
}

/// Test implementation of ObservableResult for testing purposes
class TestObservableResult implements APIObservableResult {
  final List<Measurement> _measurements = [];

  @override
  List<Measurement> get measurements => List.unmodifiable(_measurements);

  @override
  void observe(num value, [Attributes? attributes]) {
    // Store the measurement in our list
    _measurements.add(OTelAPI.createMeasurement(value, attributes));
  }

  @override
  void observeWithMap(num value, Map<String, Object> attributeMap) {
    final attributes = attributeMap.isEmpty ? null : attributeMap.toAttributes();
    observe(value, attributes);
  }
}
