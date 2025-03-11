// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

part of baggage;

class BaggageCreate {
  static Baggage create<T>([Map<String, BaggageEntry>? entries]) {
    return Baggage._(entries);
  }
}
