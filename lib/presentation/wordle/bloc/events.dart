abstract class WordleEvent {}

class SubmitLetter extends WordleEvent {
  final String letter;
  SubmitLetter({required this.letter});
}

class RemoveLetter extends WordleEvent {}

class SubmitWord extends WordleEvent {}

class RequestStats extends WordleEvent {}
