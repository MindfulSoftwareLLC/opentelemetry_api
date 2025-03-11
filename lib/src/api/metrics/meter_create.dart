// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.


part of 'meter.dart';

/// Factory methods for creating [APIMeter] instances.
/// This is part of the meter.dart file to keep related code together.
class MeterCreate {
  /// Creates a new [APIMeter] instance.
  /// This is an implementation detail and should not be used directly.
  /// Use [APIMeterProvider.getMeter()] instead.
  static APIMeter create({
    required String name,
    String? version,
    String? schemaUrl,
    Attributes? attributes,
  }) {
    return APIMeter._(
      name: name,
      version: version,
      schemaUrl: schemaUrl,
      attributes: attributes,
    );
  }
}
