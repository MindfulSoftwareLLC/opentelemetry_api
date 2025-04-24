// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

part of attributes;

class AttributesCreate {
  static Attributes create<T>(List<Attribute> entries) {
    return Attributes._(entries);
  }
}
