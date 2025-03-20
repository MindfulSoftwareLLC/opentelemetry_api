// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:opentelemetry_api/opentelemetry_api.dart';
import 'package:test/test.dart';

// Mock implementation to test abstract class
class TestSemantic extends OTelSemantic {
  const TestSemantic(super.key);
}

void main() {
  group('OTelSemantic', () {
    test('should store key correctly', () {
      const semantic = TestSemantic('test.key');
      expect(semantic.key, equals('test.key'));
    });

    test('toString should return the key', () {
      const semantic = TestSemantic('test.key');
      expect(semantic.toString(), equals('test.key'));
    });
  });
}
