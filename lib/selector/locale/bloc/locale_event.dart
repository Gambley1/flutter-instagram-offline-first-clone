part of 'locale_bloc.dart';

sealed class LocaleEvent extends Equatable {
  const LocaleEvent();
}

final class LocaleChanged extends LocaleEvent {
  const LocaleChanged(this.locale);

  final Locale? locale;

  @override
  List<Object?> get props => [locale];
}
