<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages). 
-->

# opentelemetry_api
An OpenTelemetry (OTel) API for Dart. 

This API is rarely used without an SDK. The SDK for this API is implemented by 
`dartastic_opentelemetry`, the [Dartastic OTel SDK](https://pub.dev/packages/dartastic_opentelemetry).
To instrument Dart apps, include the latest `dartastic_opentelemetry` and use its `OTel` class.

To instrument Flutter applications use the [Flutterific OTel SDK](https://pub.dev/packages/flutterrific_opentelemetry), 
`flutterrific_opentelemetry` to gain almost automatic instrumentation for app routes, error catching 
and web vitals metrics and much more.  Additional Flutterific OTel SDKs hook into popular Flutter libraries for state management, 
networking, logging, amongst others.  

[Dartastic.io](https://dartastic.io) provides and OpenTelemetry Observability backend for Flutter apps, Dart backends and 
any other service or process that produces OpenTelemetry. Dartastic.io is an observability background built on 
open standards, catering specifically to Flutter and Dart applications with the ability to show Dart source code lines
and function calls from production errors and logs.

Dartastic.io comes with a generous free tier, various levels of free, paid and enterprise support and 
additional pro library features that are not available in the open source offering including telemetry 
that integrates with native code and Real-Time User Monitoring of Flutter apps.  

This Dart API, the Dartastic SDK and Flutterrific OTel are made with 💙 by Michael Bushe at [Mindful Software](https://mindfulsoftware.com).

This `opentelemetry_api` OTel API for Dart exists as a standalone library to strictly adhere to the
OpenTelemetry specification which separates API and the SDK. The specification
requires that the API can be dropped into an app without an SDK and it will work in a no-op fashion. 
You could include just `opentelemetry_api` in your pubspec.yaml top get a no-op implementation
as required by the OTel specification, though this would be a rare use case. Typically, 
backend instrumenters will include `dartastic_opentelemetry` in their pubspec.yaml
and this opentelemetry_api will be a transitive dependency.  Flutter instrumentation developers 
will include `flutterrific_opentelemetry`.

Another direct use for this library is for developers who write instrumentation libraries.  
This OpenTelemetry API is pluggable. You can create your own `OTelFactory` to
implement your own SDK implementation.  See the Dartastic OTel SDK's `OTelSDKFactory`
for an example.

## Features

- Strict adherence to the OpenTelemetry specification.  
  - All SHOULD requirements are implemented.
  - Most, if not all, MAY requirements are implemented.
- No SDK classes are included in this library.  Resource, SpanProcessors, etc. are SDK classes.

## Getting started

Typically, you wouldn't use this library and will use Dartastic OTel `dartastic_opentelemetry` instead to 
get a working OTel implementation in your Dart application.  
include this in your pubspec.yaml:
```
dependencies:
  dartastic_opentelemetry: ^1.0.0
```
See Dartastic.io for more information.

For those that might possibly want a no-op Dart OTel implementation, again, a rare case,
include this in your pubspec.yaml
```
dependencies:
  opentelemetry_api: 1.0.0 #This won't do anything, it's a no-op
```

## Usage

The entrypoint for almost all object creation is the `OTelAPI` class. Again this would be rarely used, instead
use the `OTel` class from `dartastic_opentelemetry` which has the same methods with addition methods
for SDK objects like `Resource` and `SpanProcessor`.

All public constructors are private except the `OTelAPIFactory`.  Use the `OTelAPI` to create all API objects except 
for `Tracer` and `Span`. The OTel specification requires that `TracerProviders` must provide a function for getting
a `Tracer` and that `Span`'s must only be created from a `Tracer`. Some immutable objects can also be created 
by copy `with`, `copyWith` and `copyWithout` methods on those objects such as `Baggage` 
`Baggage copyWith(String key, String value, [String? metadata])` and `Baggage copyWithout(String key)`.

In order to strictly comply with the limited types the OpenTelemetry specification allows 
for `Attribute`s there's no generic `OTelAPI.attribute<T>` creation method and instead, to provide a
typesafe API, there are 8 creation methods for `String`, `bool`, `int`, `double` and `List`s of those types, 
i.e. `OTelAPI.attributeString('foo', 'bar')`, `OTelAPI.attributeIntList('baz', [1, 2, 3])`.

The OTelAPI has additional "factory"-like methods, i.e. `baggageForMap(Map<String, String> keyValuePairs)`.

Example
```dart
//NOTHING HAPPENS BECAUSE THIS USES THE API's OTelAPI, 
//INSTEAD USE THE SDK's OTel methods TO GET WORKING TELEMETRY
Baggage baggage = OTelAPI.baggageForMap({'userId': 'yoda'});
Context context = OTelAPI.context(baggage: baggage);
Context.current = context;
final defaultGlobalAPINOOPTracerProvider = OTelAPI.tracerProvider();
final tracer = defaultGlobalAPINOOPTracerProvider.getTracer('dart-otel-api-example-service');
Span rootSpan = tracer.startSpan('doSomeExampleSpan');
Attributes equalToTheAbove = <String, Object>({
  'example_string_key': 'foo',
  'example_double_key': 42.1,
  'example_bool_list_key': [true, false, true],
  'example_int_list_key': [42, 43, 44],
}).toAttributes();
rootSpan.attributes = equalToTheAbove;
rootSpan.addEventNow('data-retrieved', OTelAPI.attributes([OTelAPI.attributeString('event-foo', 'bar')]));
rootSpan.end(spanStatus: SpanStatusCode.Ok); //Capitalized Ok to match the OTel spec
//NOTHING HAPPENS BECAUSE THIS USES THE API's OTelAPI, 
//INSTEAD USE THE SDK's OTel methods TO GET WORKING TELEMETRY
```
See the `/example` folder for more examples.


## Additional information

- Flutter developers should use the [Flutterific OTel SDK](https://pub.dev/packages/flutterrific_opentelemetry).
- Dart backend developers should use the [Dartastic OTel SDK](https://pub.dev/packages/dartastic_opentelemetry).
- [Dartastic.io](https://dartastic.io/) the Flutter OTel backend
- [The OpenTelemetry Specifiction](https://opentelemetry.io/docs/specs/otel/)
