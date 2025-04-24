// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'dart:typed_data';
import 'package:meta/meta.dart';
import '../../opentelemetry_api.dart';

/// The [OTelAPI] is the no-op API implementation of OTel, as required by the
/// specification
/// This class should only be used in the rare case of running without and SDK
/// It is provided to comply with the specifiction requirement that the API
/// can be used without an SDK installed.
/// The [initialize] method must be called first. Internally it sets the
/// [OTelFactory] to [OTelAPIFactory].
/// The rest of the methods act like factory constructors for OTelAPI classes.
class OTelAPI {
  static const String defaultServiceName = '@dart/opentelemetry_api';
  static const String defaultServiceVersion = '1.11.0.0';
  static const String defaultSchemaUrl = 'https://opentelemetry.io/schemas/1.11.0';

  static OTelFactory? _otelFactory;

  /// Typically developers will want to initialize [OTel] (the SDK),
  /// and not [OTelAPI] (the no-op API).
  /// The [initialize] method must be called before any other methods.
  ///
  /// The global default TracerProvider and it's tracers will use the provided
  /// parameters.
  /// [endpoint] is a url, http://localhost:4317 uses the default port for
  /// the default gRPC protocol on a local host, http://localhost:4318 for http.
  /// [serviceName] SHOULD uniquely identify the instrumentation scope, such as
  /// the instrumentation library (e.g. @dart/opentelemetry_api),
  /// package, module or class name.
  /// [serviceVersion] defaults to the matching OTel spec version
  /// plus a release version of this library, currently  1.11.0.0
  /// [otelFactoryCreationFunction] defaults to a function that constructs
  /// the noop OTelAPIFactory as required by the specification. A factory
  /// method is required for serialization across
  /// execution contexts (isolates).
  /// Using [OTel.initialize] in the `dartastic_opentelemetry` library
  /// sets this factory to an SDK factory, which is the typical usage.
  static void initialize(
      {String endpoint = OTelFactory.defaultEndpoint,
      String? serviceName = OTelAPI.defaultServiceName,
      String? serviceVersion = OTelAPI.defaultServiceVersion,
      OTelFactoryCreationFunction? oTelFactoryCreationFunction}) {
    if (OTelFactory.otelFactory != null) {
      throw StateError(
          'OTelAPI can only be initialized once. If you need multiple endpoints or service names or versions create a named TracerProvider');
    }
    if (endpoint.isEmpty) {
      throw ArgumentError(
          'endpoint must not be empty.  Since the API (but not the SDK) uses noop processors by default, this can be any url for the API such as http://localhost:4317.');
    }
    if (serviceName == null || serviceName.isEmpty) {
      throw ArgumentError('serviceName must not be null or the empty string.');
    }
    if (serviceVersion == null || serviceVersion.isEmpty) {
      throw ArgumentError(
          'serviceVersion must not be null or the empty string.');
    }
    final factoryFactory =
        oTelFactoryCreationFunction ?? otelApiFactoryFactoryFunction;
    OTelFactory.otelFactory = factoryFactory(
        apiEndpoint: endpoint,
        apiServiceName: serviceName,
        apiServiceVersion: serviceVersion);
  }

  /// Creates a new [ContextKey] with the given name.
  /// Each instance will be unique, even with the same name, per spec.
  /// The name is for debugging purposes only.
  static ContextKey<T> contextKey<T>(String name) {
    _getAndCacheOtelFactory();
    return OTelFactory.otelFactory!.contextKey(name, ContextKey.generateContextKeyId());
  }

  /// Creates a new [Context] with optional [Baggage]
  static Context context({Baggage? baggage}) {
    _getAndCacheOtelFactory();
    return OTelFactory.otelFactory!.context(baggage: baggage);
  }

  /// Gets a TracerProvider.  If name is null, this returns
  /// the global default [APITracerProvider], if not it returns a
  /// TracerProvider for the name.  If the TracerProvider does not exist,
  /// it is created.
  static APITracerProvider tracerProvider([String? name]) {
    _getAndCacheOtelFactory();
    if (name != null && name.isEmpty) {
      throw ArgumentError(
          'Name must not be empty. To retrieve the global default tracer provider, omit the name parameter.');
    }
    if (name == null) {
      return _otelFactory!.globalDefaultTracerProvider();
    } else {
      APITracerProvider? tp = _otelFactory!.getNamedTracerProvider(name);
      tp ??= _otelFactory!.addTracerProvider(name);
      return tp;
    }
  }

