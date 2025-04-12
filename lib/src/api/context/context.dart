// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

library context;

import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:meta/meta.dart';
import '../baggage/baggage.dart';
import '../../factory/otel_factory.dart';
import '../trace/span.dart';
import '../trace/span_context.dart';
import 'context_key.dart';

part 'context_create.dart';

//TODO - make sure any construction with contexts share the same traceId

/// Represents the immutable context containing active spans, baggage, and other data.
@immutable
class Context {
  static final _zoneKey = Object();
  static Context? _rootContext;
  static Context? _currentContext;
  static OTelFactory? _otelFactory;

  /// The root context with no values
  static Context get root {
    return _rootContext ??= _getAndCacheOTelFactory().context();
  }

  static OTelFactory _getAndCacheOTelFactory() {
    if (_otelFactory != null) {
      return _otelFactory!;
    }
    if (OTelFactory.otelFactory == null) {
      throw StateError('Call initialize() first.');
    }
    return _otelFactory = OTelFactory.otelFactory!;
  }

  static Context get current {
    return Zone.current[_zoneKey] as Context? ??
        _currentContext ??
        Context.root;
  }

  static set current(Context newContext) {
    _currentContext = newContext;
  }

  /// Clears the current span from the context.
  /// Returns a new context without the span and span context.
  static Context clearCurrentSpan() {
    // Create a new context without span and span context
    final newContext = current.copyWithoutSpan();
    _currentContext = newContext;
    return newContext;
  }

  @visibleForTesting
  static void resetCurrent() {
    _currentContext = ContextCreate.create();
  }

  @visibleForTesting
  static void resetRoot() {
    _rootContext = ContextCreate.create();
  }

  /// The key used to store the active span - inner context keys can never be public, by spec
  static final ContextKey<APISpan> _spanKey =
      ContextKeyCreate.create('span', ContextKey.generateContextKeyId());
  static final ContextKey<SpanContext> _spanContextKey =
      ContextKeyCreate.create('spanContext', ContextKey.generateContextKeyId());
  static final ContextKey<Baggage> _baggageKey =
      ContextKeyCreate.create('baggage', ContextKey.generateContextKeyId());

  /// Creates a new Context.
  /// You cannot create a Context directly; you must use [OTelFactory]:
  /// ```dart
  /// var context = OTelFactory.context(values);
  /// ```
  const Context._(Map<ContextKey, Object?>? contextValues)
      : _values = contextValues ?? const {};

  /// The values stored in this context
  final Map<ContextKey, Object?> _values;

  /// Gets the currently active span in this context, if any
  APISpan? get span => _values[_spanKey] as APISpan?;

  /// Gets the current span from the context.
  ///
  /// Returns null if no span is set in the context.
  SpanContext? get spanContext => get<SpanContext?>(_spanContextKey);

  /// Gets the baggage from the context.
  Baggage? get baggage {
    var baggage = get<Baggage>(_baggageKey);
    return baggage;
  }

  // Returns the current context if it has baggage or makes a copy of the
  // current context with empty Baggage, sets it to Context.current and
  // returns it.
  static Context currentWithBaggage() {
    _getAndCacheOTelFactory();
    if (Context.current.baggage == null) {
      Context.current = Context.current.copyWithBaggage(OTelFactory.otelFactory!.baggage({}));
    }
    return Context.current;
  }

  /// Creates a new Context without a span or span context
  Context copyWithoutSpan() {
    final newValues = Map<ContextKey, Object?>.from(_values);
    newValues.remove(_spanKey);
    newValues.remove(_spanContextKey);
    return ContextCreate.create(contextMap: newValues);
  }

  /// Creates a new context with the given baggage
  /// Send an empty baggage to avoid sending any name/value pairs to an
  /// untrusted process.
  Context withBaggage(Baggage baggage) {
    return copyWith(_baggageKey, baggage);
  }

