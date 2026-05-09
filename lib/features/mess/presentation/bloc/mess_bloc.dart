import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repos/mess_repo_impl.dart';
import 'mess_event.dart';
import 'mess_state.dart';

class MessBloc extends Bloc<MessEvent, MessState> {
  final _repo = MessRepoImpl();

  MessBloc() : super(MessInitial()) {
    on<CreateMessRequested>(_onCreate);
    on<JoinMessRequested>(_onJoin);
    on<LoadMembersRequested>(_onLoad);
  }

  Future<void> _onCreate(
      CreateMessRequested e, Emitter emit) async {
    emit(MessLoading());
    try {
      final mess = await _repo.createMess(
        name: e.name,
        creatorUid: e.creatorUid,
        creatorName: e.creatorName,
      );
      // Member লোড করো
      add(LoadMembersRequested(mess.id));
    } catch (e) {
      emit(MessError(e.toString()));
    }
  }

  Future<void> _onJoin(
      JoinMessRequested e, Emitter emit) async {
    emit(MessLoading());
    try {
      final mess = await _repo.joinMess(
        code: e.code, uid: e.uid, name: e.name,
      );
      add(LoadMembersRequested(mess.id));
    } catch (e) {
      emit(MessError(e.toString()));
    }
  }

  Future<void> _onLoad(
      LoadMembersRequested e, Emitter emit) async {
    await emit.forEach(
      _repo.getMembers(e.messId),
      onData: (members) => MessLoaded(
        mess:   (state as MessLoaded?)?.mess
                 ?? (state as MessLoaded).mess,
        members: members,
      ),
    );
  }
}