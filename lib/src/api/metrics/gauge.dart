// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import '../common/attributes.dart';
import 'meter.dart';

part 'gauge_create.dart';

/// APIGauge is a synchronous Instrument which reports instantaneous measurements.
///
/// See the OpenTelemetry specification for more details:
/// https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/metrics/api.md#gauge
class APIGauge<T extends num> {
  final String _name;
  final String? _description;
  final String? _unit;
  final bool _enabled;
  final APIMeter _meter;

  APIGauge(
    this._name,
    this._description,
    this._unit,
    this._enabled,
    this._meter,
  );

  /// Returns the name of this Gauge.
  String get name => _name;

  /// Returns the description of this Gauge.
  String? get description => _description;

  /// Returns the unit of this Gauge.
  String? get unit => _unit;

  /// Returns whether this gauge is enabled.
  bool get enabled => _enabled;

  /// Returns the meter that created this gauge.
  APIMeter get meter => _meter;

  /// Records the current value of the gauge.
  ///
  /// [value] The current value to record.
  /// [attributes] The set of attributes to associate with this value.
  void record(T value, [Attributes? attributes]) {
    // Base implementation is a no-op
  }

  /// Records a value with the given map of attributes.
  ///
  /// [value] The current value to record.
  /// [attributeMap] A map of attribute key-value pairs.
  void recordWithMap(T value, Map<String, Object> attributeMap) {
    // Convert map to Attributes and delegate to record
    final attributes = attributeMap.isEmpty ? null : attributeMap.toAttributes();
    record(value, attributes);
  }

  /// Type identification getters
  bool get isCounter => false;
  bool get isUpDownCounter => false;
  bool get isGauge => true;
  bool get isHistogram => false;
}
