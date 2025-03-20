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
      final meter1 = meterProvider.getMeter(name: 'test-meter', attributes: {'key1': 'value1'}.toAttributes());
      final meter2 = meterProvider.getMeter(name: 'test-meter', attributes: {'key2': 'value2'}.toAttributes());

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
  });
}
