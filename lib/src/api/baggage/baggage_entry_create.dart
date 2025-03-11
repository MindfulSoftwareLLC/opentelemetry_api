// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

part of baggage_entry;

class BaggageEntryFactory {
  static BaggageEntry create<T>(String value, [String? metadata]) {
    return BaggageEntry._(value, metadata);
  }
}
