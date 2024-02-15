import 'dart:convert';
import 'dart:math' as math;

export 'extensions/extensions.dart';

// This alphabet uses `A-Za-z0-9_-` symbols. The genetic algorithm helped
// optimize the gzip compression for this alphabet.
const _alphabet =
    'ModuleSymbhasOwnPr-0123456789ABCDEFGHNRVfgctiUvz_KqYTJkLxpZXIjQW';

/// Generates a random String id
/// Adopted from: https://github.com/ai/nanoid/blob/main/non-secure/index.js
String randomId({int size = 21}) {
  final id = StringBuffer();
  for (var i = 0; i < size; i++) {
    id.write(_alphabet[(math.Random().nextDouble() * 64).floor() | 0]);
  }
  return id.toString();
}

/// Creates a hash string from the passed [objects]
String generateHash(List<Object?> objects) {
  final payload = json.encode(objects);
  final payloadBytes = utf8.encode(payload);
  final payloadB64 = base64.encode(payloadBytes);
  return payloadB64;
}
