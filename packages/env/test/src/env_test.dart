import 'package:env/env.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared/shared.dart';

void main() {
  group('Env', () {
    group('Dev', () {
      test('supabase url not null', () {
        expect(EnvDev.supabaseUrl, isNotNull);
        logD(EnvDev.supabaseUrl);
      });
      test('supabase anon url not null', () {
        expect(EnvDev.supabaseAnonKey, isNotNull);
        logD(EnvDev.supabaseAnonKey);
      });
      test('powersync url not null', () {
        expect(EnvDev.powersyncUrl, isNotNull);
        logD(EnvDev.powersyncUrl);
      });
      test('fcm server key not null', () {
        expect(EnvDev.fcmServerKey, isNotNull);
        logD(EnvDev.fcmServerKey);
      });
      test('ios client id not null', () {
        expect(EnvDev.iOSClientId, isNotNull);
        logD(EnvDev.iOSClientId);
      });
      test('web client id not null', () {
        expect(EnvDev.webClientId, isNotNull);
        logD(EnvDev.webClientId);
      });
    });
    group('Prod', () {
      test('supabase url not null', () {
        expect(EnvProd.supabaseUrl, isNotNull);
        logD(EnvProd.supabaseUrl);
      });
      test('supabase anon url not null', () {
        expect(EnvProd.supabaseAnonKey, isNotNull);
        logD(EnvProd.supabaseAnonKey);
      });
      test('powersync url not null', () {
        expect(EnvProd.powersyncUrl, isNotNull);
        logD(EnvProd.powersyncUrl);
      });
      test('fcm server key not null', () {
        expect(EnvProd.fcmServerKey, isNotNull);
        logD(EnvProd.fcmServerKey);
      });
      test('ios client id not null', () {
        expect(EnvProd.iOSClientId, isNotNull);
        logD(EnvProd.iOSClientId);
      });
      test('web client id not null', () {
        expect(EnvProd.webClientId, isNotNull);
        logD(EnvProd.webClientId);
      });
    });
  });
}
