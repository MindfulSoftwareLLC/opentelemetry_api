// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.


part of 'meter.dart';

/// Factory methods for creating [APIMeter] instances.
/// This is part of the meter.dart file to keep related code together.
class APIMeterCreate {
  /// Creates a new [APIMeter] instance.
  /// This is an implementation detail and should not be used directly.
  /// Use [APIMeterProvider.getMeter()] instead.
  static APIMeter create({
    required String name,
    String? version,
    String? schemaUrl,
    Attributes? attributes,
  }) {
    // Only apply all defaults if none of version, schemaUrl, or attributes are provided
    final bool setDefaults = version == null && schemaUrl == null && attributes == null;

    return APIMeter._(
      name: name,
      version: setDefaults ? '1.42.0.0' : version, // Only set default if no parameters were provided
      schemaUrl: setDefaults ? 'https://opentelemetry.io/schemas/1.11.0' : schemaUrl, // Only set default if no parameters were provided
      attributes: attributes,
    );
  }
}
