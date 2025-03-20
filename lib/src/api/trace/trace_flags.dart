// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

library trace_flags;

part 'trace_flags_create.dart';

/// Trace flags for a [SpanContext].
/// These flags are used to control tracing behavior.
/// TraceFlags follows the W3C Trace Context specification.
class TraceFlags {
  // ignore: constant_identifier_names
  static const int NONE_FLAG = 0x0;
  // ignore: constant_identifier_names
  static const int SAMPLED_FLAG = 0x1;
  static TraceFlags none = TraceFlagsCreate.create(NONE_FLAG);
  static TraceFlags sampled = TraceFlagsCreate.create(SAMPLED_FLAG);

  final int _flags;

  /// Create TraceFlags with the given flags value
  const TraceFlags._([this._flags = NONE_FLAG]);

  /// Create TraceFlags from a hex string
  factory TraceFlags.fromString(String hex) {
    final flags = int.tryParse(hex, radix: 16) ?? NONE_FLAG;
    return TraceFlagsCreate.create(flags);
  }

  /// Returns the byte representation of the TraceFlags
  int get asByte => _flags;

  /// Returns true if the sampled flag is set
  bool get isSampled => (_flags & SAMPLED_FLAG) == SAMPLED_FLAG;

  /// Returns a new trace flags with sampling enabled or disabled.
  TraceFlags withSampled(bool isSampled) {
    if (isSampled) {
      return TraceFlagsCreate.create(_flags | SAMPLED_FLAG);
    } else {
      return TraceFlagsCreate.create(_flags & ~SAMPLED_FLAG);
    }
  }

  /// Convert flags to hex string
  @override
  String toString() => _flags.toRadixString(16).padLeft(2, '0');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is TraceFlags &&
              runtimeType == other.runtimeType &&
              _flags == other._flags;

  @override
  int get hashCode => _flags.hashCode;

}

