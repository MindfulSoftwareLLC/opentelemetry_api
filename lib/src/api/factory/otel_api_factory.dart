// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'dart:typed_data';
import 'package:opentelemetry_api/src/api/baggage/baggage.dart';
import 'package:opentelemetry_api/src/factory/otel_factory.dart';
import 'package:opentelemetry_api/src/api/trace/span_context.dart';
import 'package:opentelemetry_api/src/api/trace/span_event.dart';
import 'package:opentelemetry_api/src/api/trace/span_id.dart';
import 'package:opentelemetry_api/src/api/trace/span_link.dart';
import 'package:opentelemetry_api/src/api/trace/trace_flags.dart';
import 'package:opentelemetry_api/src/api/trace/trace_id.dart';
import 'package:opentelemetry_api/src/api/trace/trace_state.dart';
import 'package:opentelemetry_api/src/api/trace/tracer_provider.dart';
import 'package:opentelemetry_api/src/api/metrics/meter_provider.dart';
import 'package:opentelemetry_api/src/api/metrics/counter.dart';
import 'package:opentelemetry_api/src/api/metrics/gauge.dart';
import 'package:opentelemetry_api/src/api/metrics/histogram.dart';
import 'package:opentelemetry_api/src/api/metrics/up_down_counter.dart';
import 'package:opentelemetry_api/src/api/metrics/observable_counter.dart';
import 'package:opentelemetry_api/src/api/metrics/observable_gauge.dart';
import 'package:opentelemetry_api/src/api/metrics/observable_up_down_counter.dart';

import '../../util/date_util.dart';
import '../baggage/baggage_entry.dart';
import '../common/attribute.dart';
import '../common/attributes.dart';
import '../context/context.dart';
import '../context/context_key.dart';
import '../id/id_generator.dart';
import '../metrics/meter.dart';
import '../metrics/observable_callback.dart';

OTelFactory otelApiFactoryFactoryFunction({
  required String apiEndpoint,
  required String apiServiceName,
  required String apiServiceVersion,
}) {
  return OTelAPIFactory(
    apiEndpoint: apiEndpoint,
    apiServiceName: apiServiceName,
    apiServiceVersion: apiServiceVersion,
  );
}

/// The factory used when no SDK is installed. The OpenTelemetry specification
/// requires the API to work without an SDK installed
/// All construction APIs use the factory, such as builders or 'from' helpers.
class OTelAPIFactory extends OTelFactory {

  OTelAPIFactory(
      {required super.apiEndpoint,
      required super.apiServiceName,
      required super.apiServiceVersion,
      OTelFactoryCreationFunction? factoryFactory =
          otelApiFactoryFactoryFunction})
      : super(factoryFactory: factoryFactory!);

  @override
  BaggageEntry baggageEntry(String value, [String? metadata]) {
    return BaggageEntryFactory.create(value, metadata);
  }

  @override
  Baggage baggage([Map<String, BaggageEntry>? entries]) {
    return BaggageCreate.create(entries);
  }

  @override
  Context context({Baggage? baggage}) {
    return ContextCreate.create(baggage: baggage);
  }

  @override
  ContextKey<T> contextKey<T>(String name, Uint8List id) {
    return ContextKeyCreate.create(name, id);
  }

  @override
  APITracerProvider tracerProvider(
      {required String endpoint,
      String serviceName = "@dart/opentelemetry_api",
      String? serviceVersion = '1.11.0.0'}) {
    return TracerProviderCreate.create(
        endpoint: endpoint,
        serviceName: serviceName,
        serviceVersion: serviceVersion);
  }

  @override
  APIMeterProvider meterProvider(
      {required String endpoint,
      String serviceName = "@dart/opentelemetry_api",
      String? serviceVersion = '1.11.0.0'}) {
    return MeterProviderCreate.create(
        endpoint: endpoint,
        serviceName: serviceName,
        serviceVersion: serviceVersion);
  }

  @override
  Attributes attributes([List<Attribute>? entries]) {
    return AttributesCreate.create(entries ?? []);
  }

  @override
  Attributes attributesFromList(List<Attribute> attributeList) {
    return AttributesCreate.create(attributeList);
  }

