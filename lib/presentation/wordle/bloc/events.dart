abstract class WordleEvent {}

class SubmitLetter extends WordleEvent {
  final String letter;
  SubmitLetter({required this.letter});
}

class SubmitKey extends WordleEvent {
  final KeyType key;
  SubmitKey({required this.key});
}

enum KeyType { backspace, enter }
