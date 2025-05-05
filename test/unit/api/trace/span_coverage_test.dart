// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:opentelemetry_api/opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group('APISpan - Additional Coverage Tests', () {
    late OTelFactory originalFactory;
    late APITracer? tracer;

    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );

      // Store the original factory
      originalFactory = OTelFactory.otelFactory!;
      tracer = OTelAPI.tracer('test-tracer');
    });

    tearDown(() {
      // Restore the original factory
      OTelFactory.otelFactory = originalFactory;
    });

    test('span toString outputs all properties', () {
      final span = tracer!.createSpan(
        name: 'test-span',
        kind: SpanKind.client,
        attributes: Attributes.of({'key': 'value'}),
      );

      final toString = span.toString();

      // Check that important properties are included in toString output
      expect(toString, contains('test-span'));
      expect(toString, contains('client'));
      expect(toString, contains('key'));
      expect(toString, contains('value'));
    });

    test('span copyWithAttributes updates attributes correctly', () {
      final span = tracer!.createSpan(
        name: 'test-span',
        attributes: Attributes.of({'key1': 'value1'}),
      );

      // Create new attributes
      final newAttributes = Attributes.of({'key2': 'value2'});

      // Copy with new attributes
      span.attributes = span.attributes.copyWithAttributes(newAttributes);

      // Should have both original and new attributes
      expect(span.attributes.getString('key1'), equals('value1'));
      expect(span.attributes.getString('key2'), equals('value2'));
    });

    test('span addEvent with attributes and timestamp', () {
      final span = tracer!.createSpan(name: 'test-span');
      final attributes = Attributes.of({'event.key': 'value'});
      final timestamp = DateTime.now().subtract(const Duration(minutes: 5));

      span.addEvent(OTelAPI.spanEvent('test-event', attributes, timestamp));

      final events = span.spanEvents;
      expect(events, hasLength(1));
      expect(events![0].name, equals('test-event'));
      expect(events[0].attributes!.getString('event.key'), equals('value'));
      expect(events[0].timestamp, equals(timestamp));
    });

    test('span equality and hashCode', () {
      // Create two spans with the same context
      final traceId = OTelAPI.traceId();
      final spanId = OTelAPI.spanId();
      final context = OTelAPI.spanContext(
        traceId: traceId,
        spanId: spanId,
      );

      final span1 = tracer!.createSpan(
        name: 'test-span',
        spanContext: context,
      );

      final span2 = tracer!.createSpan(
        name: 'test-span',
        spanContext: context,
      );

      // Different span with different context
      final span3 = tracer!.createSpan(name: 'other-span');

      // Spans with same context should be equal
      expect(span1, equals(span2));
      expect(span1.hashCode, equals(span2.hashCode));

      // Different spans should not be equal
      expect(span1, isNot(equals(span3)));
      expect(span1.hashCode, isNot(equals(span3.hashCode)));
    });

    test('span end with endTime parameter', () {
      final startTime = DateTime.now().subtract(const Duration(minutes: 1));
      final endTime = DateTime.now();

      final span = tracer!.createSpan(
        name: 'test-span',
        startTime: startTime,
      );

      span.end(endTime: endTime);

      expect(span.startTime, equals(startTime));
      expect(span.endTime, equals(endTime));
      expect(span.isRecording, isFalse);
    });

    test('span removeAttribute removes attribute correctly', () {
      final span = tracer!.createSpan(
        name: 'test-span',
        attributes: Attributes.of({
          'key1': 'value1',
          'key2': 'value2',
        }),
      );

      // Initially has both attributes
      expect(span.attributes.getString('key1'), equals('value1'));
      expect(span.attributes.getString('key2'), equals('value2'));

      // Remove one attribute
      span.attributes = span.attributes.copyWithout('key1');

      // Now should only have key2
      expect(span.attributes.getString('key1'), isNull);
      expect(span.attributes.getString('key2'), equals('value2'));
    });

    test('span recordException with all options', () {
      final span = tracer!.createSpan(name: 'test-span');
      final exception = Exception('Test error');
      final attributes = Attributes.of({'custom': 'attribute'});

      span.recordException(
        exception,
        attributes: attributes,
        escaped: true,
        stackTrace: StackTrace.current,
      );

      final events = span.spanEvents;
      expect(events, hasLength(1));

      final eventAttrs = events![0].attributes!.toMap();
      expect(eventAttrs['exception.type']?.value, contains('Exception'));
      expect(eventAttrs['exception.message']?.value, contains('Test error'));
      expect(eventAttrs['exception.stacktrace']?.value, isNotNull);
      expect(eventAttrs['exception.escaped']?.value, isTrue);
      expect(eventAttrs['custom']?.value, equals('attribute'));
    });
  });
}
