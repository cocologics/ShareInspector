extension StringProtocol {
  var lineCount: Int {
    guard !isEmpty else {
      return 0
    }
    return reduce(1) { lineCount, character in
      lineCount + (character.isNewline ? 1 : 0)
    }
  }
}
