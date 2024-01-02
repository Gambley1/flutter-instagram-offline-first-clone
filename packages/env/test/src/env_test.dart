import 'package:env/env.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Env', () {
    group('Dev', () {
      test('supabase url not null', () {
        expect(EnvDev.supabaseUrl, isNotNull);
        print(EnvDev.supabaseUrl);
      });
      test('supabase anon url not null', () {
        expect(EnvDev.supabaseAnonKey, isNotNull);
        print(EnvDev.supabaseAnonKey);
      });
      test('powersync url not null', () {
        expect(EnvDev.powersyncUrl, isNotNull);
        print(EnvDev.powersyncUrl);
      });
    });
    group('Prod', () {
      test('supabase url not null', () {
        expect(EnvProd.supabaseUrl, isNotNull);
        print(EnvProd.supabaseUrl);
      });
      test('supabase anon url not null', () {
        expect(EnvProd.supabaseAnonKey, isNotNull);
        print(EnvProd.supabaseAnonKey);
      });
      test('powersync url not null', () {
        expect(EnvProd.powersyncUrl, isNotNull);
        print(EnvProd.powersyncUrl);
      });
    });
  });
}