  /// Gets a MeterProvider.  If name is null, this returns
  /// the global default [APIMeterProvider], if not it returns a
  /// MeterProvider for the name.  If the MeterProvider does not exist,
  /// it is created.
  static APIMeterProvider meterProvider([String? name]) {
    _getAndCacheOtelFactory();
    if (name != null && name.isEmpty) {
      throw ArgumentError(
          'Name must not be empty. To retrieve the global default meter provider, omit the name parameter.');
    }
    if (name == null) {
      return _otelFactory!.globalDefaultMeterProvider();
    } else {
      APIMeterProvider? mp = _otelFactory!.getNamedMeterProvider(name);
      mp ??= _otelFactory!.addMeterProvider(name);
      return mp;
    }
  }

  /// Adds or replaces a named tracer provider
  static APITracerProvider addTracerProvider(String name,
      {String? endpoint, String? serviceName, String? serviceVersion}) {
    _getAndCacheOtelFactory();
    return _otelFactory!.addTracerProvider(name,
        endpoint: endpoint,
        serviceName: serviceName,
        serviceVersion: serviceVersion);
  }

  /// Adds or replaces a named meter provider
  static APIMeterProvider addMeterProvider(String name,
      {String? endpoint, String? serviceName, String? serviceVersion}) {
    _getAndCacheOtelFactory();
    return _otelFactory!.addMeterProvider(name,
        endpoint: endpoint,
        serviceName: serviceName,
        serviceVersion: serviceVersion);
  }

  /// Get the default or named tracer from the global TracerProvider
  static tracer(String name) {
    return OTelFactory.otelFactory!.globalDefaultTracerProvider().getTracer(name);
  }

  static TraceId traceIdFromBytes(List<int> traceIdBytes) {
    return TraceIdCreate.create(Uint8List.fromList(traceIdBytes));
  }

  static SpanId spanIdFromBytes(List<int> traceIdBytes) {
    return SpanIdCreate.create(Uint8List.fromList(traceIdBytes));
  }

  /// The API MUST implement methods to create a SpanContext. These methods
  /// SHOULD be the only way to create a SpanContext. This functionality MUST be
  /// fully implemented in the API, and SHOULD NOT be overridable.
  /// Hence the SDK defers to this method
  static SpanContext spanContext(
      {TraceId? traceId,
      SpanId? spanId,
      SpanId? parentSpanId,
      TraceFlags? traceFlags,
      TraceState? traceState,
      bool? isRemote = false}) {
    _getAndCacheOtelFactory();
    
    // If parentSpanId is provided but invalid, treat it as null
    SpanId? effectiveParentSpanId = parentSpanId;
    if (effectiveParentSpanId != null && !effectiveParentSpanId.isValid) {
      effectiveParentSpanId = null;
    }
    
    return OTelFactory.otelFactory!.spanContext(
      traceId: traceId ?? OTelAPI.traceId(),
      spanId: spanId ?? OTelAPI.spanId(),
      parentSpanId: effectiveParentSpanId,
      traceFlags: traceFlags ?? TraceFlags.none,
      traceState: traceState,
      isRemote: isRemote,
    );
  }

  /// Create a child SpanContext from a parent context
  static SpanContext spanContextFromParent(SpanContext parent) {
    _getAndCacheOtelFactory();
    return OTelFactory.otelFactory!.spanContextFromParent(parent);
  }

  /// Create an invalid [SpanContext] as required but the spec
  static SpanContext spanContextInvalid() {
    _getAndCacheOtelFactory();
    return OTelFactory.otelFactory!.spanContextInvalid();
  }

  static SpanEvent spanEventNow(String name, Attributes attributes) {
    _getAndCacheOtelFactory();
    return spanEvent(name, attributes, DateTime.now());
  }

  /// Creates a span event
  static SpanEvent spanEvent(String name,
      [Attributes? attributes, DateTime? timestamp]) {
    _getAndCacheOtelFactory();
    return OTelFactory.otelFactory!.spanEvent(name, attributes, timestamp);
  }

  /// Creates an `BaggageEntry` with the given `value` and optional `metadata`.
  static BaggageEntry baggageEntry(String value, String? metadata) {
    _getAndCacheOtelFactory();
    return OTelFactory.otelFactory!.baggageEntry(value, metadata);
  }

  /// Creates an `Baggage` with the given `name` and `keyValuePairs` which
  /// are converted into `BaggeEntry`s without metadata.
  static Baggage baggageForMap(Map<String, String> keyValuePairs) {
    _getAndCacheOtelFactory();
    return OTelFactory.otelFactory!.baggageForMap(keyValuePairs);
  }

  /// Creates an `Baggage` with the given `name` and `entries`.
  static Baggage baggage([Map<String, BaggageEntry>? entries]) {
    _getAndCacheOtelFactory();
    return OTelFactory.otelFactory!.baggage(entries);
  }

