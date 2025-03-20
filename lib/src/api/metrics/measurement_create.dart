// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

part of 'measurement.dart';

/// Factory methods for creating [Measurement] instances.
class MeasurementCreate {
  /// Creates a new [Measurement] instance.
  /// This is an implementation detail and should not be used directly.
  /// Use [APIMeter.createMeasurement()] instead.
  static create(num value, [Attributes? attributes]) {
    return Measurement._(value, attributes);
  }
}
