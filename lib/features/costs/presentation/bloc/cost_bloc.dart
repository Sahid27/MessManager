import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repos/cost_repo_impl.dart';
import 'cost_event.dart';
import 'cost_state.dart';

class CostBloc extends Bloc<CostEvent, CostState> {
  final _repo = CostRepoImpl();

  CostBloc() : super(CostInitial()) {
    on<LoadCostsRequested>(_onLoad);
    on<AddCostRequested>(_onAdd);
    on<TogglePaidRequested>(_onToggle);
  }

  Future<void> _onLoad(LoadCostsRequested e, Emitter emit) async {
    emit(CostLoading());
    await emit.forEach(
      _repo.getCostsStream(e.messId, e.month),
      onData: (entries) {
        final total  = _repo.calcTotalCost(entries);
        final paid   = entries.where((c) => c.isPaid).fold(0.0, (s, c) => s + c.amount);
        final due    = total - paid;
        return CostLoaded(entries: entries, totalCost: total, paidTotal: paid, dueTotal: due);
      },
      onError: (err, _) => CostError(err.toString()));
  }

  Future<void> _onAdd(AddCostRequested e, Emitter emit) async {
    try {
      await _repo.addCost(
        messId: e.messId, month: e.month,
        paidBy: e.paidBy, paidByName: e.paidByName,
        amount: e.amount, note: e.note,
        isPaid: e.isPaid, type: e.type);
    } catch (err) { emit(CostError(err.toString())); }
  }

  Future<void> _onToggle(TogglePaidRequested e, Emitter emit) async {
    try {
      await _repo.togglePaid(e.messId, e.month, e.costId, e.isPaid);
    } catch (err) { emit(CostError(err.toString())); }
  }
}