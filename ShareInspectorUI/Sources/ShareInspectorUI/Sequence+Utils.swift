extension Sequence {
  func numbered(startingAt start: Int = 0) -> [(item: Element, number: Int)] {
    Array(zip(self, start...))
  }
}
