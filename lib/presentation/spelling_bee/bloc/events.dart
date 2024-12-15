abstract class SpellingBeeEvent {}

class SubmitWord extends SpellingBeeEvent {
  String word;
  SubmitWord(this.word);
}

class RequestStats extends SpellingBeeEvent {}
