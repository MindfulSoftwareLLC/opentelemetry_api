// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

part of 'tracer_provider.dart';

/// Internal constructor access for TracerProvider
class TracerProviderCreate {
  /// Creates a TracerProvider, only accessible within library
  static APITracerProvider create({required String endpoint, String serviceName = "@dart/opentelemetry_api", String? serviceVersion = '1.11.0.0'}) {
    return APITracerProvider._(endpoint: endpoint, serviceName: serviceName, serviceVersion: serviceVersion, enabled: true, isShutdown: false);
  }
}