  /// Creates a new context with the given span context
  Context withSpanContext(SpanContext spanContext) {
    // First check the current span if any
    final currentSpan = get<APISpan?>(_spanKey);
    if (currentSpan != null &&
        currentSpan.spanContext.isValid &&
        spanContext.isValid &&
        currentSpan.spanContext.traceId != spanContext.traceId) {
      throw ArgumentError(
          // ignore: prefer_adjacent_string_concatenation
          'Cannot change trace ID when setting SpanContext. ' +
              'Current trace ID: ${currentSpan.spanContext.traceId}, ' +
              'New trace ID: ${spanContext.traceId}. ' +
              'Use withSpan() for creating child spans.');
    }

    // Then check current span context
    final currentSpanContext = get<SpanContext?>(_spanContextKey);
    if (currentSpanContext != null &&
        currentSpanContext.isValid &&
        spanContext.isValid &&
        currentSpanContext.traceId != spanContext.traceId) {
      throw ArgumentError(
          // ignore: prefer_adjacent_string_concatenation
          'Cannot change trace ID when setting SpanContext. ' +
              'Current trace ID: ${currentSpanContext.traceId}, ' +
              'New trace ID: ${spanContext.traceId}. ' +
              'Use withSpan() for creating child spans.');
    }

    return copyWith(_spanContextKey, spanContext);
  }

  /// Gets the value added for the [ContextKey]
  /// Returns null if no value is set for this key or if the value's type doesn't match T
  T? get<T>(ContextKey<T> key) {
    final value = _values[key];
    if (value == null) return null;
    if (value is T) return value as T;
    return null; // Return null when types don't match instead of throwing
  }

  /// Creates a new Context with the given span set as active
  Context withSpan(APISpan span) {
    // Create a new context with both span and span context
    return ContextCreate.create(contextMap: {
      ..._values,
      _spanKey: span,
      _spanContextKey: span.spanContext,
    });
  }

  /// Sets this context as the current context with the given span active.
  /// This is separate from span creation as per the specification.
  Context setCurrentSpan(APISpan? span) {
    Context newContext;
    if (span == null) {
      // Remove both span and span context
      newContext = ContextCreate.create(
          contextMap: Map.from(_values)
            ..remove(_spanKey)
            ..remove(_spanContextKey));
    } else {
      // Set both span and span context
      newContext = ContextCreate.create(contextMap: {
        ..._values,
        _spanKey: span,
        _spanContextKey: span.spanContext,
      });
    }
    _currentContext = newContext;
    return newContext;
  }

  /// Creates a new Context with the specified value for the given key
  Context copyWithValue<T>(String name, T contextValue) {
    return ContextCreate.create(contextMap: {
      ..._values,
      _getAndCacheOTelFactory()
          .contextKey<T>(name, ContextKey.generateContextKeyId()): contextValue,
    });
  }

  /// Creates a new Context with the specified value for the given key
  Context copyWith<T>(ContextKey<T> key, T value) {
    return ContextCreate.create(contextMap: {
      ..._values,
      key: value,
    });
  }

  /// Creates a new Context adding in [moreBaggage], replacing any existing
  /// keys that are the same as the keys in [moreBaggage]
  Context copyWithBaggage(Baggage moreBaggage) {
    var currentBaggage = baggage;
    Baggage newBaggage = currentBaggage == null
        ? moreBaggage
        : currentBaggage.copyWithBaggage(moreBaggage);
    return ContextCreate.create(contextMap: {
      ..._values,
      _baggageKey: newBaggage,
    });
  }

  /// Creates a new Context adding in [moreBaggage], replacing any existing
  /// keys that are the same as the keys in [moreBaggage]
  Context copyWithSpanContext(SpanContext spanContext) {
    var newContext = ContextCreate.create(contextMap: {
      ..._values,
      _spanContextKey: spanContext,
    });
    return newContext;
  }

  /// Run an operation in a zone with this context
  Future<T> run<T>(Future<T> Function() operation) {
    return runZoned(
      operation,
      zoneValues: {_zoneKey: this},
    );
  }

