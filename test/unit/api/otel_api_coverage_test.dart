// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:opentelemetry_api/opentelemetry_api.dart';
import 'package:test/test.dart';
import 'dart:typed_data';

void main() {
  group('OTelAPI - Additional Coverage Tests', () {
    late OTelFactory originalFactory;

    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );

      // Store the original factory
      originalFactory = OTelFactory.otelFactory!;
    });

    tearDown(() {
      // Restore the original factory
      OTelFactory.otelFactory = originalFactory;
    });

    test('initialize throws when called twice', () {
      // Already initialized in setUp, so calling again should throw
      expect(() {
        OTelAPI.initialize(
          endpoint: 'http://localhost:4317',
          serviceName: 'test-service',
          serviceVersion: '1.0.0',
        );
      }, throwsA(isA<StateError>()));
    });

    test('initialize throws with empty endpoint', () {
      OTelAPI.reset();
      expect(() {
        OTelAPI.initialize(
          endpoint: '',
          serviceName: 'test-service',
          serviceVersion: '1.0.0',
        );
      }, throwsA(isA<ArgumentError>()));
    });

    test('initialize throws with empty serviceName', () {
      OTelAPI.reset();
      expect(() {
        OTelAPI.initialize(
          endpoint: 'http://localhost:4317',
          serviceName: '',
          serviceVersion: '1.0.0',
        );
      }, throwsA(isA<ArgumentError>()));
    });

    test('initialize throws with empty serviceVersion', () {
      OTelAPI.reset();
      expect(() {
        OTelAPI.initialize(
          endpoint: 'http://localhost:4317',
          serviceName: 'test-service',
          serviceVersion: '',
        );
      }, throwsA(isA<ArgumentError>()));
    });

    test('meterProvider returns existing named provider', () {
      final name = 'test-meter-provider';

      // Create a named provider
      final provider1 = OTelAPI.addMeterProvider(name);

      // Get the same provider by name
      final provider2 = OTelAPI.meterProvider(name);

      expect(provider2, same(provider1));
    });

    test('traceId and spanId from bytes validation', () {
      // Invalid length for trace ID
      final invalidTraceIdBytes = Uint8List.fromList(List.filled(8, 0));
      expect(() {
        OTelAPI.traceIdOf(invalidTraceIdBytes);
      }, throwsArgumentError);

      // Invalid length for span ID
      final invalidSpanIdBytes = Uint8List.fromList(List.filled(16, 0));
      expect(() {
        OTelAPI.spanIdOf(invalidSpanIdBytes);
      }, throwsArgumentError);
    });

    test('traceIdFrom handles invalid hex strings', () {
      expect(() {
        OTelAPI.traceIdFrom('invalid-hex');
      }, throwsFormatException);
    });

    test('spanIdFrom handles invalid hex strings', () {
      expect(() {
        OTelAPI.spanIdFrom('invalid-hex');
      }, throwsFormatException);
    });

    test('baggage creation and manipulation', () {
      // Create entries
      final entry1 = OTelAPI.baggageEntry('value1', 'metadata1');
      final entry2 = OTelAPI.baggageEntry('value2', 'metadata2');

      // Create baggage with entries
      final baggage = OTelAPI.baggage({
        'key1': entry1,
        'key2': entry2,
      });

      // Verify entries
      expect(baggage.getEntry('key1')?.value, equals('value1'));
      expect(baggage.getEntry('key1')?.metadata, equals('metadata1'));
      expect(baggage.getEntry('key2')?.value, equals('value2'));
      expect(baggage.getEntry('key2')?.metadata, equals('metadata2'));
    });

    test('baggageForMap creates baggage from key-value pairs', () {
      final map = {
        'key1': 'value1',
        'key2': 'value2',
      };

      final baggage = OTelAPI.baggageForMap(map);

      expect(baggage.getEntry('key1')?.value, equals('value1'));
      expect(baggage.getEntry('key2')?.value, equals('value2'));
      // No metadata provided
      expect(baggage.getEntry('key1')?.metadata, isNull);
      expect(baggage.getEntry('key2')?.metadata, isNull);
    });

    test('baggageFromJson creates baggage from JSON', () {
      final json = {
        'key1': {'value': 'value1', 'metadata': 'metadata1'},
        'key2': {'value': 'value2', 'metadata': 'metadata2'},
        'key3': {'metadata': 'metadata3'}, // Invalid entry, missing value
        'key4': 'not-an-object' // Invalid entry, not an object
      };

      final baggage = OTelAPI.baggageFromJson(json);

      // Valid entries are included
      expect(baggage.getEntry('key1')?.value, equals('value1'));
      expect(baggage.getEntry('key1')?.metadata, equals('metadata1'));
      expect(baggage.getEntry('key2')?.value, equals('value2'));
      expect(baggage.getEntry('key2')?.metadata, equals('metadata2'));

      // Invalid entries are skipped
      expect(baggage.getEntry('key3'), isNull);
      expect(baggage.getEntry('key4'), isNull);
    });
  });
}
