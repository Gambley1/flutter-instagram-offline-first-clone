import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/counter/bloc/bloc/counter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/counter/widgets/counter_text.dart';
import 'package:flutter_instagram_offline_first_clone/counter/widgets/counter_value.dart';

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CounterBloc(),
      child: const CounterView(),
    );
  }
}

class CounterView extends StatelessWidget {
  const CounterView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Test'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<CounterBloc>().add(const CounterIncremented());
        },
        child: const Icon(Icons.add),
      ),
      body: const CounterText(
        child: CounterValue(),
      ),
    );
  }
}
