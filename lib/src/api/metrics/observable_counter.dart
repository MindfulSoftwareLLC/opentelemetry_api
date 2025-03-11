// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'meter.dart';
import 'measurement.dart';
import 'observable_callback.dart';

part 'observable_counter_create.dart';

/// APIObservableCounter is an asynchronous Instrument which reports monotonically
/// increasing value(s) when the instrument is being observed.
///
/// An ObservableCounter is intended for capturing values that can only increase,
/// such as the system uptime, the number of total bytes received, or the number
/// of page faults.
class APIObservableCounter<T extends num> {
  final String _name;
  final String? _description;
  final String? _unit;
  final bool _enabled;
  final APIMeter _meter;
  final List<ObservableCallback> _callbacks = [];

  /// Creates a new observable counter instrument
  APIObservableCounter(this._name, this._description, this._unit, this._enabled, this._meter, ObservableCallback? callback) {
    if (callback != null) {
      registerCallback(callback);
    }
  }

  /// Returns the name of this observable counter.
  String get name => _name;

  /// Returns the description of this observable counter.
  String? get description => _description;

  /// Returns the unit of this observable counter.
  String? get unit => _unit;

  /// Returns whether this observable counter is enabled.
  bool get enabled => _enabled;

  /// Returns the meter that created this observable counter.
  APIMeter get meter => _meter;

  /// Returns the current list of callbacks registered to this instrument.
  List<ObservableCallback> get callbacks => List.unmodifiable(_callbacks);

  /// Registers a callback function that will be invoked when the instrument is observed.
  APICallbackRegistration registerCallback(ObservableCallback callback) {
    _callbacks.add(callback);
    return _CallbackRegistration(this, callback);
  }

  /// Removes a callback from this instrument.
  void _removeCallback(ObservableCallback callback) {
    _callbacks.remove(callback);
  }

  /// Collects measurements from all registered callbacks.
  /// This method is typically only called by the SDK during collection.
  List<Measurement> collect() {
    // In the API implementation, this simply returns an empty list
    return <Measurement>[];
  }
}

/// Default implementation of [APICallbackRegistration].
class _CallbackRegistration implements APICallbackRegistration {
  final APIObservableCounter _instrument;
  final ObservableCallback _callback;

  _CallbackRegistration(this._instrument, this._callback);

  @override
  void unregister() {
    _instrument._removeCallback(_callback);
  }
}
