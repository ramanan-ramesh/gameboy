enum LexBoxGuessedWordState {
  tooShort,
  notInDictionary,
  invalidConsecutiveSameSide,
  mustStartWithPreviousWordLastLetter,
  valid,
  win,
}
