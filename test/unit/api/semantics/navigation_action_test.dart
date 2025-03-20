// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:opentelemetry_api/opentelemetry_api.dart';
import 'package:test/test.dart';

void main() {
  group('NavigationAction', () {
    test('should have correct string values', () {
      expect(NavigationAction.push.value, equals('push'));
      expect(NavigationAction.pop.value, equals('pop'));
      expect(NavigationAction.replace.value, equals('replace'));
      expect(NavigationAction.remove.value, equals('remove'));
      expect(NavigationAction.returnTo.value, equals('return_to'));
      expect(NavigationAction.initial.value, equals('initial'));
      expect(NavigationAction.deepLink.value, equals('deep_link'));
      expect(NavigationAction.redirect.value, equals('redirect'));
    });

    test('toString should return the correct value', () {
      expect(NavigationAction.push.toString(), equals('push'));
      expect(NavigationAction.pop.toString(), equals('pop'));
      expect(NavigationAction.replace.toString(), equals('replace'));
      expect(NavigationAction.remove.toString(), equals('remove'));
      expect(NavigationAction.returnTo.toString(), equals('return_to'));
      expect(NavigationAction.initial.toString(), equals('initial'));
      expect(NavigationAction.deepLink.toString(), equals('deep_link'));
      expect(NavigationAction.redirect.toString(), equals('redirect'));
    });
  });
}
