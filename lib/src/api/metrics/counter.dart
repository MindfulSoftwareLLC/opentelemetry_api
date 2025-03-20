// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import '../common/attributes.dart';
import 'meter.dart';

part 'counter_create.dart';

/// APICounter is a synchronous Instrument which supports non-negative increments.
///
/// See the OpenTelemetry specification for more details:
/// https://github.com/open-telemetry/opentelemetry-specification/blob/main/specification/metrics/api.md#counter
class APICounter<T extends num> {
  final String _name;
  final String? _description;
  final String? _unit;
  final bool _enabled;
  final APIMeter _meter;

  APICounter(
    this._name,
    this._description,
    this._unit,
    this._enabled,
    this._meter,
  );

  /// Returns the name of this Counter.
  String get name => _name;

  /// Returns the description of this Counter.
  String? get description => _description;

  /// Returns the unit of this Counter.
  String? get unit => _unit;

  /// Returns whether this counter is enabled.
  bool get enabled => _enabled;

  /// Returns the meter that created this counter.
  APIMeter get meter => _meter;

  /// Adds a value to the counter's sum.
  ///
  /// The value must be non-negative.
  ///
  /// [value] The increment amount. Must be non-negative.
  /// [attributes] The set of attributes to associate with this value.
  void add(T value, [Attributes? attributes]) {
    // Base implementation is a no-op
  }

  /// Adds a value to the counter's sum using a map of attributes.
  ///
  /// [value] The increment amount. Must be non-negative.
  /// [attributeMap] A map of attribute key-value pairs.
  void addWithMap(T value, Map<String, Object> attributeMap) {
    // Convert map to Attributes and delegate to add
    final attributes = attributeMap.isEmpty ? null : attributeMap.toAttributes();
    add(value, attributes);
  }

  /// Type identification getters
  bool get isCounter => true;
  bool get isUpDownCounter => false;
  bool get isGauge => false;
  bool get isHistogram => false;
}
