import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show Locale;
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'locale_event.dart';

class LocaleBloc extends HydratedBloc<LocaleEvent, Locale> {
  LocaleBloc() : super(const Locale('en', 'US')) {
    on<LocaleChanged>((event, emit) => emit(event.locale ?? state));
  }

  @override
  Locale? fromJson(Map<String, dynamic> json) =>
      Locale(json['language_code'] as String, json['country_code'] as String?);

  @override
  Map<String, dynamic>? toJson(Locale state) => {
        'language_code': state.languageCode,
        if (state.countryCode != null) 'country_code': state.countryCode,
      };
}
