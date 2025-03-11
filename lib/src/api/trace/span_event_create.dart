// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

part of span_event;

class SpanEventCreate {
  static SpanEvent create({
    required String name,
    required DateTime timestamp,
    Attributes? attributes,
  }) {
    if (name.isEmpty) {
      throw ArgumentError('name cannot be empty');
    }
    return SpanEvent._(name: name, timestamp: timestamp, attributes: attributes);
  }
}
