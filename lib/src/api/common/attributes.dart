// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

library attributes;

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import '../../../opentelemetry_api.dart';

part 'attributes_create.dart';

/// A collection of attributes that are immutable and type-safe.
/// Create with the OTelFactory methods.
@immutable
class Attributes {
  final Map<String, Attribute> _entries = {};

  /// Private constructor to enforce immutability.
  Attributes._(List<Attribute> entries) {
    for (var attr in entries) {
      _entries[attr.key] = attr;
    }
  }

  List<String> get keys => List.unmodifiable(_entries.keys);

  /// Returns all attributes as a read-only List.
  List<Attribute> toList() => List.unmodifiable(_entries.values);

  /// Returns all attributes as a read-only map.
  Map<String, Attribute> toMap() => Map.unmodifiable(_entries);

  bool get isEmpty => _entries.isEmpty;

  String? getString(String name) => _getTyped<String>(name);

  bool? getBool(String name) => _getTyped<bool>(name);

  int? getInt(String name) => _getTyped<int>(name);

  double? getDouble(String name) => _getTyped<double>(name);

  List<String>? getStringList(String name) => _getTyped<List<String>>(name);

  List<bool>? getBoolList(String name) => _getTyped<List<bool>>(name);

  List<int>? getIntList(String name) => _getTyped<List<int>>(name);

  List<double>? getDoubleList(String name) => _getTyped<List<double>>(name);

  int get length => _entries.length;

  /// Returns the value associated with the given [key], or null if not present.
  T? _getTyped<T>(String key) {
    final attribute = _entries[key];
    if (attribute == null) return null;

    // Ensure the value matches the expected type `T`
    if (attribute.value is T) {
      return attribute.value as T;
    } else {
      throw StateError('Value for key "$key" is not of type ${T.runtimeType}');
    }
  }

  /// Makes a copy of the attributes, overwriting keys if they are the same
  Attributes copyWithStringAttribute(String name, String value) {
    return AttributesCreate.create([
      ..._entries.values,
      AttributeCreate.create(name, value),
    ]);
  }

  Attributes withBoolAttribute(String name, bool value) {
    return AttributesCreate.create([
      ..._entries.values,
      AttributeCreate.create(name, value),
    ]);
  }

  Attributes copyWithIntAttribute(String name, int value) {
    return AttributesCreate.create([
      ..._entries.values,
      AttributeCreate.create(name, value),
    ]);
  }

  Attributes copyWithDoubleAttribute(String name, double value) {
    return AttributesCreate.create([
      ..._entries.values,
      AttributeCreate.create(name, value),
    ]);
  }

  Attributes copyWithStringListAttribute(String name, List<String> value) {
    return AttributesCreate.create([
      ..._entries.values,
      AttributeCreate.create(name, value),
    ]);
  }

  Attributes copyWithBoolListAttribute(String name, List<bool> value) {
    return AttributesCreate.create([
      ..._entries.values,
      AttributeCreate.create(name, value),
    ]);
  }

  Attributes copyWithIntListAttribute(String name, List<int> value) {
    return AttributesCreate.create([
      ..._entries.values,
      AttributeCreate.create(name, value),
    ]);
  }

  Attributes copyWithDoubleListAttribute(String name, List<double> value) {
    return AttributesCreate.create([
      ..._entries.values,
      AttributeCreate.create(name, value),
    ]);
  }

  /// Adds entries to this Attributes, overwriting existing when keys match,
  /// returning a new immutable Attributes
  Attributes copyWith(List<Attribute> other) {
    if (other.isEmpty) {
      return this;
    }
    final newEntries = {
      ..._entries,
    };
    for (var attr in other) {
      newEntries[attr.key] = attr;
    }
    return AttributesCreate.create(newEntries.values.toList());
  }

  /// Adds other entries to this Attributes, overwriting existing when
  /// keys match, returning a new immutable Attributes
  Attributes copyWithAttributes(Attributes other) {
    return copyWith(other.toList());
  }

  /// Removes an attribute by key and returns a new immutable [Attributes] instance.
  Attributes copyWithout(String key) {
    if (!_entries.containsKey(key)) return this; // Nothing to remove
    final newEntries = Map<String, Attribute>.from(_entries);
    newEntries.remove(key);
    return AttributesCreate.create(newEntries.values.toList());
  }

  @override
  String toString() => _entries.toString();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Attributes) return false;

    // Use deep equality for the map
    const equality = MapEquality<String, Attribute>();
    return equality.equals(_entries, other._entries);
  }

  @override
  int get hashCode => const MapEquality<String, Attribute>().hash(_entries);
}

/// Extension to create Attributes from a simple Map
extension AttributesExtension on Map<String, Object> {
  /// Convert this map to Attributes
  /// Empty string are not allowed and are skipped
  Attributes toAttributes() {

    if (OTelFactory.otelFactory == null) {
      // Cheating here since Attributes is unlikely to be overriden in a
      // factory and is often called before initialize
      return OTelAPI.attributesFromMap(this);
    }
    return OTelFactory.otelFactory!.attributesFromMap(this);
  }
}
