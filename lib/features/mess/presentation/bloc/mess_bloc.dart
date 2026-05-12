import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repos/mess_repo_impl.dart';
import '../../domain/entities/mess.dart';
import 'mess_event.dart';
import 'mess_state.dart';

class MessBloc extends Bloc<MessEvent, MessState> {
  final _repo = MessRepoImpl();
  Mess? _currentMess;

  MessBloc() : super(MessInitial()) {
    on<CreateMessRequested>(_onCreate);
    on<JoinMessRequested>(_onJoin);
    on<LoadMembersRequested>(_onLoad);
  }

  Future<void> _onCreate(CreateMessRequested e, Emitter emit) async {
    emit(MessLoading());
    try {
      final mess = await _repo.createMess(
        name: e.name, creatorUid: e.creatorUid, creatorName: e.creatorName);
      _currentMess = mess;
      add(LoadMembersRequested(mess.id, mess: mess));
    } catch (err) { emit(MessError(err.toString())); }
  }

  Future<void> _onJoin(JoinMessRequested e, Emitter emit) async {
    emit(MessLoading());
    try {
      final mess = await _repo.joinMess(
        code: e.code, uid: e.uid, name: e.name);
      _currentMess = mess;
      add(LoadMembersRequested(mess.id, mess: mess));
    } catch (err) { emit(MessError(err.toString())); }
  }

  Future<void> _onLoad(LoadMembersRequested e, Emitter emit) async {
    if (e.mess != null) _currentMess = e.mess;
    if (_currentMess == null) {
      try {
        _currentMess = await _repo.getMessById(e.messId);
      } catch (err) {
        emit(MessError('মেসের তথ্য পাওয়া যায়নি'));
        return;
      }
    }
    final mess = _currentMess!;
    await emit.forEach(
      _repo.getMembers(e.messId),
      onData: (members) => MessLoaded(mess: mess, members: members),
      onError: (err, _) => MessError(err.toString()),
    );
  }
}