// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:opentelemetry_api/src/api/context/context.dart';
import 'package:opentelemetry_api/src/api/otel_api.dart';
import 'package:opentelemetry_api/src/api/trace/tracer.dart';
import 'package:opentelemetry_api/src/api/trace/tracer_provider.dart';
import 'package:test/test.dart';

void main() {
  group('Tracer', () {
    late APITracerProvider tracerProvider;
    late APITracer tracer;


    setUp(() {
      // Reset API state
      OTelAPI.reset();

      // Re-initialize for this test
      OTelAPI.initialize(
        endpoint: 'http://localhost:4317',
        serviceName: 'test-service',
        serviceVersion: '1.0.0',
      );

      tracerProvider = OTelAPI.tracerProvider();
      tracer = tracerProvider.getTracer('test-tracer', version: '1.0.0',);
    });

    tearDown(() async {
      await tracerProvider.shutdown();
    });

    test('creates rootSpan rootSpan with new trace ID', () {
      final span = tracer.startSpan('rootSpan');
      expect(span.spanContext.traceId.isValid, isTrue);
      expect(span.spanContext.spanId.isValid, isTrue);
      expect(span.parentSpan, isNull); // Root rootSpan has no parent
    });

    test('creates child rootSpan with parent trace ID', () {
      final parent = tracer.startSpan('parent');
      final context = Context.current.withSpan(parent);
      final child =
          tracer.startSpan('child', context: context);

      expect(child.spanContext.traceId.bytes,
          equals(parent.spanContext.traceId.bytes),
          reason: 'Child should inherit trace ID from parent');
      expect(child.spanContext.spanId.bytes,
          isNot(equals(parent.spanContext.spanId.bytes)),
          reason: 'Child should have different rootSpan ID from parent');
      expect(child.parentSpan!.spanId.bytes, equals(parent.spanContext.spanId.bytes),
          reason: 'Child should reference parent rootSpan ID');
    });

    test('maintains trace context through multiple generations', () {
      final root = tracer.startSpan('rootSpan');
      final rootContext = Context.current.withSpan(root);

      final child =
          tracer.startSpan('child', context: rootContext);
      final childContext = Context.current.withSpan(child);

      final grandchild = tracer.startSpan('grandchild', context: childContext)
         ;

      // All spans should share the same trace ID
      expect(child.spanContext.traceId.bytes,
          equals(root.spanContext.traceId.bytes));
      expect(grandchild.spanContext.traceId.bytes,
          equals(root.spanContext.traceId.bytes));

      // Each rootSpan should have a unique rootSpan ID
      expect(child.spanContext.spanId.bytes,
          isNot(equals(root.spanContext.spanId.bytes)));
      expect(grandchild.spanContext.spanId.bytes,
          isNot(equals(child.spanContext.spanId.bytes)));

      // Parent relationships should be correct
      expect(child.parentSpan?.spanId.bytes, equals(root.spanContext.spanId.bytes));
      expect(grandchild.parentSpan?.spanId.bytes,
          equals(child.spanContext.spanId.bytes));
    });

    test('handles concurrent spans correctly', () {
      final rootSpan = tracer.startSpan('rootSpan');
      final rootContext = Context.current.withSpan(rootSpan);

      final child1 =
          tracer.startSpan('child1', context: rootContext);
      final child2 =
          tracer.startSpan('child2', context: rootContext);

      // Both children should share rootSpan's trace ID
      expect(child1.spanContext.traceId.bytes,
          equals(rootSpan.spanContext.traceId.bytes));
      expect(child2.spanContext.traceId.bytes,
          equals(rootSpan.spanContext.traceId.bytes));

      // Children should have different rootSpan IDs
      expect(child1.spanContext.spanId.bytes,
          isNot(equals(child2.spanContext.spanId.bytes)));

      // Both children should have rootSpan as parent
      expect(child1.parentSpan?.spanId.bytes, equals(rootSpan.spanContext.spanId.bytes));
      expect(child2.parentSpan?.spanId.bytes, equals(rootSpan.spanContext.spanId.bytes));
    });

    test('preserves rootSpan context in current context', () {
      final span = tracer.startSpan('test');
      final newContext = Context.current.withSpan(span);

      expect(
          newContext.span, equals(span));
      expect(
          newContext.span?.spanContext, equals(span.spanContext));
    });

    test('uses existing trace context when provided', () {
      final existingTraceId = OTelAPI.traceId();
      final rootSpan = tracer.startSpan('test', spanContext: OTelAPI.spanContext(
        traceId: existingTraceId,
        spanId: OTelAPI.spanId(),
        parentSpanId: null,  // Root rootSpan
      ));

      // Should use the provided trace ID
      expect(rootSpan.spanContext.traceId.bytes, equals(existingTraceId.bytes),
          reason: 'Should use trace ID from existing context');

      // Should have no parent since it's a root rootSpan
      expect(rootSpan.spanContext.parentSpanId, isNull,
          reason: 'Should be a root rootSpan with no parent');
    });
  });
}