  Future<T> runIsolate<T>(Future<T> Function() computation) async {
    final oldFactory = _getAndCacheOTelFactory();
    // Capture the parent's factory configuration and serialize it.
    final serializedFactory = oldFactory.serialize();

    // Capture the parent's context and serialize it.
    final originalContext = current;
    final serializedContext = current.serialize();
    final OTelFactoryCreationFunction factoryFactory =
        oldFactory.factoryFactory;

    try {
      return await Isolate.run(() async {
        // Deserialize the factory and assign it to the static field.
        OTelFactory.otelFactory =
            OTelFactory.deserialize(serializedFactory, factoryFactory);
        // In the new isolate, deserialize the parent's context.
        final isolateContext = deserialize(serializedContext);
        Context.current = isolateContext;
        // Set the static context variables in the new isolate.
        _currentContext = isolateContext;
        _rootContext ??= isolateContext;

        // Run the computation in a zone that carries the deserialized context.
        return runZoned(
          () => computation(),
          zoneValues: {_zoneKey: isolateContext},
        );
      });
    } finally {
      // Restore the parent's current context after the isolate call returns.
      _currentContext = originalContext;
    }
  }

  Map<String, dynamic> serialize() {
    final values = <String, dynamic>{};
    final keyNamesCount = <String, int>{};

    // Only serialize baggage if it has entries
    var currentBaggage = baggage;
    if (currentBaggage != null && currentBaggage.getAllEntries().isNotEmpty) {
      values['baggage'] = currentBaggage.toJson();
    }

    // Only serialize span context if not null
    if (spanContext != null) {
      values['spanContext'] = spanContext!.toJson();
    }

    // Serialize remaining context values with their unique IDs
    _values.forEach((key, value) {
      if (key != _baggageKey && key != _spanKey && key != _spanContextKey) {
        try {
          // Try to encode to JSON to test serializability
          json.encode(value);

          // If we get here, the value is serializable
          // Handle multiple keys with the same name
          String finalKeyName = key.name;

          // If we've seen this key name before, make it unique
          keyNamesCount[key.name] = (keyNamesCount[key.name] ?? 0) + 1;
          if (keyNamesCount[key.name]! > 1) {
            finalKeyName = '${key.name}-${keyNamesCount[key.name]}';
          }

          // Create a composite key entry that includes both name and uniqueId
          values[finalKeyName] = {
            'value': value,
            'uniqueId': key.uniqueId,
            'originalKeyName': key.name, // Store original key name for deserialization
          };
        } catch (e) {
          // Value is not serializable, skip it
        }
      }
    });

    return values;
  }

  static Context deserialize(Map<String, dynamic> values) {
    _getAndCacheOTelFactory();
    var context = _otelFactory!.context();

    // Handle baggage if present and not empty
    if (values.containsKey('baggage')) {
      final baggageValue = values['baggage'];
      if (baggageValue is Map<String, dynamic> && baggageValue.isNotEmpty) {
        final baggage = Baggage.fromJson(baggageValue);
        context = context.copyWith(_baggageKey, baggage);
      }
    }

    // Handle span context if present and not null
    if (values.containsKey('spanContext')) {
      final spanContextValue = values['spanContext'];
      if (spanContextValue is Map<String, dynamic>) {
        final spanContext = SpanContext.fromJson(spanContextValue);
        context = context.copyWith(_spanContextKey, spanContext);
      }
    }

    // Handle remaining values
    values.forEach((key, value) {
      if (key != 'baggage' && key != 'spanContext') {
        if (value is Map<String, dynamic> && value.containsKey('uniqueId')) {
          final uniqueIdList =
              Uint8List.fromList((value['uniqueId'] as List).cast<int>());

          // Get the original key name if available, otherwise use the key
          final keyName = value.containsKey('originalKeyName') ?
              value['originalKeyName'] as String : key;

          // Note: Two keys with same name but different uniqueIds are valid and distinct

          // Recreate the context key with the same name and uniqueId
          final contextKey = OTelFactory.otelFactory!.contextKey(
            keyName,
            uniqueIdList,
          );
          context = context.copyWith(contextKey, value['value']);
        }
      }
    });

    return context;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Context) return false;
    if (_values.length != other._values.length) return false;
    for (final key in _values.keys) {
      if (!other._values.containsKey(key)) return false;
      if (_values[key] != other._values[key]) return false;
    }
    return true;
  }

  @override
  int get hashCode {
    // Create a consistent hash based on the values and keys
    // Sort the keys for consistency
    final sortedEntries = _values.entries.toList()
      ..sort((a, b) => a.key.toString().compareTo(b.key.toString()));

    return Object.hashAll([
      for (final entry in sortedEntries)
        Object.hash(entry.key, entry.value)
    ]);
  }
}