  @override
  Attributes attributesFromMap(Map<String, Object> namedMap) {
    /// Cheating a bit since Attribute is unlikely to be overriden
    /// in a factory but likely to be used for initialize();
    return attrsFromMap(namedMap);
  }

  static Attributes attrsFromMap(Map<String, Object> namedMap) {
    /// Cheating a bit since Attribute is unlikely to be overriden
    /// in a factory but likely to be used for initialize();
    final attributes = <Attribute>[];
    namedMap.forEach((key, value) {
      if (value is String) {
        if (value.isNotEmpty) {
          attributes.add(AttributeCreate.create(key, value));
        }
      } else if (value is int) {
        attributes.add(AttributeCreate.create(key, value));
      } else if (value is double) {
        attributes.add(AttributeCreate.create(key, value));
      } else if (value is bool) {
        attributes.add(AttributeCreate.create(key, value));
      } else if (value is DateTime) {
        String isoTimestamp = dateTimeToString(value);
        attributes
            .add(AttributeCreate.create(key, isoTimestamp));
      } else if (value is Attribute) {
        attributes.add(value);
      } else if (value is List) {
        if (value.isNotEmpty) {
          if (value.first is String) {
            attributes.add(AttributeCreate.create(key, value as List<String>));
          } else if (value.first is bool) {
            attributes.add(AttributeCreate.create(key, value as List<bool>));
          } else if (value.first is int) {
            attributes.add(AttributeCreate.create(key, value as List<int>));
          } else if (value.first is double) {
            attributes.add(AttributeCreate.create(key, value as List<double>));
          }
        }
      } else {
        attributes
            .add(AttributeCreate.create(key, '$value'));
      }
    });
    return AttributesCreate.create(attributes);
  }

  /// Creates an `AttributeValue` for the given String.
  @override
  Attribute<String> attributeString(String key, String value) {
    return AttributeCreate.create(key, value);
  }

  /// Creates an `AttributeValue` for the given boolean.
  @override
  Attribute<bool> attributeBool(String key, bool value) {
    return AttributeCreate.create(key, value);
  }

  /// Creates an `AttributeValue` for the given int.
  @override
  Attribute<int> attributeInt(String key, int value) {
    return AttributeCreate.create(key, value);
  }

  /// Creates an `AttributeValue` for the given double.
  @override
  Attribute<double> attributeDouble(String key, double value) {
    return AttributeCreate.create(key, value);
  }

  /// Creates an `AttributeValue` for the given String.
  @override
  Attribute<List<String>> attributeStringList(String key, List<String> value) {
    return AttributeCreate.create(key, value);
  }

  /// Creates an `AttributeValue` for the given boolean.
  @override
  Attribute<List<bool>> attributeBoolList(String key, List<bool> value) {
    return AttributeCreate.create(key, value);
  }

  /// Creates an `AttributeValue` for the given int.
  @override
  Attribute<List<int>> attributeIntList(String key, List<int> value) {
    return AttributeCreate.create(key, value);
  }

  /// Creates an `AttributeValue` for the given double.
  @override
  Attribute<List<double>> attributeDoubleList(String key, List<double> value) {
    return AttributeCreate.create(key, value);
  }

  @override
  TraceId traceId([Uint8List? traceIdBytes]) {
    traceIdBytes ??= IdGenerator.generateTraceId();
    return TraceIdCreate.create(traceIdBytes);
  }

  @override
  SpanId spanId([Uint8List? spanId]) {
    spanId ??= IdGenerator.generateSpanId();
    return SpanIdCreate.create(spanId);
  }

  @override
  TraceId traceIdInvalid() {
    return TraceIdCreate.create(TraceId.invalidTraceIdBytes);
  }

  @override
  SpanId spanIdInvalid([Uint8List? spanId]) {
    return SpanIdCreate.create(SpanId.invalidSpanIdBytes);
  }

  @override
  TraceState traceState(Map<String, String>? entries) {
    return TraceStateCreate.create(entries);
  }

  @override
  TraceFlags traceFlags([int? flags]) {
    return TraceFlagsCreate.create(flags);
  }

