// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:opentelemetry_api/src/api/otel_api.dart';
import 'package:opentelemetry_api/src/api/trace/span_context.dart';
import 'package:opentelemetry_api/src/api/trace/span_id.dart';
import 'package:opentelemetry_api/src/api/trace/trace_flags.dart';
import 'package:opentelemetry_api/src/api/trace/trace_id.dart';
import 'package:test/test.dart';

void main() {
  group('SpanContext', () {
    late SpanContext context;
    late TraceId traceId;
    late SpanId spanId;

    setUp(() {
      OTelAPI.reset();
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );
      traceId = OTelAPI.traceId();
      spanId = OTelAPI.spanId();
      context = OTelAPI.spanContext(
        traceId: traceId,
        spanId: spanId,
      );
    });

    test('creates valid span context', () {
      expect(context.isValid, isTrue);
      expect(context.traceId, equals(traceId));
      expect(context.spanId, equals(spanId));
      expect(context.traceFlags, isA<TraceFlags>());
      expect(context.traceState, isNull);
      expect(context.isRemote, isFalse);
    });

    test('creates invalid span context', () {
      final invalidContext = OTelAPI.spanContextInvalid();
      expect(invalidContext.isValid, isFalse);
      expect(invalidContext.traceId.toString(), equals('00000000000000000000000000000000'));
      expect(invalidContext.spanId.toString(), equals('0000000000000000'));
    });

    test('creates child span context correctly', () {
      final parentContext = OTelAPI.spanContext(
        traceId: traceId,
        spanId: spanId,
        traceFlags: OTelAPI.traceFlags(TraceFlags.SAMPLED_FLAG),
        traceState: OTelAPI.traceState({'key': 'value'}),
      );

      final childContext = OTelAPI.spanContextFromParent(parentContext);

      // Child should inherit trace ID and trace state from parent
      expect(childContext.traceId, equals(parentContext.traceId));
      expect(childContext.traceFlags, equals(parentContext.traceFlags));
      expect(childContext.traceState, equals(parentContext.traceState));

      // But should have its own span ID
      expect(childContext.spanId, isNot(equals(parentContext.spanId)));
      expect(childContext.spanId.isValid, isTrue);
    });

    test('updates trace flags', () {
      final updatedContext = context.withTraceFlags(OTelAPI.traceFlags(TraceFlags.SAMPLED_FLAG));
      expect(updatedContext.traceFlags.asByte, equals(1));
      expect(updatedContext.traceId, equals(context.traceId));
      expect(updatedContext.spanId, equals(context.spanId));
    });

    test('updates trace state', () {
      final newState = OTelAPI.traceState({'vendor': 'value'});
      final updatedContext = context.withTraceState(newState);
      expect(updatedContext.traceState, equals(newState));
      expect(updatedContext.traceId, equals(context.traceId));
      expect(updatedContext.spanId, equals(context.spanId));
    });

    test('implements equals correctly', () {
      final sameContext = OTelAPI.spanContext(
        traceId: context.traceId,
        spanId: context.spanId,
        traceFlags: context.traceFlags,
        traceState: context.traceState,
      );

      expect(context, equals(sameContext));
      expect(context.hashCode, equals(sameContext.hashCode));
    });
  });
}
