import 'package:bloc/bloc.dart';

/// A minimal Cubit purely to demonstrate the toolkit's App State Inspector.
/// `DevBlocObserver`, registered in main.dart, picks up every state change
/// automatically — nothing here is toolkit-specific.
class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
  void decrement() => emit(state - 1);
}

final counterCubit = CounterCubit();