  @override
  SpanContext spanContext(
      {TraceId? traceId,
      SpanId? spanId,
      SpanId? parentSpanId,
      TraceFlags? traceFlags,
      TraceState? traceState,
      bool? isRemote}) {
    return SpanContextCreate.create(
        traceId: traceId,
        spanId: spanId,
        parentSpanId: parentSpanId,
        traceFlags: traceFlags,
        traceState: traceState,
        isRemote: isRemote);
  }

  @override
  SpanContext spanContextFromParent(SpanContext parent) {
    return spanContext(
      traceId: parent.traceId,
      // MUST inherit trace ID from parent
      spanId: spanId(),
      // Generate new span ID
      parentSpanId: parent.spanId,
      // Set parent's span ID as parent
      traceFlags: parent.traceFlags,
      // Inherit trace flags
      traceState: parent.traceState,
      // Inherit trace state
      isRemote: false, // Local spans are not remote
    );
  }

  @override
  SpanContext spanContextInvalid() {
    return spanContext(
      traceId: traceIdInvalid(),
      spanId: spanIdInvalid(),
    );
  }

  @override
  SpanLink spanLink(SpanContext spanContext, {Attributes? attributes}) {
    return SpanLinkCreate.create(
        spanContext: spanContext, attributes: attributes);
  }

  @override
  SpanEvent spanEvent(String name,
      [Attributes? attributes, DateTime? timestamp]) {
    return SpanEventCreate.create(
      name: name,
      attributes: attributes,
      timestamp: timestamp ?? DateTime.now(),
    );
  }

  @override
  SpanEvent spanEventNow(String name, [Attributes? attributes]) {
    return SpanEventCreate.create(
        name: name, timestamp: DateTime.now(), attributes: attributes);
  }

  @override
  APICounter createCounter(String name, {String? description, String? unit}) {
    return CounterCreate.create(
      name: name,
      description: description,
      unit: unit,
      enabled: false, // API implementation is always disabled
      meter: APIMeterCreate.create(name: '@api/default'),
    );
  }

  @override
  APIUpDownCounter createUpDownCounter(String name, {String? description, String? unit}) {
    return UpDownCounterCreate.create(
      name: name,
      description: description,
      unit: unit,
      enabled: false, // API implementation is always disabled
      meter: APIMeterCreate.create(name: '@api/default'),
    );
  }

  @override
  APIGauge createGauge(String name, {String? description, String? unit}) {
    return GaugeCreate.create(
      name: name,
      description: description,
      unit: unit,
      enabled: false, // API implementation is always disabled
      meter: APIMeterCreate.create(name: '@api/default'),
    );
  }

  @override
  APIHistogram createHistogram(String name, {String? description, String? unit, List<double>? boundaries}) {
    return HistogramCreate.create(
      name: name,
      description: description,
      unit: unit,
      enabled: false, // API implementation is always disabled
      meter: APIMeterCreate.create(name: '@api/default'),
      boundaries: boundaries,
    );
  }

  @override
  APIObservableCounter createObservableCounter(String name, {String? description, String? unit, ObservableCallback? callback}) {
    return ObservableCounterCreate.create(
      name: name,
      description: description,
      unit: unit,
      enabled: false, // API implementation is always disabled
      meter: APIMeterCreate.create(name: '@api/default'),
      callback: callback,
    );
  }

  @override
  APIObservableGauge createObservableGauge(String name, {String? description, String? unit, ObservableCallback? callback}) {
    return ObservableGaugeCreate.create(
      name: name,
      description: description,
      unit: unit,
      enabled: false, // API implementation is always disabled
      meter: APIMeterCreate.create(name: '@api/default'),
      callback: callback,
    );
  }

  @override
  APIObservableUpDownCounter createObservableUpDownCounter(String name, {String? description, String? unit, ObservableCallback? callback}) {
    return ObservableUpDownCounterCreate.create(
      name: name,
      description: description,
      unit: unit,
      enabled: false, // API implementation is always disabled
      meter: APIMeterCreate.create(name: '@api/default'),
      callback: callback,
    );
  }

  @override
  Baggage baggageForMap(Map<String, String> keyValuePairs) {
    Map<String, BaggageEntry> entries = {};
    for (String key in keyValuePairs.keys) {
      entries[key] = baggageEntry(keyValuePairs[key]!);
    }
    return baggage(entries);
  }
}
