// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:opentelemetry_api/opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group('SpanContext', () {
    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );
    });

    final traceIdBytes = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16];
    final spanIdBytes = [1, 2, 3, 4, 5, 6, 7, 8];
    late TraceId traceId;
    late SpanId spanId;
    
    setUp(() {
      traceId = OTelAPI.traceId(bytes: traceIdBytes);
      spanId = OTelAPI.spanId(bytes: spanIdBytes);
    });

    test('create basic span context', () {
      final spanContext = OTelAPI.spanContext(
        traceId: traceId,
        spanId: spanId,
        traceFlags: TraceFlags.none,
        traceState: TraceState.empty(),
        isRemote: false,
      );

      expect(spanContext.traceId, equals(traceId));
      expect(spanContext.spanId, equals(spanId));
      expect(spanContext.traceFlags, equals(TraceFlags.none));
      expect(spanContext.traceState, equals(TraceState.empty()));
      expect(spanContext.isRemote, isFalse);
      expect(spanContext.isValid, isTrue);
    });

    test('create remote span context', () {
      final spanContext = OTelAPI.spanContext(
        traceId: traceId,
        spanId: spanId,
        traceFlags: TraceFlags.sampled,
        traceState: TraceState.empty(),
        isRemote: true,
      );

      expect(spanContext.isRemote, isTrue);
      expect(spanContext.isSampled, isTrue);
    });

    test('invalid span context with invalid trace ID', () {
      final invalidTraceId = TraceId.invalid;
      final spanContext = OTelAPI.spanContext(
        traceId: invalidTraceId,
        spanId: spanId,
        traceFlags: TraceFlags.none,
        traceState: TraceState.empty(),
        isRemote: false,
      );

      expect(spanContext.isValid, isFalse);
    });

    test('invalid span context with invalid span ID', () {
      final invalidSpanId = SpanId.invalid;
      final spanContext = OTelAPI.spanContext(
        traceId: traceId,
        spanId: invalidSpanId,
        traceFlags: TraceFlags.none,
        traceState: TraceState.empty(),
        isRemote: false,
      );

      expect(spanContext.isValid, isFalse);
    });

    test('create from hex strings', () {
      final traceIdHex = '0102030405060708090a0b0c0d0e0f10';
      final spanIdHex = '0102030405060708';
      
      final spanContext = SpanContext.fromString(
        traceIdHex: traceIdHex,
        spanIdHex: spanIdHex,
        traceFlagsHex: '01', // sampled flag
        traceStateHeader: 'vendor1=value1,vendor2=value2',
        isRemote: true,
      );

      expect(spanContext.traceId.toString(), equals(traceIdHex));
      expect(spanContext.spanId.toString(), equals(spanIdHex));
      expect(spanContext.traceFlags.isSampled, isTrue);
      expect(spanContext.traceState.get('vendor1'), equals('value1'));
      expect(spanContext.traceState.get('vendor2'), equals('value2'));
      expect(spanContext.isRemote, isTrue);
      expect(spanContext.isValid, isTrue);
    });

    test('create from invalid hex strings', () {
      // Invalid trace ID (all zeros)
      final invalidTraceIdHex = '00000000000000000000000000000000';
      final spanIdHex = '0102030405060708';
      
      final spanContext = SpanContext.fromString(
        traceIdHex: invalidTraceIdHex,
        spanIdHex: spanIdHex,
        traceFlagsHex: '00',
        traceStateHeader: '',
        isRemote: false,
      );

      expect(spanContext.isValid, isFalse);
    });

    test('create invalidSpanContext', () {
      final invalidContext = SpanContext.invalid();
      
      expect(invalidContext.isValid, isFalse);
      expect(invalidContext.traceId, equals(TraceId.invalid));
      expect(invalidContext.spanId, equals(SpanId.invalid));
      expect(invalidContext.traceFlags, equals(TraceFlags.none));
      expect(invalidContext.traceState.isEmpty, isTrue);
      expect(invalidContext.isRemote, isFalse);
    });

    test('isSampled returns correct sampling state', () {
      final sampledContext = OTelAPI.spanContext(
        traceId: traceId,
        spanId: spanId,
        traceFlags: TraceFlags.sampled,
        traceState: TraceState.empty(),
        isRemote: false,
      );
      
      final notSampledContext = OTelAPI.spanContext(
        traceId: traceId,
        spanId: spanId,
        traceFlags: TraceFlags.none,
        traceState: TraceState.empty(),
        isRemote: false,
      );
      
      expect(sampledContext.isSampled, isTrue);
      expect(notSampledContext.isSampled, isFalse);
    });

    test('toString includes all components', () {
      final spanContext = OTelAPI.spanContext(
        traceId: traceId,
        spanId: spanId,
        traceFlags: TraceFlags.sampled,
        traceState: TraceState.fromMap({'vendor': 'value'}),
        isRemote: true,
      );
      
      final str = spanContext.toString();
      expect(str.contains(traceId.toString()), isTrue);
      expect(str.contains(spanId.toString()), isTrue);
      expect(str.contains(TraceFlags.sampled.toString()), isTrue);
      expect(str.contains('isRemote: true'), isTrue);
    });

    test('equals compares span contexts correctly', () {
      final context1 = OTelAPI.spanContext(
        traceId: traceId,
        spanId: spanId,
        traceFlags: TraceFlags.sampled,
        traceState: TraceState.empty(),
        isRemote: true,
      );
      
      final context2 = OTelAPI.spanContext(
        traceId: traceId,
        spanId: spanId,
        traceFlags: TraceFlags.sampled,
        traceState: TraceState.empty(),
        isRemote: true,
      );
      
      final context3 = OTelAPI.spanContext(
        traceId: traceId,
        spanId: spanId,
        traceFlags: TraceFlags.none, // Different flags
        traceState: TraceState.empty(),
        isRemote: true,
      );
      
      expect(context1 == context2, isTrue);
      expect(context1 == context3, isFalse);
      expect(context1 == SpanContext.invalid(), isFalse);
    });

    test('hashCode is consistent', () {
      final context1 = OTelAPI.spanContext(
        traceId: traceId,
        spanId: spanId,
        traceFlags: TraceFlags.sampled,
        traceState: TraceState.empty(),
        isRemote: true,
      );
      
      final context2 = OTelAPI.spanContext(
        traceId: traceId,
        spanId: spanId,
        traceFlags: TraceFlags.sampled,
        traceState: TraceState.empty(),
        isRemote: true,
      );
      
      expect(context1.hashCode, equals(context2.hashCode));
      expect(context1.hashCode == SpanContext.invalid().hashCode, isFalse);
    });
  });
}
