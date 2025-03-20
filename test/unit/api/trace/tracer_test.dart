// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:opentelemetry_api/opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group('APITracer', () {
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

    test('creates with name, version, and schemaUrl', () {
      final tracer = OTelAPI.tracer(
        name: 'test-tracer',
        version: '1.0.0',
        schemaUrl: 'https://example.com/schema',
      );

      expect(tracer.name, equals('test-tracer'));
      expect(tracer.version, equals('1.0.0'));
      expect(tracer.schemaUrl, equals('https://example.com/schema'));
    });

    test('creates span with name only', () {
      final tracer = OTelAPI.tracer(name: 'test-tracer');
      final span = tracer.createSpan(name: 'test-span');

      expect(span, isNotNull);
      expect(span.name, equals('test-span'));
      expect(span.isRecording, isTrue);
    });

    test('creates span with all options', () {
      final tracer = OTelAPI.tracer(name: 'test-tracer');
      final parentContext = OTelAPI.tracerProvider().getTracer(name: 'parent-tracer').createSpan(name: 'parent-span').spanContext;
      
      final attributes = Attributes.of({'key': 'value'});
      final links = [SpanLink(parentContext, attributes)];
      final startTime = DateTime.now();
      
      final span = tracer.createSpan(
        name: 'test-span',
        kind: SpanKind.client,
        attributes: attributes,
        links: links,
        startTime: startTime,
        context: parentContext,
      );

      expect(span, isNotNull);
      expect(span.name, equals('test-span'));
      expect(span.kind, equals(SpanKind.client));
    });

    test('creates span with parent context from current context', () {
      final tracer = OTelAPI.tracer(name: 'test-tracer');
      
      // Create a parent span and make it current
      final parentSpan = tracer.createSpan(name: 'parent-span');
      final testContext = Context.current.setValue(APISpan.key, parentSpan);
      
      // Create a child span in the context with the parent span
      Context.current = testContext;
      final childSpan = tracer.createSpan(name: 'child-span');
      expect(childSpan, isNotNull);
      
      // Reset context
      Context.current = Context.root;
    });

    test('span with default context takes current context', () {
      final tracer = OTelAPI.tracer(name: 'test-tracer');
      
      // Create a parent span and make it current
      final parentSpan = tracer.createSpan(name: 'parent-span');
      final parentContext = parentSpan.spanContext;
      
      // Set the parent span as current
      final testContext = Context.current.setValue(APISpan.key, parentSpan);
      
      // Use the context
      Context.current = testContext;
      
      // Create a child span without explicitly passing a context
      final childSpan = tracer.createSpan(name: 'child-span');
      
      // Reset context
      Context.current = Context.root;
      
      // The child span should have the parent context
      expect(childSpan.parentSpanContext?.traceId, equals(parentContext.traceId));
    });

    test('gets active span from context', () {
      final tracer = OTelAPI.tracer(name: 'test-tracer');
      final span = tracer.createSpan(name: 'test-span');
      
      expect(APISpan.current, isNot(equals(span))); // Not active yet
      
      // Set the span as current
      final testContext = Context.current.setValue(APISpan.key, span);
      Context.current = testContext;
      
      expect(APISpan.current, equals(span)); // Now it should be active
      
      // Reset context
      Context.current = Context.root;
    });

    test('currentSpan returns current span in context', () {
      final tracer = OTelAPI.tracer(name: 'test-tracer');
      final span = tracer.createSpan(name: 'test-span');
      
      expect(tracer.currentSpan, isNot(equals(span))); // Not active yet
      
      // Set the span as current
      final testContext = Context.current.setValue(APISpan.key, span);
      Context.current = testContext;
      
      expect(tracer.currentSpan, equals(span)); // Now it should be active
      
      // Reset context
      Context.current = Context.root;
    });

    test('executing code with span in context', () {
      final tracer = OTelAPI.tracer(name: 'test-tracer');
      final span = tracer.createSpan(name: 'test-span');
      
      var executed = false;
      
      tracer.withSpan(span, () {
        executed = true;
        expect(APISpan.current, equals(span)); // Should be active inside the callback
      });
      
      expect(executed, isTrue);
      expect(APISpan.current, isNot(equals(span))); // Should no longer be active after the callback
    });

    test('executing async code with span in context', () async {
      final tracer = OTelAPI.tracer(name: 'test-tracer');
      final span = tracer.createSpan(name: 'test-span');
      
      var executed = false;
      
      await tracer.withSpanAsync(span, () async {
        executed = true;
        expect(APISpan.current, equals(span)); // Should be active inside the callback
        
        // Make sure it stays active during an await
        await Future.delayed(Duration(milliseconds: 10));
        expect(APISpan.current, equals(span)); // Should still be active
      });
      
      expect(executed, isTrue);
      expect(APISpan.current, isNot(equals(span))); // Should no longer be active after the callback
    });

    test('startSpan starts and activates a span', () {
      final tracer = OTelAPI.tracer(name: 'test-tracer');
      
      // Start a new span and activate it
      final span = tracer.startSpan(name: 'test-span');
      
      expect(span, isNotNull);
      expect(APISpan.current, equals(span)); // Should be active
      
      // End the span, which should also deactivate it
      span.end();
      
      // Now check if it's still the current span
      expect(APISpan.current, isNot(equals(span))); // Should no longer be active
    });

    test('startSpan attaches to existing active span', () {
      final tracer = OTelAPI.tracer(name: 'test-tracer');
      
      // Create and activate a parent span
      final parentSpan = tracer.startSpan(name: 'parent-span');
      final parentContext = parentSpan.spanContext;
      
      // Start a child span (should automatically use the parent)
      final childSpan = tracer.startSpan(name: 'child-span');
      
      // Check the child span has the parent's context
      expect(childSpan.parentSpanContext?.traceId, equals(parentContext.traceId));
      
      // End both spans
      childSpan.end();
      parentSpan.end();
    });

    test('startSpanWithContext activates span in specified context', () {
      final tracer = OTelAPI.tracer(name: 'test-tracer');
      final customContext = Context.root.setValue(ContextKey<String>('test'), 'value');
      
      // Start a span with the custom context
      final span = tracer.startSpanWithContext(name: 'test-span', context: customContext);
      
      expect(span, isNotNull);
      expect(APISpan.current, equals(span)); // Should be active
      
      // The context should now contain both the span and the original value
      final currentContext = Context.current;
      expect(currentContext.getValue(ContextKey<String>('test')), equals('value'));
      
      // End the span
      span.end();
    });

    test('startActiveSpan executes code with new active span', () {
      final tracer = OTelAPI.tracer(name: 'test-tracer');
      
      var executed = false;
      final result = tracer.startActiveSpan(name: 'test-span', fn: (span) {
        executed = true;
        expect(APISpan.current, equals(span)); // Should be active inside the callback
        return 'test-result';
      });
      
      expect(executed, isTrue);
      expect(result, equals('test-result'));
    });

    test('startActiveSpanAsync executes async code with new active span', () async {
      final tracer = OTelAPI.tracer(name: 'test-tracer');
      
      var executed = false;
      final result = await tracer.startActiveSpanAsync(name: 'test-span', fn: (span) async {
        executed = true;
        expect(APISpan.current, equals(span)); // Should be active inside the callback
        
        // Make sure it stays active during an await
        await Future.delayed(Duration(milliseconds: 10));
        expect(APISpan.current, equals(span)); // Should still be active
        
        return 'test-result';
      });
      
      expect(executed, isTrue);
      expect(result, equals('test-result'));
    });

    test('recordSpan executes code and records it as a span', () {
      final tracer = OTelAPI.tracer(name: 'test-tracer');
      
      var executed = false;
      final result = tracer.recordSpan(
        name: 'test-span',
        fn: () {
          executed = true;
          return 'test-result';
        },
      );
      
      expect(executed, isTrue);
      expect(result, equals('test-result'));
    });

    test('recordSpanAsync executes async code and records it as a span', () async {
      final tracer = OTelAPI.tracer(name: 'test-tracer');
      
      var executed = false;
      final result = await tracer.recordSpanAsync(
        name: 'test-span',
        fn: () async {
          executed = true;
          await Future.delayed(Duration(milliseconds: 10));
          return 'test-result';
        },
      );
      
      expect(executed, isTrue);
      expect(result, equals('test-result'));
    });
  });
}
