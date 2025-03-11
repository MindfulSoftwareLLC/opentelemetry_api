// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

part of trace_id;

class TraceIdCreate {
  static TraceId create(Uint8List bytes) {
    return TraceId._(bytes);
  }
}
