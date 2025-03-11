// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

part of span_id;

class SpanIdCreate {
  static SpanId create(Uint8List bytes) {
    return SpanId._(bytes);
  }
}
