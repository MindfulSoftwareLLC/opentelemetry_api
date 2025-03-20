// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

part of 'tracer.dart';

/// Internal constructor access for Tracer
class TracerCreate {
  /// Creates a Tracer, only accessible within library
  static APITracer create({
    required String name,
    String? version,
    String? schemaUrl,
    Attributes? attributes,
  }) {
    // Only apply all defaults if none of version, schemaUrl, or attributes are provided
    final bool setDefaults = version == null && schemaUrl == null && attributes == null;
    
    return APITracer._(
      name: name,
      version: setDefaults ? '1.42.0.0' : version, // Only set default if no parameters were provided
      schemaUrl: setDefaults ? 'https://opentelemetry.io/schemas/1.11.0' : schemaUrl, // Only set default if no parameters were provided
      attributes: attributes,
    );
  }
}
