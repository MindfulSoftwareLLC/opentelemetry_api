// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.


// ignore_for_file: unnecessary_getters_setters

import '../common/attributes.dart';
import '../context/context.dart';
import 'tracer.dart';

part 'tracer_provider_create.dart';

/// APITracerProvider is the entry point of the OpenTelemetry tracing API.
/// The API prefix indicates that it's part of the API and not the SDK
/// and generally should not be used since an API without an SDK is a noop.
/// Use the TracerProvider from the SDK instead.
/// It provides access to [APITracer]s which are used to trace operations.
/// You cannot create a TracerProvider directly;
/// you must use [OTel], for example to get the default tracer:
/// ```dart
/// var tracerProvider = OTel.tracerProvider();
/// ```
/// See [OTel] for creating tracers in addition to the default.
/// Use [OTelAPI] to run in no-op mode, as required by the specification.
class APITracerProvider {
  String _endpoint;
  String _serviceName;
  String? _serviceVersion;
  bool _enabled;
  bool _isShutdown;

  // Cache for created tracers, keyed by _TracerKey.
  final Map<_TracerKey, APITracer> _tracerCache = {};

  /// Creates a new [APITracerProvider].
  /// You cannot create a TracerProvider directly; you must use [OTelFactory]:
  /// ```dart
  /// var tracerProvider = OTelFactory.tracerProvider();
  APITracerProvider._({
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

  /// Returns a [APITracer] with the given [name] and [version].
  ///
  /// [name] The name of the tracer, usually the package name of the instrumented library.
  /// [version] The version of the instrumented library.
  /// [schemaUrl] Optional URL of the OpenTelemetry schema being used.
  /// [attributes] Optional Attributes for the Tracer.
  APITracer getTracer(String name,
      {String? version, String? schemaUrl, Attributes? attributes}) {
    if (_isShutdown) {
      throw StateError('TracerProvider has been shut down');
    }

    // Validate the tracer name; if invalid (empty), log a warning and use empty string.
    final validatedName = name.isEmpty ? '' : name;
    if (validatedName.isEmpty) {
      print(
          'Warning: Invalid tracer name provided; using empty string as fallback.');
    }

    // Create a cache key based on the provided parameters.
    final key = _TracerKey(validatedName, version, schemaUrl, attributes);

    if (_tracerCache.containsKey(key)) {
      return _tracerCache[key]!;
    } else {
      final tracer = TracerCreate.create(
        name: validatedName,
        version: version,
        schemaUrl: schemaUrl,
        attributes: attributes,
      );
      _tracerCache[key] = tracer;
      return tracer;
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

  /// Shuts down the TracerProvider.
  /// After shutdown:
  /// - New spans will not be accepted
  /// - All spans in progress should be ended
  /// - Resources should be cleaned up
  /// Returns true if shutdown was successful.
  Future<bool> shutdown() async {
    if (_isShutdown) {
      return true;  // Already shut down
    }

    try {
      // Mark as shut down immediately to prevent new tracers/spans
      _isShutdown = true;

      // Clear the tracer cache
      _tracerCache.clear();

      // Disable the provider
      _enabled = false;

      // Reset current context through context API
      // Clear any active spans from context
      Context.root.setCurrentSpan(null);

      return true;
    } catch (e) {
      print('Error during TracerProvider shutdown: $e');
      return false;
    }
  }
}

/// Private key class used for caching Tracer instances within TracerProvider.
class _TracerKey {
  final String name;
  final String? version;
  final String? schemaUrl;
  final Attributes? attributes;

  _TracerKey(this.name, this.version, this.schemaUrl, this.attributes);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! _TracerKey) return false;
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
