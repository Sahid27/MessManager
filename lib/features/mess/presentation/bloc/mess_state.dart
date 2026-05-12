import '../../domain/entities/mess.dart';
import '../../domain/entities/member.dart';

abstract class MessState {}
class MessInitial extends MessState {}
class MessLoading extends MessState {}
class MessError   extends MessState {
  final String msg; MessError(this.msg);
}
class MessLoaded  extends MessState {
  final Mess             mess;
  final List<MessMember> members;
  MessLoaded({required this.mess, required this.members});
}