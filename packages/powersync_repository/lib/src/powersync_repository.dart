import 'package:env/env.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:powersync/powersync.dart';
import 'package:shared/shared.dart' as shared;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Env value signature that can be used to get an environment value, base
/// on provided [Env].
typedef EnvValue = String Function(Env env);

/// Postgres Response codes that we cannot recover from by retrying.
final List<RegExp> fatalResponseCodes = [
  // Class 22 — Data Exception
  // Examples include data type mismatch.
  RegExp(r'^22...$'),
  // Class 23 — Integrity Constraint Violation.
  // Examples include NOT NULL, FOREIGN KEY and UNIQUE violations.
  RegExp(r'^23...$'),
  // INSUFFICIENT PRIVILEGE - typically a row-level security violation
  RegExp(r'^42501$'),
];

/// Use Supabase for authentication and data upload.
class SupabaseConnector extends PowerSyncBackendConnector {
  /// {@macro supabase_connector}
  SupabaseConnector(this.db, {required this.env});

  /// PowerSync main database.
  final PowerSyncDatabase db;

  /// Environment values.
  final EnvValue env;

  Future<void>? _refreshFuture;

  /// Get a Supabase token to authenticate against the PowerSync instance.
  @override
  Future<PowerSyncCredentials?> fetchCredentials() async {
    // Wait for pending session refresh if any
    await _refreshFuture;

    // Use Supabase token for PowerSync
    final session = Supabase.instance.client.auth.currentSession;
    shared.logD('Session: ${session?.user.toJson()}');
    if (session == null) {
      // Not logged in
      return null;
    }

    // Use the access token to authenticate against PowerSync
    final token = session.accessToken;

    // userId and expiresAt are for debugging purposes only
    final userId = session.user.id;
    final expiresAt = session.expiresAt == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000);
    return PowerSyncCredentials(
      endpoint: env(Env.powerSyncUrl),
      token: token,
      userId: userId,
      expiresAt: expiresAt,
    );
  }

  @override
  void invalidateCredentials() {
    // Trigger a session refresh if auth fails on PowerSync.
    // Generally, sessions should be refreshed automatically by Supabase.
    // However, in some cases it can be a while before the session refresh is
    // retried. We attempt to trigger the refresh as soon as we get an auth
    // failure on PowerSync.
    //
    // This could happen if the device was offline for a while and the session
    // expired, and nothing else attempt to use the session it in the meantime.
    //
    // Timeout the refresh call to avoid waiting for long retries,
    // and ignore any errors. Errors will surface as expired tokens.
    _refreshFuture = Supabase.instance.client.auth
        .refreshSession()
        .timeout(5.seconds)
        .then((response) => null, onError: (error) => null);
  }

  // Upload pending changes to Supabase.
  @override
  Future<void> uploadData(PowerSyncDatabase database) async {
    // This function is called whenever there is data to upload, whether the
    // device is online or offline.
    // If this call throws an error, it is retried periodically.
    final transaction = await database.getNextCrudTransaction();
    if (transaction == null) {
      return;
    }

    final rest = Supabase.instance.client.rest;
    CrudEntry? lastOp;
    try {
      // Note: If transactional consistency is important, use database functions
      // or edge functions to process the entire transaction in a single call.
      for (final op in transaction.crud) {
        lastOp = op;

        final table = rest.from(op.table);
        if (op.op == UpdateType.put) {
          final data = Map<String, dynamic>.of(op.opData!);
          data['id'] = op.id;
          await table.upsert(data);
        } else if (op.op == UpdateType.patch) {
          await table.update(op.opData!).eq('id', op.id);
        } else if (op.op == UpdateType.delete) {
          await table.delete().eq('id', op.id);
        }
      }

      // All operations successful.
      await transaction.complete();
    } on PostgrestException catch (e) {
      if (e.code != null &&
          fatalResponseCodes.any((re) => re.hasMatch(e.code!))) {
        /// Instead of blocking the queue with these errors,
        /// discard the (rest of the) transaction.
        ///
        /// Note that these errors typically indicate a bug in the application.
        /// If protecting against data loss is important, save the failing
        /// records
        /// elsewhere instead of discarding, and/or notify the user.
        shared.logE('Data upload error - discarding $lastOp', error: e);
        await transaction.complete();
      } else {
        /// Error may be retryable - e.g. network error or temporary server
        /// error. Throwing an error here causes this call to be retried after
        /// a delay.
        rethrow;
      }
    }
  }
}

