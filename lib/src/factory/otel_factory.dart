// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'dart:typed_data';

import 'package:opentelemetry_api/src/api/metrics/measurement.dart';
import 'package:opentelemetry_api/src/api/trace/span_event.dart';
import 'package:opentelemetry_api/src/api/trace/span_id.dart';
import 'package:opentelemetry_api/src/api/trace/trace_flags.dart';
import 'package:opentelemetry_api/src/api/trace/trace_id.dart';
import 'package:opentelemetry_api/src/api/trace/trace_state.dart';
import 'package:opentelemetry_api/src/api/trace/tracer_provider.dart';
import 'package:opentelemetry_api/src/api/metrics/meter_provider.dart';
import 'package:opentelemetry_api/src/api/metrics/counter.dart';
import 'package:opentelemetry_api/src/api/metrics/gauge.dart';
import 'package:opentelemetry_api/src/api/metrics/histogram.dart';
import 'package:opentelemetry_api/src/api/metrics/up_down_counter.dart';

import '../../opentelemetry_api.dart' show OTelAPI;
import '../api/baggage/baggage.dart';
import '../api/baggage/baggage_entry.dart';
import '../api/common/attribute.dart';
import '../api/common/attributes.dart';
import '../api/context/context.dart';
import '../api/context/context_key.dart';
import '../api/metrics/observable_callback.dart';
import '../api/metrics/observable_counter.dart';
import '../api/metrics/observable_gauge.dart';
import '../api/metrics/observable_up_down_counter.dart';
import '../api/trace/span_context.dart';
import '../api/trace/span_link.dart';

typedef OTelFactoryCreationFunction = OTelFactory Function(
    {required String apiEndpoint,
    required String apiServiceName,
    required String apiServiceVersion});

/// The `OTelFactory` is the plugin mechanism for OpenTelemetry SDK's.
/// The OpenTelemetry specifies that the API must work without any
/// SDK installed.  The API uses the `OTelAPIFactory` as a default.
/// SDKs override this default by registering their own APIFactory
abstract class OTelFactory {
  static const defaultEndpoint = 'http://localhost:4317';

  /// SDKs must replace this otelFactory with their own to get the SDK
  /// object created instead of the API default implementation
  static OTelFactory? otelFactory;
  String _apiEndpoint;
  String _apiServiceName;
  String _apiServiceVersion;
  APITracerProvider? _globalDefaultTracerProvider;
  APIMeterProvider? _globalDefaultMeterProvider;
  Map<String, APITracerProvider>? _tracerProviders;
  Map<String, APIMeterProvider>? _meterProviders;

  /// Used to reproduce the concrete factory
  /// across process boundaries, i.e. isolates
  final OTelFactoryCreationFunction factoryFactory;

  OTelFactory(
      {required String apiEndpoint,
      required String apiServiceName,
      required String apiServiceVersion,
      required this.factoryFactory})
      : _apiServiceVersion = apiServiceVersion,
        _apiServiceName = apiServiceName,
        _apiEndpoint = apiEndpoint;

  set apiEndpoint(String value) {
    _apiEndpoint = value;
  }

  set apiServiceName(String value) {
    _apiServiceName = value;
  }

  set apiServiceVersion(String value) {
    _apiServiceVersion = value;
  }

  /// Serializes the factory configuration into a map, used to
  /// reproduce the factory across execution contexts (isolates)
  Map<String, dynamic> serialize() {
    return {
      'apiEndpoint': _apiEndpoint,
      'apiServiceName': _apiServiceName,
      'apiServiceVersion': _apiServiceVersion,
    };
  }

  /// Deserializes the factory configuration from a map from [serialize], used
  /// to reproduce the factory across execution contexts (isolates)
  static OTelFactory deserialize(
      Map<String, dynamic> data, OTelFactoryCreationFunction factoryFactory) {
    // For example, returning an instance of OTelAPIFactory.
    var oTelFactory = factoryFactory(
      apiEndpoint: data['apiEndpoint'] as String,
      apiServiceName: data['apiServiceName'] as String,
      apiServiceVersion: data['apiServiceVersion'] as String,
    );

    return oTelFactory;
  }

