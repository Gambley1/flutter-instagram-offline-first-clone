import 'package:env/env.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared/shared.dart';

void main() {
  group('Env', () {
    group('Dev', () {
      test('supabase url not null', () {
        expect(EnvDev.supabaseUrl, isNotNull);
        logI(EnvDev.supabaseUrl);
      });
      test('supabase anon url not null', () {
        expect(EnvDev.supabaseAnonKey, isNotNull);
        logI(EnvDev.supabaseAnonKey);
      });
      test('powersync url not null', () {
        expect(EnvDev.powersyncUrl, isNotNull);
        logI(EnvDev.powersyncUrl);
      });
      test('fcm server key not null', () {
        expect(EnvDev.fcmServerKey, isNotNull);
        logI(EnvDev.fcmServerKey);
      });
      test('ios client id not null', () {
        expect(EnvDev.iOSClientId, isNotNull);
        logI(EnvDev.iOSClientId);
      });
      test('web client id not null', () {
        expect(EnvDev.webClientId, isNotNull);
        logI(EnvDev.webClientId);
      });
    });
    group('Prod', () {
      test('supabase url not null', () {
        expect(EnvProd.supabaseUrl, isNotNull);
        logI(EnvProd.supabaseUrl);
      });
      test('supabase anon url not null', () {
        expect(EnvProd.supabaseAnonKey, isNotNull);
        logI(EnvProd.supabaseAnonKey);
      });
      test('powersync url not null', () {
        expect(EnvProd.powersyncUrl, isNotNull);
        logI(EnvProd.powersyncUrl);
      });
      test('fcm server key not null', () {
        expect(EnvProd.fcmServerKey, isNotNull);
        logI(EnvProd.fcmServerKey);
      });
      test('ios client id not null', () {
        expect(EnvProd.iOSClientId, isNotNull);
        logI(EnvProd.iOSClientId);
      });
      test('web client id not null', () {
        expect(EnvProd.webClientId, isNotNull);
        logI(EnvProd.webClientId);
      });
    });
  });
}
