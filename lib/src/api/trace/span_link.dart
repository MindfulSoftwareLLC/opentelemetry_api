// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:meta/meta.dart';
import 'package:opentelemetry_api/src/api/trace/span_context.dart';
import '../common/attributes.dart';
import '../../factory/otel_factory.dart';

part 'span_link_create.dart';

/// Represents a link between spans in potentially different traces.
@immutable
class SpanLink {
  /// The context of the linked span
  final SpanContext spanContext;

  /// The attributes describing this link
  final Attributes attributes;

  /// Creates a new [SpanLink].
  /// You cannot create a SpanLink directly; you must use [OTelFactory]:
  /// ```dart
  /// var link = OTelFactory.spanLink(context);
  /// ```
   SpanLink._({
    required this.spanContext,
    required this.attributes,
  });
}
