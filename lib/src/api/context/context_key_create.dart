// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

part of context_key;

class ContextKeyCreate<T> {
  static ContextKey<T> create<T>(String name, Uint8List id) {
    return ContextKey<T>._(name, id);
  }
}
