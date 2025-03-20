// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

// ignore_for_file: unnecessary_getters_setters

import '../common/attributes.dart';
import 'meter.dart';

part 'meter_provider_create.dart';

/// APIMeterProvider is the entry point of the OpenTelemetry metrics API.
/// The API prefix indicates that it's part of the API and not the SDK
/// and generally should not be used since an API without an SDK is a noop.
/// Use the MeterProvider from the SDK instead.
/// It provides access to [APIMeter]s which are used to record metrics.
/// You cannot create a MeterProvider directly;
/// you must use [OTelAPI] or more likely, [OTel], for example to get the default meter provider:
/// ```dart
/// var meterProvider = OTel.meterProvider();
/// ```
/// See [OTel] for creating meters in addition to the default.
/// Use [OTelAPI] to run in no-op mode, as required by the specification.
class APIMeterProvider {
  String _endpoint;
  String _serviceName;
  String? _serviceVersion;
  bool _enabled;
  bool _isShutdown;

  // Cache for created meters, keyed by _MeterKey.
  final Map<_MeterKey, APIMeter> _meterCache = {};

  /// Creates a new [APIMeterProvider].
  /// You cannot create a MeterProvider directly; you must use [OTelFactory]:
  /// ```dart
  /// var meterProvider = OTelFactory.meterProvider();
  APIMeterProvider._({
    required String endpoint,
    String serviceName = "@dart/opentelemetry_api",
    String? serviceVersion = '1.11.0.0',
    bool enabled = true,
    bool isShutdown = false,
  })  : _endpoint = endpoint,
        _serviceName = serviceName,
        _serviceVersion = serviceVersion,
        _enabled = enabled,
        _isShutdown = isShutdown;

  String get endpoint => _endpoint;

  set endpoint(String value) {
    _endpoint = value;
  }

  /// Returns a [APIMeter] with the given [name] and [version].
  ///
  /// [name] The name of the meter, usually the package name of the instrumented library.
  /// [version] The version of the instrumented library.
  /// [schemaUrl] Optional URL of the OpenTelemetry schema being used.
  /// [attributes] Optional Attributes for the Meter.
  APIMeter getMeter({required String name, String? version, String? schemaUrl, Attributes? attributes}) {
    if (_isShutdown) {
      throw StateError('MeterProvider has been shut down');
    }

    // Validate the meter name; if invalid (empty), log a warning and use empty string.
    final validatedName = name.isEmpty ? '' : name;
    if (validatedName.isEmpty) {
      print(
          'Warning: Invalid meter name provided; using empty string as fallback.');
    }

    // Create a cache key based on the provided parameters.
    final key = _MeterKey(validatedName, version, schemaUrl, attributes);

    if (_meterCache.containsKey(key)) {
      return _meterCache[key]!;
    } else {
      final meter = APIMeterCreate.create(
        name: validatedName,
        version: version,
        schemaUrl: schemaUrl,
        attributes: attributes,
      );
      _meterCache[key] = meter;
      return meter;
    }
  }

  String get serviceName => _serviceName;

  set serviceName(String value) {
    _serviceName = value;
  }

  String? get serviceVersion => _serviceVersion;

  set serviceVersion(String? value) {
    _serviceVersion = value;
  }

  bool get enabled => _enabled;

  set enabled(bool value) {
    _enabled = value;
  }

  bool get isShutdown => _isShutdown;

  set isShutdown(bool value) {
    _isShutdown = value;
  }

  /// Shuts down the MeterProvider.
  /// After shutdown:
  /// - New metrics will not be recorded
  /// - All pending metrics should be exported
  /// - Resources should be cleaned up
  /// Returns true if shutdown was successful.
  Future<bool> shutdown() async {
    if (_isShutdown) {
      return true;  // Already shut down
    }

    try {
      // Mark as shut down immediately to prevent new meters
      _isShutdown = true;

      // Clear the meter cache
      _meterCache.clear();

      // Disable the provider
      _enabled = false;

      return true;
    } catch (e) {
      print('Error during MeterProvider shutdown: $e');
      return false;
    }
  }

  /// Forces the MeterProvider to flush all pending metrics to exporters.
  /// This is useful when the application is about to terminate and you want
  /// to ensure all metrics are exported.
  /// Returns true if the flush was successful, false otherwise.
  Future<bool> forceFlush() async {
    if (_isShutdown) {
      return false;  // Already shut down
    }

    try {
      // In the API implementation, this is a no-op
      return true;
    } catch (e) {
      print('Error during MeterProvider forceFlush: $e');
      return false;
    }
  }
}

/// Private key class used for caching Meter instances within MeterProvider.
class _MeterKey {
  final String name;
  final String? version;
  final String? schemaUrl;
  final Attributes? attributes;

  _MeterKey(this.name, this.version, this.schemaUrl, this.attributes);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! _MeterKey) return false;
    return name == other.name &&
        version == other.version &&
        schemaUrl == other.schemaUrl &&
        attributes == other.attributes;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        (version?.hashCode ?? 0) ^
        (schemaUrl?.hashCode ?? 0) ^
        (attributes?.hashCode ?? 0);
  }
}
