// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

part of attribute_value;

class AttributeCreate<T extends Object> {
  static Attribute<T> create<T>(String name, T value) {
    return Attribute._(name, value);
  }
}
