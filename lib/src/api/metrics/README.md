# OpenTelemetry Metrics API

The Metrics API in OpenTelemetry provides a way to record measurements about your application. These measurements can be exported later as metrics, allowing you to monitor and analyze the performance and behavior of your application.

## Concepts

- **MeterProvider**: Entry point to the metrics API, responsible for creating Meters
- **Meter**: Used to create instruments for recording measurements
- **Instrument**: Used to record measurements
  - Synchronous instruments: record measurements at the moment of calling their APIs
  - Asynchronous instruments: collect measurements on demand via callbacks

## Instrument Types

- **Counter**: Synchronous, monotonic increasing counter (can only go up)
- **UpDownCounter**: Synchronous, non-monotonic counter (can go up or down)
- **Histogram**: Synchronous, aggregable measurements with statistical distributions
- **Gauge**: Synchronous, non-additive value that represents current state
- **ObservableCounter**: Asynchronous version of Counter
- **ObservableUpDownCounter**: Asynchronous version of UpDownCounter
- **ObservableGauge**: Asynchronous version of Gauge

## Usage Pattern

Similar to the Tracing API, the metrics API follows a multi-layered factory pattern:

1. **API Layer**: Defines interfaces and provides no-op implementations
2. **SDK Layer**: Provides concrete implementations
3. **Flutter Layer**: Adds UI-specific functionality

The API follows the pattern of using factory methods for creation rather than constructors:

```dart
// Get a meter from the meter provider
final meter = OTel.meterProvider().getMeter('component_name');

// Create a counter instrument
final counter = meter.createCounter('my_counter');

// Record measurements
counter.add(1, {'attribute_key': 'attribute_value'});
```

For asynchronous instruments:

```dart
// Create an observable counter
final observableCounter = meter.createObservableCounter(
  'my_observable_counter',
  () => [Measurement(10, {'attribute_key': 'attribute_value'})],
);
```

## Understanding Metric Types and When to Use Them

| Instrument Type | Use Case | Example |
|----------------|----------|---------|
| Counter | Count things that only increase | Request count, completed tasks |
| UpDownCounter | Count things that can increase or decrease | Active requests, queue size |
| Histogram | Measure distributions | Request durations, payload sizes |
| Gauge | Record current value | CPU usage, memory usage |
| ObservableCounter | Count things that only increase, collected on demand | Total CPU time |
| ObservableUpDownCounter | Count things that can increase or decrease, collected on demand | Memory usage |
| ObservableGauge | Record current value, collected on demand | Current temperature |

## Integration with Dartastic/Flutterrific

This API implementation follows the same pattern as the tracing API, where the creation of objects is managed through factory methods. This allows for a clear separation between API and SDK, and ensures that the metrics functionality can be used in a no-op mode when the SDK is not initialized.