  /// Returns the global default tracer provider
  APITracerProvider globalDefaultTracerProvider() {
    return _globalDefaultTracerProvider ??= tracerProvider(
        endpoint: _apiEndpoint,
        serviceName: _apiServiceName,
        serviceVersion: _apiServiceVersion);
  }

  /// Returns the global default meter provider
  APIMeterProvider globalDefaultMeterProvider() {
    return _globalDefaultMeterProvider ??= meterProvider(
        endpoint: _apiEndpoint,
        serviceName: _apiServiceName,
        serviceVersion: _apiServiceVersion);
  }

  /// This is intended to be used by subclasses in their override
  /// of [tracerProvider] and in created named [APITracerProvider]s.
  APITracerProvider? getNamedTracerProvider(String name) {
    return _tracerProviders?[name];
  }

  /// This is intended to be used by subclasses in their override
  /// of [meterProvider] and in created named [APIMeterProvider]s.
  APIMeterProvider? getNamedMeterProvider(String name) {
    return _meterProviders?[name];
  }

  /// Creates a new TracerProvider referenced by [name] .  If name is null, this returns
  /// the global default [APITracerProvider], if not it returns a
  /// TracerProvider for the name.  If the TracerProvider does not exist,
  /// it is created.
  APITracerProvider addTracerProvider(String name,
      {String? endpoint, String? serviceName, String? serviceVersion}) {
    _tracerProviders ??= {};
    return _tracerProviders![name] ??= tracerProvider(
        endpoint: endpoint ?? _apiEndpoint,
        serviceName: serviceName ?? _apiServiceName,
        serviceVersion: serviceVersion ?? _apiServiceVersion);
  }

  /// Creates a new MeterProvider referenced by [name] .  If name is null, this returns
  /// the global default [APIMeterProvider], if not it returns a
  /// MeterProvider for the name.  If the MeterProvider does not exist,
  /// it is created.
  APIMeterProvider addMeterProvider(String name,
      {String? endpoint, String? serviceName, String? serviceVersion}) {
    _meterProviders ??= {};
    return _meterProviders![name] ??= meterProvider(
        endpoint: endpoint ?? _apiEndpoint,
        serviceName: serviceName ?? _apiServiceName,
        serviceVersion: serviceVersion ?? _apiServiceVersion);
  }

  /// Creates a [APITracerProvider]
  APITracerProvider tracerProvider(
      {required String endpoint, String serviceName, String serviceVersion});

  /// Creates a [APIMeterProvider]
  APIMeterProvider meterProvider(
      {required String endpoint, String serviceName, String serviceVersion});

  /// Creates a new `Context` with optional [Baggage].
  Context context({Baggage? baggage});

  /// Generates a [ContextKey]. Context keys are always unique, even if they
  /// have the same name, per spec.  The name is used for debugging only.
  ContextKey<T> contextKey<T>(String name, Uint8List explicitId);

  /// Creates an `BaggageEntry` with the given `value` and optional `metadata`.
  BaggageEntry baggageEntry(String value, [String? metadata]);

  /// Creates an `Baggage` with the given `name` and `entries`.
  Baggage baggage([Map<String, BaggageEntry>? entries]);

  /// Creates an `Baggage` with the given `keyValuePairs` which
  /// are converted into `BaggageEntry`s without metadata.
  Baggage baggageForMap(Map<String, String> keyValuePairs);

  /// Creates an `AttributeValue` for the given String.
  Attribute<String> attributeString(String key, String value);

  /// Creates an `AttributeValue` for the given boolean.
  Attribute<bool> attributeBool(String key, bool value);

  /// Creates an `AttributeValue` for the given int.
  Attribute<int> attributeInt(String key, int value);

  /// Creates an `AttributeValue` for the given double.
  Attribute<double> attributeDouble(String key, double value);

  /// Creates an `AttributeValue` for the given String.
  Attribute<List<String>> attributeStringList(String key, List<String> value);

  /// Creates an `AttributeValue` for the given boolean.
  Attribute<List<bool>> attributeBoolList(String key, List<bool> value);

  /// Creates an `AttributeValue` for the given int.
  Attribute<List<int>> attributeIntList(String key, List<int> value);

