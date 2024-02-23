import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/l10n/l10n.dart';
import 'package:flutter_instagram_offline_first_clone/selector/selector.dart';

/// A drop down menu to select a new [Locale]
///
/// Requires a [LocaleBloc] to be provided in the widget tree
/// (usually above [MaterialApp])
class LocaleSelector extends StatelessWidget {
  const LocaleSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = context.watch<LocaleBloc>().state;

    return DropdownButton(
      key: const Key('localeSelector_dropdown'),
      onChanged: (locale) =>
          context.read<LocaleBloc>().add(LocaleChanged(locale)),
      value: locale,
      items: [
        DropdownMenuItem(
          value: const Locale('en', 'US'),
          child: Text(
            l10n.enOption,
            key: const Key('localeSelector_en_dropdownMenuItem'),
          ),
        ),
        DropdownMenuItem(
          value: const Locale('ru', 'RU'),
          child: Text(
            l10n.ruOption,
            key: const Key('localeSelector_ru_dropdownMenuItem'),
          ),
        ),
      ],
    );
  }
}

class LocaleModalOption extends StatelessWidget {
  const LocaleModalOption({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const LocaleSelector(),
      title: Text(context.l10n.language),
    );
  }
}
