// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:opentelemetry_api/src/api/baggage/baggage_entry.dart';
import 'package:opentelemetry_api/src/api/otel_api.dart';
import 'package:opentelemetry_api/src/api/baggage/baggage.dart';
import 'package:test/test.dart';

void main() {
  group('Baggage', () {
    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );
    });

    group('negative tests', () {
      test('handles null entries map by creating empty baggage', () {
        final baggage = OTelAPI.baggage(null);
        expect(baggage.getAllEntries(), isEmpty);
      });

      test('validates key format', () {
        expect(
              () => OTelAPI.baggage({'': OTelAPI.baggageEntry('value', null)}),
          throwsArgumentError,
        );
      });

      test('fromJson handles malformed JSON input', () {
        final malformedJson = {
          'key1': [], // Array instead of map
          'key2': 42, // Number instead of map
          'key3': true, // Boolean instead of map
          'key4': null, // Null instead of map
        };
        final baggage = Baggage.fromJson(malformedJson);
        expect(baggage.getAllEntries(), isEmpty);
      });

      test('rejects modification of returned entries map', () {
        final baggage = OTelAPI.baggage({
          'key1': OTelAPI.baggageEntry('value1', null),
        });
        final entries = baggage.getAllEntries();
        expect(
              () => entries['new_key'] = OTelAPI.baggageEntry('value', null),
          throwsUnsupportedError,
        );
      });

      test('handles extremely long keys and values', () {
        final longString = 'a' * 10000;
        final baggage = OTelAPI.baggage({
          longString: OTelAPI.baggageEntry(longString, longString),
        });
        expect(baggage[longString], equals(longString));
      });

      test('validates value is not empty', () {
        expect(
              () => OTelAPI.baggage({'key': OTelAPI.baggageEntry('', null)}),
          throwsArgumentError,
        );
      });

      test('rejects modification through original map', () {
        final originalMap = <String, BaggageEntry>{
          'key1': OTelAPI.baggageEntry('value1', null),
        };
        final baggage = OTelAPI.baggage(originalMap);

        // Modify original map
        originalMap['key2'] = OTelAPI.baggageEntry('value2', null);

        // Verify baggage is unchanged
        expect(baggage
            .getAllEntries()
            .length, equals(1));
        expect(baggage.getEntry('key2'), isNull);
      });

      test('prevents cross-contamination between instances', () {
        final map1 = {'key1': OTelAPI.baggageEntry('value1', null)};
        final map2 = {'key2': OTelAPI.baggageEntry('value2', null)};

        final baggage1 = OTelAPI.baggage(map1);
        final baggage2 = OTelAPI.baggage(map2);

        map1['key3'] = OTelAPI.baggageEntry('value3', null);
        map2['key3'] = OTelAPI.baggageEntry('value3', null);

        expect(baggage1.getEntry('key3'), isNull);
        expect(baggage2.getEntry('key3'), isNull);
      });

      group('JSON handling', () {
        test('handles deeply nested malformed JSON', () {
          final nestedJson = {
            'key1': {
              'value': {'nested': 'too deep'},
            },
            'key2': {'value': 'valid', 'metadata': 'valid'}
          };
          final baggage = Baggage.fromJson(nestedJson);
          expect(baggage.getEntry('key1'), isNull);
          expect(baggage
              .getEntry('key2')
              ?.value, equals('valid'));
        });

        test('handles circular references safely', () {
          final map1 = <String, dynamic>{};
          final map2 = <String, dynamic>{'ref': map1};
          map1['ref'] = map2;

          final json = {
            'key1': map1,
            'key2': {'value': 'valid'}
          };

          final baggage = Baggage.fromJson(json);
          expect(baggage.getEntry('key1'), isNull);
          expect(baggage
              .getEntry('key2')
              ?.value, equals('valid'));
        });

        test('handles invalid types in metadata', () {
          final json = {
            'key1': {'value': 'valid', 'metadata': {'invalid': 'type'}},
            'key2': {'value': 'valid', 'metadata': 42},
            'key3': {'value': 'valid', 'metadata': 'valid'}
          };

          final baggage = Baggage.fromJson(json);
          expect(baggage.getEntry('key1'), isNull);
          expect(baggage.getEntry('key2'), isNull);
          expect(baggage
              .getEntry('key3')
              ?.value, equals('valid'));
          expect(baggage
              .getEntry('key3')
              ?.metadata, equals('valid'));
        });
      });

      test('put with same value creates new instance', () {
        final originalBaggage = OTelAPI.baggage({
          'key1': OTelAPI.baggageEntry('value1', 'meta1'),
        });

        final newBaggage = originalBaggage.copyWith('key1', 'value1', 'meta1');
        expect(identical(originalBaggage, newBaggage), isFalse);
      });
    });

    test('equality checks entries without considering order', () {
      final entries1 = {
        'key1': OTelAPI.baggageEntry('value1', 'meta1'),
        'key2': OTelAPI.baggageEntry('value2', null),
      };
      final entries2 = {
        'key2': OTelAPI.baggageEntry('value2', null),
        'key1': OTelAPI.baggageEntry('value1', 'meta1'),
      };
      final entries3 = {
        'key1': OTelAPI.baggageEntry('different', 'meta1'),
        'key2': OTelAPI.baggageEntry('value2', null),
      };

      final baggage1 = OTelAPI.baggage(entries1);
      final baggage2 = OTelAPI.baggage(entries2);
      final baggage3 = OTelAPI.baggage(entries3);

      expect(baggage1, equals(baggage2));
      expect(baggage1, isNot(equals(baggage3)));
      expect(baggage1.hashCode == baggage2.hashCode, isTrue);
      expect(baggage1.hashCode == baggage3.hashCode, isFalse);
    });
  });
}
