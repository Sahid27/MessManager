abstract class MessEvent {}

class CreateMessRequested extends MessEvent {
  final String name, creatorUid, creatorName;
  CreateMessRequested({
    required this.name,
    required this.creatorUid,
    required this.creatorName,
  });
}
class JoinMessRequested extends MessEvent {
  final String code, uid, name;
  JoinMessRequested({
    required this.code,
    required this.uid,
    required this.name,
  });
}
class LoadMembersRequested extends MessEvent {
  final String messId;
  LoadMembersRequested(this.messId);
}