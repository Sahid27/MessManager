import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import '../../../costs/data/repos/cost_repo_impl.dart';
import '../../../meals/data/repos/meal_repo_impl.dart';
import '../../../mess/presentation/bloc/mess_bloc.dart';
import '../../../mess/presentation/bloc/mess_state.dart';
import '../../domain/entities/member_balance.dart';
import 'summary_event.dart';
import 'summary_state.dart';

class SummaryBloc extends Bloc<SummaryEvent, SummaryState> {
  final _mealRepo = MealRepoImpl();
  final _costRepo = CostRepoImpl();

  SummaryBloc() : super(SummaryInitial()) {
    on<LoadSummaryRequested>(_onLoad);
  }

  Future<void> _onLoad(LoadSummaryRequested e, Emitter emit) async {
    emit(SummaryLoading());
    await emit.forEach(
      Rx.combineLatest2(
        _mealRepo.getMealsStream(messId: e.messId, month: e.month),
        _costRepo.getCostsStream(e.messId, e.month),
        (meals, costs) => (meals, costs)),
      onData: (data) {
        final (meals, costs) = data;
        final totalCost  = _costRepo.calcTotalCost(costs);
        final totalMeals = _mealRepo.calcTotal(meals);
        final mealRate   = _mealRepo.calcRate(meals, totalCost);
        // Need members from MessBloc — injected via event in screen
        return SummaryLoaded(
          balances: [], // computed in screen with members
          totalCost: totalCost, mealRate: mealRate,
          totalMeals: totalMeals, month: e.month);
      },
      onError: (err, _) => SummaryError(err.toString()));
  }
}