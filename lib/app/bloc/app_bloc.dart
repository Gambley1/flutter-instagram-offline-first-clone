import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_notifications_client/firebase_notifications_client.dart';
import 'package:powersync_repository/powersync_repository.dart';
import 'package:shared/shared.dart';
import 'package:user_repository/user_repository.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc({
    required UserRepository userRepository,
    required FirebaseNotificationsClient notificationsClient,
    required User user,
  })  : _userRepository = userRepository,
        _notificationsClient = notificationsClient,
        super(
          user == User.anonymous
              ? const AppState.unauthenticated()
              : AppState.authenticated(user),
        ) {
    on<AppOpened>(_onAppOpened);
    on<AppLogoutRequested>(_onAppLogoutRequested);
    on<AppUserChanged>(_onUserChanged);
    on<_AppAuthenticate>(_onAppAuthenticate);
    on<_AppUnauthenticate>(_onAppUnauthenticate);

    _userSubscription =
        userRepository.user.listen(_userChanged, onError: addError);
  }

  final UserRepository _userRepository;
  final FirebaseNotificationsClient _notificationsClient;

  StreamSubscription<AuthState>? _authStateChangesSubscription;
  StreamSubscription<User>? _userSubscription;
  StreamSubscription<String>? _pushTokenSubscription;

  void _userChanged(User user) => add(AppUserChanged(user));

  Future<void> _onUserChanged(
    AppUserChanged event,
    Emitter<AppState> emit,
  ) async {
    final user = event.user;
    logD('User changed: ${user.toJson()}');

    Future<void> authenticate(User user) async {
      user == User.anonymous
          ? emit(const AppState.unauthenticated())
          : emit(AppState.authenticated(user));
    }

    switch (state.status) {
      case AppStatus.unknown:
      case AppStatus.authenticated:
        await authenticate(user);
      case AppStatus.unauthenticated:
        await authenticate(user);
    }
  }

  Future<void> _onAppOpened(AppOpened event, Emitter<AppState> emit) async {
    await _notificationsClient.requestPermission();

    // final newPushToken = await _notificationsClient.getToken();
    // await _userRepository.updateUser(pushToken: newPushToken);

    _pushTokenSubscription =
        _notificationsClient.onTokenRefresh().listen((pushToken) async {
      await _userRepository.updateUser(pushToken: pushToken);
    });

    _authStateChangesSubscription =
        _userRepository.authStateChanges().listen((authState) async {
      final event = authState.event;
      final aud = authState.session?.user.toJson()['aud'] as String?;

      final authenticated =
          aud == 'authenticated' || event == AuthChangeEvent.signedIn;
      final unauthenticated = event == AuthChangeEvent.signedOut;

      if (authenticated) {
        add(const _AppAuthenticate());
        return;
      }
      if (event == AuthChangeEvent.tokenRefreshed) {
        if (authenticated) {
          add(const _AppAuthenticate());
          return;
        }
      }
      if (unauthenticated) {
        add(const _AppUnauthenticate());
      }
    });
  }

  Future<void> _onAppAuthenticate(
    _AppAuthenticate event,
    Emitter<AppState> emit,
  ) async {
    emit(state.copyWith(status: AppStatus.authenticated));
  }

  Future<void> _onAppUnauthenticate(
    _AppUnauthenticate event,
    Emitter<AppState> emit,
  ) async {
    emit(const AppState.unauthenticated());
  }

  Future<void> _onAppLogoutRequested(
    AppLogoutRequested event,
    Emitter<AppState> emit,
  ) =>
      Future.delayed(1.seconds, _userRepository.logOut);

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    _authStateChangesSubscription?.cancel();
    _pushTokenSubscription?.cancel();
    return super.close();
  }
}
