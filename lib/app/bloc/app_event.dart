part of 'app_bloc.dart';

sealed class AppEvent extends Equatable {
  const AppEvent();

  @override
  List<Object> get props => [];
}

final class AppLogoutRequested extends AppEvent {
  const AppLogoutRequested();
}

final class AppUserChanged extends AppEvent {
  const AppUserChanged(this.user);

  final User user;

  @override
  List<Object> get props => [user];
}

final class AppOpened extends AppEvent {
  const AppOpened();
}

final class _AppAuthenticate extends AppEvent {
  const _AppAuthenticate();
}

final class _AppUnauthenticate extends AppEvent {
  const _AppUnauthenticate();
}
