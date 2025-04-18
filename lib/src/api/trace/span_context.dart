// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

library span_context;

import 'package:opentelemetry_api/opentelemetry_api.dart';

part 'span_context_create.dart';

/// Immutable representation of a SpanContext.
/// A SpanContext contains the state that must propagate to child Spans
/// and across process boundaries.
/// SpanContext follows the W3C Trace Context specification.
class SpanContext {

  final TraceId traceId;
  final SpanId spanId;
  final TraceFlags traceFlags;
  final TraceState? traceState;
  final SpanId? parentSpanId;
  final bool _isRemote;

  SpanContext._({  
    required this.traceId,
    required this.traceFlags,
    required this.spanId,
    this.parentSpanId,
    this.traceState,
    bool isRemote = false,
  })  : _isRemote = isRemote;


  bool get isValid => traceId.isValid  && spanId.isValid;

  bool get isRemote => _isRemote;

  /// Create a new SpanContext with updated trace flags
  SpanContext withTraceFlags(TraceFlags flags) {
    return OTelAPI.spanContext(
      traceId: traceId,
      spanId: spanId,
      parentSpanId: parentSpanId,
      traceFlags: flags,
      traceState: traceState,
      isRemote: _isRemote,
    );
  }

  /// Create a new SpanContext with updated trace state
  SpanContext withTraceState(TraceState state) {
    return OTelAPI.spanContext(
      traceId: traceId,
      spanId: spanId,
      parentSpanId: parentSpanId,
      traceFlags: traceFlags,
      traceState: state,
      isRemote: _isRemote,
    );
  }

  Map<String, dynamic> toJson() {
    var jsonMap = {
      'traceId': traceId.toString(),
      'spanId': spanId.toString(),
      'traceFlags': traceFlags.asByte,
      'isRemote': _isRemote,
    };

    // Always include parentSpanId
    if (parentSpanId != null) {
      jsonMap['parentSpanId'] = parentSpanId!.toString();
    }

    if (traceState != null) {
      jsonMap['traceState'] =  traceState!.entries;
    }

    return jsonMap;
  }

  factory SpanContext.fromJson(Map<String, dynamic> json) {
    if (OTelFactory.otelFactory == null) throw StateError('Call initialize() first.');

    SpanId? parentSpanId;
    if (json['parentSpanId'] != null) {
      final parentId = OTelAPI.spanIdFrom(json['parentSpanId'] as String);
      // Only set parentSpanId if it's valid (not all zeros)
      if (parentId.isValid) {
        parentSpanId = parentId;
      }
    }

    return OTelAPI.spanContext(
      traceId: OTelAPI.traceIdFrom(json['traceId'] as String),
      spanId: OTelAPI.spanIdFrom(json['spanId'] as String),
      parentSpanId: parentSpanId,
      traceFlags: OTelFactory.otelFactory!.traceFlags(json['traceFlags'] as int),
      traceState:
      OTelFactory.otelFactory!.traceState(json['traceState'] as Map<String, String>? ?? {}),
      isRemote: json['isRemote'] as bool,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is SpanContext &&
              runtimeType == other.runtimeType &&
              traceId == other.traceId &&
              spanId == other.spanId &&
              parentSpanId == other.parentSpanId &&
              traceFlags == other.traceFlags &&
              traceState == other.traceState &&
              _isRemote == other._isRemote;

  @override
  int get hashCode =>
      traceId.hashCode ^
      spanId.hashCode ^
      (parentSpanId?.hashCode ?? 0) ^
      traceFlags.hashCode ^
      (traceState?.hashCode ?? 0) ^
      _isRemote.hashCode;

  @override
  String toString() {
    return 'SpanContext{traceId: $traceId, spanId: $spanId, parentSpanId: $parentSpanId, traceFlags: $traceFlags, traceState: $traceState, isRemote: $_isRemote}';
  }
}
