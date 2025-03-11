// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

// ignore_for_file: unused_local_variable

import 'package:opentelemetry_api/opentelemetry_api.dart';

void main() {
  OTelAPI.initialize(endpoint: 'http://localhost:4317');
  Attribute<String> stringAttribute = OTelAPI.attributeString('example_string_key', 'foo');
  Attribute<bool> boolAttribute = OTelAPI.attributeBool('example_bool_key', true);
  Attribute<int> intAttr = OTelAPI.attributeInt('example_int_key', 42);
  Attribute<double> doubleAttribute = OTelAPI.attributeDouble('example_double_key', 42.1);
  Attribute<List<String>> stringListAttribute = OTelAPI.attributeStringList('example_string_list_key', ['foo', 'bar', 'baz']);
  Attribute<List<bool>> boolListAttribute = OTelAPI.attributeBoolList('example_bool_key', [true, false, true]);
  Attribute<List<int>> intListAttr = OTelAPI.attributeIntList('example_int_list_key', [42, 43, 44]);
  Attribute<List<double>> doubleListAttribute = OTelAPI.attributeDoubleList('example_double_list_key', [42.0, 42.1, 42.2]);

  OTelAPI.attributes([stringAttribute, boolAttribute, intAttr, doubleAttribute, stringListAttribute, boolListAttribute, intListAttr, doubleListAttribute]);

  Baggage baggage = OTelAPI.baggageForMap({'userId': 'yoda'});
  //set the current context to one with the new baggage
  Context.current = OTelAPI.context(baggage: baggage);
  final defaultGlobalAPINOOPTracerProvider = OTelAPI.tracerProvider();
  final tracer = defaultGlobalAPINOOPTracerProvider.getTracer('dart-otel-api-example-service');
  APISpan rootSpan = tracer.startSpan('doSomeExampleSpan');
  // Same thing as above, more simply but will some loss of type checking
  // If your Map has anything but the types above and exception will be thrown.
  Attributes equalToTheAbove = OTelAPI.attributesFromMap({
    'example_string_key': 'foo',
    'example_bool_key': true,
    'example_int_key': 42,
    'example_double_key': 42.1,
    'example_string_list_key': ['foo', 'bar', 'baz'],
    'example_bool_list_key': [true, false, true],
    'example_int_list_key': [42, 43, 44],
    'example_double_list_key': [42.0, 42.1, 42.2]
  });
  rootSpan.attributes = equalToTheAbove;
  rootSpan.addEventNow('data-retrieved', OTelAPI.attributes([OTelAPI.attributeString('event-foo', 'bar')]));
  rootSpan.end(spanStatus: SpanStatusCode.Ok); //Capitalized Ok to match the OTel spec
}
