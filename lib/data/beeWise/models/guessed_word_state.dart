enum GuessedWordState {
  notInDictionary,
  alreadyGuessed,
  doesNotContainLettersOfTheDay,
  doesNotContainCenterLetter,
  tooShort,
  pangram,
  valid,
}
