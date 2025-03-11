// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:opentelemetry_api/src/api/trace/span_context.dart';
import 'package:opentelemetry_api/src/api/trace/span_event.dart';
import 'package:opentelemetry_api/src/factory/otel_factory.dart';
import '../common/attributes.dart';
import '../context/context.dart';
import 'instrumentation_scope.dart';
import 'span.dart';
import 'span_kind.dart';
import 'span_link.dart';

part 'tracer_create.dart';

/// Tracer is responsible for creating [APISpan]s and propagating context in-process.
/// The API prefix indicates that it's part of the API and not the SDK
/// and generally should not be used since an API without an SDK is a noop.
/// Use the TracerProvider from the SDK instead.
class APITracer {
  /// Gets the name of the tracer, usually of a library, package or module
  final String name;

  /// Gets the version, usually of the instrumented library, package or module
  final String? version;

  /// Gets the schema URL of the tracer
  final String? schemaUrl;

  Attributes? attributes;

  /// Creates a new [APITracer].
  /// You cannot create a Tracer directly; you must use [TracerProvider]:
  /// ```dart
  /// var tracer = OTelFactory.tracerProvider().get("my-library");
  /// ```
  APITracer._({
    this.name = '@dartastic/opentelemetry_instrumentation_api',
    this.schemaUrl = 'https://opentelemetry.io/schemas/1.11.0',
    this.version = '1.42.0.0', //matches the otel spec version, plus a number
    this.attributes,
  });

  /// Returns true if the tracer is enabled and will create sampling spans.
  /// This should be checked before performing expensive operations to create spans.
  bool get enabled => false;

  /// Starts a new [APISpan].
  ///
  /// Context precedence (in order):
  /// 1. If [spanContext] is provided, it will be used as base for the new span's context
  /// 2. If [parentSpan] is provided, it will be used as the parent
  /// 3. If [context] is provided, any span in it will be used as parent
  /// 4. If none of the above, [Context.current] will be checked for a parent span
  ///
  /// Parent-child relationship rules:
  /// - If both [spanContext] and [parentSpan] are provided and [spanContext] has a
  ///   parent ID, it must match [parentSpan]'s span ID
  /// - The new span inherits trace ID from parent if any, otherwise gets new trace ID
  /// - The new span always gets a new span ID
  /// - Parent span ID is set from the parent if any, otherwise invalid
  /// - Trace state and flags are inherited from parent if any
  ///
  /// [name] The name of the span
  /// [context] Optional explicit context to use
  /// [spanContext] Optional explicit span context to use as base
  /// [parentSpan] Optional explicit parent span
  /// [kind] The SpanKind (optional), defaults to [SpanKind.internal]
  /// [attributes] Standard attributes (see semantic conventions)
  /// [links] Links to other spans
  /// [isRecording] Whether the span should record information
  APISpan startSpan(
    String name, {
    Context? context,
    SpanContext? spanContext,
    APISpan? parentSpan,
    SpanKind kind = SpanKind.internal,
    Attributes? attributes,
    List<SpanLink>? links,
    bool? isRecording = true,
  }) {
    print('\nStarting span: $name');

    // TODO - empty span
    // if (!_isEnabled) {
    //   return Span.empty();
    // }

    // Get current context and determine parent
    final contextOfSpan = context ?? Context.current;
    final contextSpan = contextOfSpan.span;
    final effectiveParentSpan = parentSpan ?? contextSpan;
    final contextSpanContext = contextOfSpan.spanContext;

    SpanContext spanCtx;
    if (spanContext != null) {
      // Use provided span context but ensure parent relationship
      print('Using provided span context: ${spanContext.traceId}');
      spanCtx = OTelFactory.otelFactory!.spanContext(
        traceId: spanContext.traceId,
        spanId: OTelFactory.otelFactory!.spanId(),
        parentSpanId: effectiveParentSpan?.spanContext.spanId,
        traceFlags: spanContext.traceFlags,
        traceState: spanContext.traceState,
        isRemote: spanContext.isRemote,
      );
    } else if (contextSpanContext != null &&
        contextSpanContext.isValid &&
        contextSpanContext.isRemote) {
      // Handle remote context - create child using remote context's trace ID
      print(
          'Creating child span from remote context: ${contextSpanContext.traceId}');
      spanCtx = OTelFactory.otelFactory!.spanContext(
        traceId: contextSpanContext.traceId,
        spanId: OTelFactory.otelFactory!.spanId(),
        parentSpanId: contextSpanContext.spanId,
        traceFlags: contextSpanContext.traceFlags,
        traceState: contextSpanContext.traceState,
      );
    } else if (effectiveParentSpan != null) {
      // Create child context from parent
      print(
          'Creating child context from parent: ${effectiveParentSpan.spanContext.traceId}');
      spanCtx = OTelFactory.otelFactory!
          .spanContextFromParent(effectiveParentSpan.spanContext);
    } else {
      // Create new root context
      print('Creating new root span context');
      spanCtx = OTelFactory.otelFactory!.spanContext(
        traceId: OTelFactory.otelFactory!.traceId(),
        spanId: OTelFactory.otelFactory!.spanId(),
        parentSpanId: OTelFactory.otelFactory!.spanIdInvalid(),
      );
    }

    print('Final span context trace ID: ${spanCtx.traceId}');

    var span = createSpan(
        name: name,
        spanContext: spanCtx,
        parentSpan: effectiveParentSpan,
        kind: kind,
        attributes: attributes,
        links: links,
        isRecording: isRecording);

    // Set the span in context and ensure it's properly propagated
    contextOfSpan.setCurrentSpan(span);
    return span;
  }

  APISpan createSpan({
    required String name,
    required SpanContext spanContext,
    APISpan? parentSpan,
    SpanKind kind = SpanKind.internal,
    Attributes? attributes,
    List<SpanLink>? links,
    List<SpanEvent>? spanEvents,
    DateTime? startTime,
    bool? isRecording,
  }) {
    if (parentSpan != null &&
        spanContext.traceId != parentSpan.spanContext.traceId) {
      throw ArgumentError(
          'Parent and child span context traceIds must be the same');
    }

    return SpanCreate.create(
      name: name,
      instrumentationScope: InstrumentationScope(
        name: this.name,
        version: version,
        attributes: attributes
      ),
      spanContext: spanContext,
      parentSpan: parentSpan,
      spanKind: kind,
      attributes: attributes,
      links: links,
      spanEvents: spanEvents,
      startTime: startTime,
      isRecording: isRecording ?? true && enabled,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is APITracer &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          version == other.version &&
          schemaUrl == other.schemaUrl &&
          attributes == other.attributes;

  @override
  int get hashCode =>
      name.hashCode ^
      version.hashCode ^
      schemaUrl.hashCode ^
      attributes.hashCode;
}
