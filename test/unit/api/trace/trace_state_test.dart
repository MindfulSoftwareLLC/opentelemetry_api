// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:opentelemetry_api/src/api/otel_api.dart';
import 'package:test/test.dart';

void main() {
  group('TraceState', () {
    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );
    });

    test('creates empty trace state', () {
      final traceState = OTelAPI.traceState(null);
      expect(traceState.isEmpty, isTrue);
      expect(traceState.entries, isEmpty);
    });

    test('gets value for key', () {
      final traceState = OTelAPI.traceState({
        'vendora': 'value1',
        'vendorb': 'value2',
      });

      expect(traceState.get('vendora'), equals('value1'));
      expect(traceState.get('vendorb'), equals('value2'));
      expect(traceState.get('unknown'), isNull);
    });

    test('adds new key/value pair', () {
      final traceState = OTelAPI.traceState({'vendora': 'value1'});
      final updatedState = traceState.put('vendorb', 'value2');

      expect(updatedState.get('vendora'), equals('value1'));
      expect(updatedState.get('vendorb'), equals('value2'));
      expect(identical(traceState, updatedState), isFalse);
    });

    test('updates existing value', () {
      final traceState = OTelAPI.traceState({'vendora': 'value1'});
      final updatedState = traceState.put('vendora', 'newvalue');

      expect(updatedState.get('vendora'), equals('newvalue'));
      expect(identical(traceState, updatedState), isFalse);
    });

    test('deletes key/value pair', () {
      final traceState = OTelAPI.traceState({
        'vendora': 'value1',
        'vendorb': 'value2',
      });
      final updatedState = traceState.remove('vendora');

      expect(updatedState.get('vendora'), isNull);
      expect(updatedState.get('vendorb'), equals('value2'));
      expect(identical(traceState, updatedState), isFalse);
    });

    test('handles OpenTelemetry vendor-specific format', () {
      final traceState = OTelAPI.traceState({
        'ot': 'p:8;r:62'
      });

      expect(traceState.get('ot'), equals('p:8;r:62'));
    });

    test('supports tenant format', () {
      final traceState = OTelAPI.traceState({'tenant@vendor': 'value'});
      expect(traceState.get('tenant@vendor'), equals('value'));
    });

    test('maintains immutability', () {
      final traceState = OTelAPI.traceState({'key': 'value'});
      final updatedState = traceState.put('newkey', 'newvalue');

      expect(traceState.get('newkey'), isNull);
      expect(updatedState.get('newkey'), equals('newvalue'));
    });

    test('handles empty entries correctly', () {
      final traceState = OTelAPI.traceState({});
      expect(traceState.isEmpty, isTrue);

      final updatedState = traceState.put('key', 'value');
      expect(updatedState.isEmpty, isFalse);
      expect(updatedState.get('key'), equals('value'));
    });
  });
}
