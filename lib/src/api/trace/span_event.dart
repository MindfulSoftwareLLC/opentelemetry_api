// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

library span_event;
import 'package:meta/meta.dart';

import '../common/attributes.dart';

part 'span_event_create.dart';

@immutable
class SpanEvent {
  final String name;
  final DateTime timestamp;
  final Attributes? attributes;

  SpanEvent._({
    required this.name,
    required this.timestamp,
    this.attributes,
  });
}
