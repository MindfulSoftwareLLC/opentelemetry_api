// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

import 'package:meta/meta.dart';

/// Utility class for working with timestamps in OpenTelemetry.
@immutable
class Timestamp {
  /// Returns the current timestamp in nanoseconds since epoch.
  static int now() => DateTime.now().microsecondsSinceEpoch * 1000;

  /// Converts a [DateTime] to nanoseconds since epoch.
  static int fromDateTime(DateTime dateTime) =>
      dateTime.microsecondsSinceEpoch * 1000;

  /// Converts nanoseconds since epoch to a [DateTime].
  static DateTime toDateTime(int nanos) =>
      DateTime.fromMicrosecondsSinceEpoch(nanos ~/ 1000);
}
