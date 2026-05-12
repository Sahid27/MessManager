import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repos/meal_repo_impl.dart';
import 'meal_event.dart';
import 'meal_state.dart';

class MealBloc extends Bloc<MealEvent, MealState> {
  final _repo = MealRepoImpl();
  double totalCost = 0.0;

  MealBloc() : super(MealInitial()) {
    on<LoadMealsRequested>(_onLoad);
    on<SaveMealsRequested>(_onSave);
  }

  Future<void> _onLoad(LoadMealsRequested e, Emitter emit) async {
    emit(MealLoading());
    await emit.forEach(
      _repo.getMealsStream(messId: e.messId, month: e.month),
      onData: (entries) => MealLoaded(
        month: e.month, entries: entries,
        totalMeals: _repo.calcTotal(entries),
        mealRate: _repo.calcRate(entries, totalCost)),
      onError: (err, _) => MealError(err.toString()));
  }

  Future<void> _onSave(SaveMealsRequested e, Emitter emit) async {
    emit(MealSaving());
    try {
      await _repo.saveMeals(messId: e.messId, date: e.date, counts: e.counts);
      emit(MealSaved());
    } catch (err) { emit(MealError(err.toString())); }
  }
}