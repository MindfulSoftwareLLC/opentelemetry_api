// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

library attribute_value;

import 'package:meta/meta.dart';
import 'package:collection/collection.dart';

part 'attribute_create.dart';

/// Represents a value for an attribute, associated with an attribute key.
@immutable
class Attribute<T> {
  // For deep equality checks (e.g., for lists)
  static final DeepCollectionEquality _listEquality = DeepCollectionEquality();

  final String _key;
  final T _value;

  Attribute._(String key, T value)
      : _key = key,
        _value = value {
    if (_value == null) {
      throw ArgumentError('Attribute _value must not be null');
    }
    if (_value is String && (_value as String).isEmpty) {
      throw ArgumentError('Attribute _value must not be an empty string');
    }
    if (_value is List) {
      var valueList = (_value as List);
      if (valueList.isEmpty) {
        throw ArgumentError('Attribute _value list must not be empty');
      }
      if (valueList.contains(null)) {
        throw ArgumentError('null is not allowed in List attribute values.');
      }
    }
  }

  String get key => _key;

  T get value => _value;

  @override
  String toString() {
    return 'AttributeValue($_value)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is! Attribute<T>) return false;

    // Use deep equality for lists, otherwise default equality
    final valuesAreEqual = value is List
        ? _listEquality.equals(value, other.value)
        : value == other.value;

    return runtimeType == other.runtimeType && key == other.key && valuesAreEqual;
  }

  @override
  int get hashCode {
    // Use deep hash for lists, otherwise default hash
    final valueHash = value is List ? _listEquality.hash(value) : value.hashCode;
    return Object.hash(key, valueHash);
  }
}