/// {@template power_sync_repository}
/// A package that manages connection to the PowerSync cloud service and
/// database.
///
/// The [PowerSyncRepository] class is responsible for managing the local
/// database and interacting with the Supabase client.
/// {@endtemplate}
class PowerSyncRepository {
  /// Initializes a new instance of the [PowerSyncRepository] class.
  PowerSyncRepository({required this.env});

  /// Environment values.
  final EnvValue env;

  bool _isInitialized = false;

  late final PowerSyncDatabase _db;

  /// The Supabase client.
  late final supabase = Supabase.instance.client;

  /// Initializes the local database and opens a new instance of the database.
  Future<void> initialize({bool offlineMode = false}) async {
    if (!_isInitialized) {
      await _openDatabase();
      _isInitialized = true;
    }
  }

  /// Returns the PowerSync database instance.
  PowerSyncDatabase db() {
    if (!_isInitialized) {
      throw Exception(
        'PowerSyncDatabase not initialized. Call initialize() first.',
      );
    }
    return _db;
  }

  /// Checks if a user is logged in.
  bool isLoggedIn() {
    return supabase.auth.currentSession?.accessToken != null;
  }

  /// Returns the relative directory of the local database.
  Future<String> getDatabasePath() async {
    final dir = await getApplicationSupportDirectory();
    return join(dir.path, 'flutter-instagram-offline-first.db');
  }

  /// Loads the Supabase client with the provided environment values.
  Future<void> _loadSupabase() async {
    await Supabase.initialize(
      url: env(Env.supabaseUrl),
      anonKey: env(Env.supabaseAnonKey),
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.implicit,
      ),
    );
  }

  /// Opens the local database, initializes the Supabase client, and connects
  /// to the database if the user is logged in.
  Future<void> _openDatabase() async {
    _db = PowerSyncDatabase(
      schema: shared.schema,
      path: await getDatabasePath(),
    );
    await _db.initialize();

    await _loadSupabase();

    SupabaseConnector? currentConnector;

    if (isLoggedIn()) {
      currentConnector = SupabaseConnector(_db, env: env);
      await _db.connect(connector: currentConnector);
    }

    supabase.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn ||
          event == AuthChangeEvent.passwordRecovery) {
        shared.logD('Connect to PowerSync');
        currentConnector = SupabaseConnector(_db, env: env);
        await _db.connect(connector: currentConnector!);
      } else if (event == AuthChangeEvent.signedOut) {
        currentConnector = null;
        await _db.disconnect();
      } else if (event == AuthChangeEvent.tokenRefreshed) {
        await currentConnector?.prefetchCredentials();
      }
    });
  }

  /// Returns a stream of authentication state changes from the Supabase client.
  Stream<AuthState> authStateChanges() =>
      supabase.auth.onAuthStateChange.asBroadcastStream();

  /// Updates the user app metadata.
  Future<void> updateUser(Object? data) =>
      supabase.auth.updateUser(UserAttributes(data: data));

  /// Sends a password reset email to the specified email address.
  Future<void> resetPassword({
    required String email,
    String? redirectTo,
  }) =>
      supabase.auth.resetPasswordForEmail(email, redirectTo: redirectTo);

  /// Verifies the OTP token for password recovery.
  Future<void> verifyOTP({
    required String token,
    required String email,
  }) =>
      supabase.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.recovery,
      );
}
