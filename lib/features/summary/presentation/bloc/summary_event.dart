abstract class SummaryEvent {}
class LoadSummaryRequested extends SummaryEvent {
  final String messId, month;
  LoadSummaryRequested({required this.messId, required this.month});
}