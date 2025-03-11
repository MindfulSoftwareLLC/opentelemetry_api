// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

library baggage_entry;

import 'package:meta/meta.dart';

part 'baggage_entry_create.dart';

/// A single entry within Baggage. Typically just a [value] plus optional [metadata].
@immutable
class BaggageEntry {
  final String value;
  final String? metadata;

  const BaggageEntry._(this.value, [this.metadata]);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is BaggageEntry &&
            value == other.value &&
            metadata == other.metadata);
  }

  @override
  int get hashCode => Object.hash(value, metadata);

  @override
  String toString() => 'BaggageEntry(value: $value, metadata: $metadata)';
}
