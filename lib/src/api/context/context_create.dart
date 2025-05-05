// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

part of context;

class ContextCreate {
  static Context create({Map<ContextKey<Object?>, Object?>? contextMap, Baggage? baggage}) {
    if (baggage != null) {
      (contextMap ??= {})[Context._baggageKey] = baggage;
    }
    return Context._(contextMap);
  }
}
