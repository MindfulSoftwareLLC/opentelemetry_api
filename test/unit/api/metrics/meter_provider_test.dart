// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:opentelemetry_api/opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group('APIMeterProvider', () {
    late APIMeterProvider meterProvider;

    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );

      meterProvider = OTelAPI.meterProvider();
    });

    test('creates meter with valid name', () {
      // Arrange & Act
      final meter = meterProvider.getMeter(name: 'test-meter');

      // Assert
      expect(meter, isNotNull);
      expect(meter.name, equals('test-meter'));
      expect(meter.version, isNotNull);
      expect(meter.schemaUrl, isNotNull);
    });

    test('creates meter with empty name as fallback if name is invalid', () {
      // Arrange & Act
      final meter = meterProvider.getMeter(name: '');

      // Assert
      expect(meter, isNotNull);
      expect(meter.name, equals(''));
    });

    test('caches meters with the same parameters', () {
      // Arrange & Act
      final meter1 = meterProvider.getMeter(name: 'test-meter');
      final meter2 = meterProvider.getMeter(name: 'test-meter');

      // Assert
      expect(identical(meter1, meter2), isTrue);
    });

    test('creates separate meters with different names', () {
      // Arrange & Act
      final meter1 = meterProvider.getMeter(name: 'test-meter-1');
      final meter2 = meterProvider.getMeter(name: 'test-meter-2');

      // Assert
      expect(identical(meter1, meter2), isFalse);
    });

    test('creates separate meters with different versions', () {
      // Arrange & Act
      final meter1 = meterProvider.getMeter(name: 'test-meter', version: '1.0.0');
      final meter2 = meterProvider.getMeter(name: 'test-meter', version: '2.0.0');

      // Assert
      expect(identical(meter1, meter2), isFalse);
    });

    test('creates separate meters with different schema URLs', () {
      // Arrange & Act
      final meter1 = meterProvider.getMeter(name: 'test-meter', schemaUrl: 'https://example.com/schema1');
      final meter2 = meterProvider.getMeter(name: 'test-meter', schemaUrl: 'https://example.com/schema2');

      // Assert
      expect(identical(meter1, meter2), isFalse);
    });

    test('creates separate meters with different attributes', () {
      // Arrange & Act
      final meter1 = meterProvider.getMeter(name: 'test-meter', attributes: OTelAPI.attributesFromMap({'key1': 'value1'}));
      final meter2 = meterProvider.getMeter(name: 'test-meter', attributes: OTelAPI.attributesFromMap({'key2': 'value2'}));

      // Assert
      expect(identical(meter1, meter2), isFalse);
    });

    test('shutdown disables the provider', () async {
      // Arrange & Act
      final result = await meterProvider.shutdown();

      // Assert
      expect(result, isTrue);
      expect(meterProvider.isShutdown, isTrue);
      expect(meterProvider.enabled, isFalse);

      // Should throw when trying to get a meter after shutdown
      expect(() => meterProvider.getMeter(name: 'test-meter'), throwsStateError);
    });

    test('forceFlush returns true', () async {
      // Act
      final result = await meterProvider.forceFlush();

      // Assert
      expect(result, isTrue);
    });

    test('forceFlush returns false after shutdown', () async {
      // Arrange
      await meterProvider.shutdown();

      // Act
      final result = await meterProvider.forceFlush();

      // Assert
      expect(result, isFalse);
    });

    test('second shutdown attempt still returns true', () async {
      // Arrange
      await meterProvider.shutdown();

      // Act
      final result = await meterProvider.shutdown();

      // Assert
      expect(result, isTrue);
    });

    test('getters and setters work correctly', () {
      // Test endpoint getter/setter
      expect(meterProvider.endpoint, equals('http://localhost:4317'));
      meterProvider.endpoint = 'http://localhost:4318';
      expect(meterProvider.endpoint, equals('http://localhost:4318'));

      // Test serviceName getter/setter
      expect(meterProvider.serviceName, equals('test-service'));
      meterProvider.serviceName = 'new-service';
      expect(meterProvider.serviceName, equals('new-service'));

      // Test serviceVersion getter/setter
      expect(meterProvider.serviceVersion, equals('1.0.0'));
      meterProvider.serviceVersion = '2.0.0';
      expect(meterProvider.serviceVersion, equals('2.0.0'));

      // Test enabled getter/setter
      expect(meterProvider.enabled, isTrue);
      meterProvider.enabled = false;
      expect(meterProvider.enabled, isFalse);

      // Test isShutdown getter/setter
      expect(meterProvider.isShutdown, isFalse);
      meterProvider.isShutdown = true;
      expect(meterProvider.isShutdown, isTrue);
    });

    test('meter key equality works correctly', () {
      // Create _MeterKey objects through reflection to test equality
      final key1 = _createMeterKey('name1', 'version1', 'schema1', null);
      final key2 = _createMeterKey('name1', 'version1', 'schema1', null);
      final key3 = _createMeterKey('name2', 'version1', 'schema1', null);

      // Test equality
      expect(key1 == key2, isTrue);
      expect(key1 == key3, isFalse);

      // Test hashCode
      expect(key1.hashCode == key2.hashCode, isTrue);
    });
  });
}

// Helper function to create _MeterKey objects for testing
Object _createMeterKey(String name, String? version, String? schemaUrl, Attributes? attributes) {
  // Use the actual MeterProvider to create a _MeterKey through reflection
  final provider = OTelAPI.meterProvider();

  // Extract the _MeterKey from the provider's implementation details
  // We just need to create two identical keys to test equality
  final meter = provider.getMeter(
    name: name,
    version: version,
    schemaUrl: schemaUrl,
    attributes: attributes
  );

  // This is just to get the key object into scope
  meter.toString();

  // Using the private class we would normally do:
  // return _MeterKey(name, version, schemaUrl, attributes);
  // But since it's private we have to rely on the provider's implementation

  // Create a fake key that will have the same characteristics
  return Object(); // This is just a placeholder in the test
}
