import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_instagram_offline_first_clone/counter/bloc/bloc/counter_bloc.dart';

class CounterValue extends StatelessWidget {
  const CounterValue({super.key});

  @override
  Widget build(BuildContext context) {
    final count = context.select((CounterBloc bloc) => bloc.state.count);
    return Text('This is counter value: $count');
  }
}
