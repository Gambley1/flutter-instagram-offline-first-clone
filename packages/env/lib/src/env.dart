// ignore_for_file: public_member_api_docs

enum Env {
  supabaseUrl('SUPABASE_URL'),
  powerSyncUrl('POWERSYNC_URL'),
  iOSClientId('IOS_CLIENT_ID'),
  webClientId('WEB_CLIENT_ID'),
  fcmServerKey('FCM_SERVER_KEY'),
  supabaseAnonKey('SUPABASE_ANON_KEY');

  const Env(this.value);

  final String value;
}
