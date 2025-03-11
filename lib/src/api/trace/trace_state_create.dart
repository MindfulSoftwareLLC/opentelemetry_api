// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

part of 'trace_state.dart';

/// Internal constructor access for TraceState
class TraceStateCreate {
  /// Creates a TraceState, only accessible within library
  static TraceState create(Map<String, String>? entries) {
    return TraceState._(entries);
  }
}