  /// Creates an `AttributeValue` for the given double.
  Attribute<List<double>> attributeDoubleList(String key, List<double> value);

  /// Creates an `Attributes` collection.
  Attributes attributes([List<Attribute>? entries]);

  /// Creates an `Attributes` from a named set of key value pairs;
  /// Values that are, String, bool, int, double,
  /// List\<String>, List\<bool>, List\<int> or List\<double> are used
  /// directly, DateTime is converted to the UTC formatted String,
  /// other values have their toString() used
  Attributes attributesFromMap(Map<String, Object> namedMap);

  /// Creates an `Attributes` from a list of values;
  Attributes attributesFromList(List<Attribute> attributeList);

  /// Creates a new [TraceState] with the provided `entries`
  TraceState traceState(Map<String, String>? entries);

  /// Creates a new TraceFlags with the options flags
  TraceFlags traceFlags([int flags]);

  /// Creates a new [TraceId] either randomly or with the given bytes,
  /// If provided trace bytes must have a length of 16 bytes
  TraceId traceId([Uint8List traceIdBytes]);

  /// Creates an invalid [TraceId]
  TraceId traceIdInvalid();

  /// Creates a new [SpanId] either randomly or with the given bytes,
  /// If provided trace bytes must have a length of 16 bytes
  SpanId spanId([Uint8List spanId]);

  /// Creates an invalid [SpanId]
  SpanId spanIdInvalid();

  /// Creates a [SpanContext] from a parent span context
  SpanContext spanContextFromParent(SpanContext parent);

  /// Creates an invalid [SpanContext] as required by the specification
  SpanContext spanContextInvalid();

  /// Creates a [SpanLink] with the given `spanContext` and `attributes`
  SpanLink spanLink(SpanContext spanContext, {Attributes? attributes});

  /// Creates a [SpanEvent] with the given `name` and `attributes` and a timestamp generated during the call
  SpanEvent spanEventNow(String name, [Attributes? attributes]);

  /// Creates a [SpanEvent] with the given `name` and `attributes` and `timestamp`
  SpanEvent spanEvent(String name, Attributes? attributes, DateTime? timestamp);

  /// Creates a [APICounter] instrument with the given name
  APICounter createCounter(String name, {String? description, String? unit});

  /// Creates a [APIUpDownCounter] instrument with the given name
  APIUpDownCounter createUpDownCounter(String name, {String? description, String? unit});

  /// Creates a [APIGauge] instrument with the given name
  APIGauge createGauge(String name, {String? description, String? unit});

  /// Creates a [APIHistogram] instrument with the given name
  APIHistogram createHistogram(String name, {String? description, String? unit, List<double>? boundaries});

  /// Creates an [APIObservableCounter] instrument with the given name
  APIObservableCounter createObservableCounter(String name, {String? description, String? unit, ObservableCallback? callback});

  /// Creates an [APIObservableGauge] instrument with the given name
  APIObservableGauge createObservableGauge(String name, {String? description, String? unit, ObservableCallback? callback});

  /// Creates an [APIObservableUpDownCounter] instrument with the given name
  APIObservableUpDownCounter createObservableUpDownCounter(String name, {String? description, String? unit, ObservableCallback? callback});


  ///Creates a span context. Random trace and span ids
  ///will be generated if not provided.
  SpanContext spanContext(
      {TraceId? traceId,
      SpanId? spanId,
      SpanId? parentSpanId,
      TraceFlags? traceFlags,
      TraceState? traceState,
      bool? isRemote = false});

  void reset() {
    _apiEndpoint = defaultEndpoint;
    _apiServiceName = OTelAPI.defaultServiceName;
    _apiServiceVersion = OTelAPI.defaultServiceVersion;
    _globalDefaultTracerProvider = null;
    _globalDefaultMeterProvider = null;
    _tracerProviders?.clear();
    _tracerProviders = null;
    _meterProviders?.clear();
    _meterProviders = null;
    otelFactory = null;
  }

  Measurement<T> createMeasurement<T extends num>(T value, [Attributes? attributes]) {
    return MeasurementCreate.create(value, attributes);
  }
}