  /// Creates a baggage instance from a JSON representation.
  static baggageFromJson(Map<String, dynamic> json) {
    _getAndCacheOtelFactory();
    final entries = <String, BaggageEntry>{};
    for (final entry in json.entries) {
      if (entry.value is Map) {
        final value = entry.value as Map;
        final stringValue = value['value'] as String?;
        if (stringValue == null || stringValue.isEmpty) {
          continue; // Skip invalid entries
        }
        entries[entry.key] = OTelFactory.otelFactory!.baggageEntry(
          stringValue,
          value['metadata'] as String?,
        );
      }
    }
    return OTelFactory.otelFactory!.baggage(entries);
  }

  /// Create a string attribute key
  static Attribute<String> attributeString(String name, String value) {
    _getAndCacheOtelFactory();
    return OTelFactory.otelFactory!.attributeString(name, value);
  }

  /// Create a boolean attribute key
  static Attribute<bool> attributeBool(String name, bool value) {
    _getAndCacheOtelFactory();
    return OTelFactory.otelFactory!.attributeBool(name, value);
  }

  /// Create an integer attribute key
  static Attribute<int> attributeInt(String name, int value) {
    _getAndCacheOtelFactory();
    return OTelFactory.otelFactory!.attributeInt(name, value);
  }

  /// Create a double attribute key
  static Attribute<double> attributeDouble(String name, double value) {
    _getAndCacheOtelFactory();
    return OTelFactory.otelFactory!.attributeDouble(name, value);
  }

  /// Create a string list attribute key
  static Attribute<List<String>> attributeStringList(
      String name, List<String> value) {
    _getAndCacheOtelFactory();
    return OTelFactory.otelFactory!.attributeStringList(name, value);
  }

  /// Create a boolean list attribute key
  static Attribute<List<bool>> attributeBoolList(
      String name, List<bool> value) {
    _getAndCacheOtelFactory();
    return OTelFactory.otelFactory!.attributeBoolList(name, value);
  }

  /// Create an integer list attribute key
  static Attribute<List<int>> attributeIntList(String name, List<int> value) {
    _getAndCacheOtelFactory();
    return OTelFactory.otelFactory!.attributeIntList(name, value);
  }

  /// Create a double list attribute key
  static Attribute<List<double>> attributeDoubleList(
      String name, List<double> value) {
    _getAndCacheOtelFactory();
    return OTelFactory.otelFactory!.attributeDoubleList(name, value);
  }

  /// Creates an `Attributes` collection from a list of [Attribute]s.
  static Attributes attributes([List<Attribute>? entries]) {
    _getAndCacheOtelFactory();
    return OTelFactory.otelFactory!.attributes(entries);
  }

  static Attributes attributesFromSemanticMap(Map<OTelSemantic, Object> semanticMap) {
    return attributesFromMap(semanticMap.map((key, value) =>  key.toMapEntry(value)));
  }

  /// Creates an empty `Attributes` collection from a named set of values.
  /// String, bool, int and double or Lists of those types get turned into
  /// the matching typed attribute.
  /// DateTime gets converted to an Attribute\<String> with the UTC time string.
  /// Attributes get added as-is (note - that would be unnecessary code)
  /// Anything else gets converted to an Attribute\<String> via its toString.
  static Attributes attributesFromMap(Map<String, Object> namedMap) {
    // Cheating a bit since Attributes is unlikley to get overridden
    // and are often used before initialize() _getAndCacheOtelFactory();
    return OTelAPIFactory.attrsFromMap(namedMap);
  }

  static Attributes attributesFromList(List<Attribute> attributeList) {
    _getAndCacheOtelFactory();
    return OTelFactory.otelFactory!.attributesFromList(attributeList);
  }

  static TraceState traceState(Map<String, String>? entries) {
    _getAndCacheOtelFactory();
    return OTelFactory.otelFactory!.traceState(entries);
  }

  static TraceFlags traceFlags([int? flags]) {
    _getAndCacheOtelFactory();
    return OTelFactory.otelFactory!.traceFlags(flags ?? TraceFlags.NONE_FLAG);
  }

  static TraceId traceId() {
    return traceIdOf(IdGenerator.generateTraceId());
  }

  static TraceId invalidTraceId() {
    return traceIdOf(TraceId.invalidTraceIdBytes);
  }

  static TraceId traceIdOf(Uint8List traceId) {
    _getAndCacheOtelFactory();
    if (traceId.length != TraceId.traceIdLength) {
      throw ArgumentError(
          'Trace ID must be exactly ${TraceId.traceIdLength} bytes, got ${traceId.length} bytes');
    }
    return OTelFactory.otelFactory!.traceId(traceId);
  }

  /// Creates a new [TraceId] from a hex string
  static TraceId traceIdFrom(String hexString) {
    _getAndCacheOtelFactory();
    try {
      var bytes = IdGenerator.hexToBytes(hexString);
      if (bytes == null || bytes.length != TraceId.traceIdLength) {
        throw FormatException('TraceId must be {$TraceId.traceIdLength} bytes');
      }
      return OTelFactory.otelFactory!.traceId(bytes);
    } catch (e) {
      throw FormatException('Invalid TraceId hex string: $hexString, $e');
    }
  }

