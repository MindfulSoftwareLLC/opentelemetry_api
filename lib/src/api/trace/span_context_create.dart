// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

part of 'span_context.dart';

/// Internal constructor access for Span
class SpanContextCreate {
  /// Creates a Span, only accessible within library
  static SpanContext create({
    TraceId? traceId,
    SpanId? spanId,
    SpanId? parentSpanId,
    TraceFlags? traceFlags,
    TraceState? traceState,
    bool? isRemote = false,
  }) {
    return SpanContext._(
        traceId: traceId ?? OTelFactory.otelFactory!.traceId(),
        spanId: spanId ?? OTelFactory.otelFactory!.spanId(),
        parentSpanId: parentSpanId,
        traceFlags: traceFlags ?? OTelFactory.otelFactory!.traceFlags(),
        traceState: traceState,
        isRemote: isRemote ?? false);
  }
}
