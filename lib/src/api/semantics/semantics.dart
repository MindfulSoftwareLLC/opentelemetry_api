// Licensed under the Apache License, Version 2.0
// Copyright 2025, Michael Bushe, All rights reserved.

// Base Enum with Custom Constructor
abstract class OTelSemantic {
  final String key;
  const OTelSemantic(this.key);

  @override
  String toString() => key;

}
