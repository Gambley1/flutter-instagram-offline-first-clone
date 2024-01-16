import 'dart:developer' as developer;
import 'package:env/env.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Env', () {
    group('Dev', () {
      test('supabase url not null', () {
        expect(EnvDev.supabaseUrl, isNotNull);
        developer.log(EnvDev.supabaseUrl);
      });
      test('supabase anon url not null', () {
        expect(EnvDev.supabaseAnonKey, isNotNull);
        developer.log(EnvDev.supabaseAnonKey);
      });
      test('powersync url not null', () {
        expect(EnvDev.powersyncUrl, isNotNull);
        developer.log(EnvDev.powersyncUrl);
      });
      test('fcm server key not null', () {
        expect(EnvDev.fcmServerKey, isNotNull);
        developer.log(EnvDev.fcmServerKey);
      });
    });
    group('Prod', () {
      test('supabase url not null', () {
        expect(EnvProd.supabaseUrl, isNotNull);
        developer.log(EnvProd.supabaseUrl);
      });
      test('supabase anon url not null', () {
        expect(EnvProd.supabaseAnonKey, isNotNull);
        developer.log(EnvProd.supabaseAnonKey);
      });
      test('powersync url not null', () {
        expect(EnvProd.powersyncUrl, isNotNull);
        developer.log(EnvProd.powersyncUrl);
      });
      test('fcm server key not null', () {
        expect(EnvProd.fcmServerKey, isNotNull);
        developer.log(EnvProd.fcmServerKey);
      });
    });
  });
}
