import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_notifications_client/firebase_notifications_client.dart';
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
          user.isAnonymous
              ? const AppState.unauthenticated()
              : AppState.authenticated(user),
        ) {
    on<AppLogoutRequested>(_onAppLogoutRequested);
    on<AppUserChanged>(_onUserChanged);

    _userSubscription =
        userRepository.user.listen(_userChanged, onError: addError);
  }

  final UserRepository _userRepository;
  final FirebaseNotificationsClient _notificationsClient;

  StreamSubscription<User>? _userSubscription;
  StreamSubscription<String>? _pushTokenSubscription;

  void _userChanged(User user) => add(AppUserChanged(user));

  void _onUserChanged(AppUserChanged event, Emitter<AppState> emit) {
    final user = event.user;

    Future<void> authenticate() async {
      emit(AppState.authenticated(user));

      _pushTokenSubscription ??=
          _notificationsClient.onTokenRefresh().listen((pushToken) async {
        await _userRepository.updateUser(pushToken: pushToken);
      });

      await _notificationsClient.requestPermission();
    }

    switch (state.status) {
      case AppStatus.onboardingRequired:
      case AppStatus.authenticated:
      case AppStatus.unauthenticated:
        return !user.isAnonymous && user.isNewUser
            ? emit(AppState.onboardingRequired(user))
            : user.isAnonymous
                ? emit(const AppState.unauthenticated())
                : authenticate();
    }
  }

  Future<void> _onAppLogoutRequested(
    AppLogoutRequested event,
    Emitter<AppState> emit,
  ) =>
      _userRepository.logOut();

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    _pushTokenSubscription?.cancel();
    return super.close();
  }
}
