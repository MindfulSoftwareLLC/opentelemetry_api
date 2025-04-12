// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import '../../../opentelemetry_api.dart';

/// Represents the instrumentation scope information for a Span.
///
/// This follows the OpenTelemetry specification which states that each Tracer has
/// an associated InstrumentationScope that provides information about the library
/// that created the Span.
class InstrumentationScope {
  final String name;
  final String? version;
  final String? schemaUrl;
  final Attributes? attributes;

  /// Creates a new InstrumentationScope.
  ///
  /// [name] is required and represents the instrumentation scope name (e.g. 'io.opentelemetry.contrib.mongodb')
  /// [version] is optional and specifies the version of the instrumentation scope
  /// [schemaUrl] is optional and specifies the Schema URL
  /// [attributes] is optional and specifies instrumentation scope attributes
  const InstrumentationScope({
    required this.name,
    this.version,
    this.schemaUrl,
    this.attributes,
  });
}