  /// Creates an invalid [Trace] (all zeros)
  static TraceId traceIdInvalid() {
    return traceIdOf(TraceId.invalidTraceIdBytes);
  }

  /// Generate a new random SpanId
  static SpanId spanId() {
    return spanIdOf(IdGenerator.generateSpanId());
  }

  /// SpanId of 8 bytes.
  static SpanId spanIdOf(Uint8List spanId) {
    _getAndCacheOtelFactory();
    if (spanId.length != 8) {
      throw ArgumentError(
          'Span ID must be exactly 8 bytes, got ${spanId.length} bytes');
    }
    return OTelFactory.otelFactory!.spanId(spanId);
  }

  /// SpanId from 8-byte String.
  static SpanId spanIdFrom(String hexString) {
    _getAndCacheOtelFactory();

    /// Generate a new random SpanId
    try {
      var bytes = IdGenerator.hexToBytes(hexString);
      if (bytes == null || bytes.length != SpanId.spanIdLength) {
        throw FormatException('SpanId must be ${SpanId.spanIdLength} bytes');
      }
      return OTelFactory.otelFactory!.spanId(bytes);
    } catch (e) {
      throw FormatException('Invalid SpanId hex string: $hexString,  $e');
    }
  }

  /// Creates an invalid [SpanId] (all zeros)
  static SpanId spanIdInvalid() {
    return spanIdOf(SpanId.invalidSpanIdBytes);
  }

  static SpanLink spanLink(SpanContext spanContext, Attributes attributes) {
    _getAndCacheOtelFactory();
    return OTelFactory.otelFactory!
        .spanLink(spanContext, attributes: attributes);
  }

  /// Creates a counter instrument
  static APICounter createCounter(String name, {String? description, String? unit}) {
    _getAndCacheOtelFactory();
    return OTelFactory.otelFactory!.createCounter(name, description: description, unit: unit);
  }

  /// Creates an up-down counter instrument
  static APIUpDownCounter createUpDownCounter(String name, {String? description, String? unit}) {
    _getAndCacheOtelFactory();
    return OTelFactory.otelFactory!.createUpDownCounter(name, description: description, unit: unit);
  }

  /// Creates a gauge instrument
  static APIGauge createGauge(String name, {String? description, String? unit}) {
    _getAndCacheOtelFactory();
    return OTelFactory.otelFactory!.createGauge(name, description: description, unit: unit);
  }

  /// Creates a histogram instrument
  static APIHistogram createHistogram(String name, {String? description, String? unit, List<double>? boundaries}) {
    _getAndCacheOtelFactory();
    return OTelFactory.otelFactory!.createHistogram(name, description: description, unit: unit, boundaries: boundaries);
  }

  /// Creates an observable counter instrument
  static APIObservableCounter createObservableCounter(String name, {String? description, String? unit, ObservableCallback? callback}) {
    _getAndCacheOtelFactory();
    return OTelFactory.otelFactory!.createObservableCounter(name, description: description, unit: unit, callback: callback);
  }

  /// Creates an observable gauge instrument
  static APIObservableGauge createObservableGauge(String name, {String? description, String? unit, ObservableCallback? callback}) {
    _getAndCacheOtelFactory();
    return OTelFactory.otelFactory!.createObservableGauge(name, description: description, unit: unit, callback: callback);
  }

  /// Creates an observable up-down counter instrument
  static APIObservableUpDownCounter createObservableUpDownCounter(String name, {String? description, String? unit, ObservableCallback? callback}) {
    _getAndCacheOtelFactory();
    return OTelFactory.otelFactory!.createObservableUpDownCounter(name, description: description, unit: unit, callback: callback);
  }

  /// Creates an observable up-down counter instrument
  static Measurement<T> createMeasurement<T extends num>(T value, [Attributes? attributes]) {
    _getAndCacheOtelFactory();
    return OTelFactory.otelFactory!.createMeasurement(value, attributes);
  }

  static OTelFactory _getAndCacheOtelFactory() {
    if (_otelFactory != null) {
      return _otelFactory!;
    }
    if (OTelFactory.otelFactory == null) {
      throw StateError('initialize() must be called first.');
    }
    _otelFactory = OTelFactory.otelFactory;
    return _otelFactory ?? OTelFactory.otelFactory!;
  }

  /// Reset API state (only public for testing)
  @visibleForTesting
  static void reset() {
    _otelFactory = null;
    OTelFactory.otelFactory?.reset();
    // ignore: invalid_use_of_visible_for_testing_member
    Context.resetRoot();
    // ignore: invalid_use_of_visible_for_testing_member
    Context.resetCurrent();
  }

}
