public struct Numbered<T> {
  public var number: Int
  public var item: T
}

extension Numbered: Equatable where T: Equatable {}

extension Numbered: Hashable where T: Hashable {}

extension Numbered: Identifiable where T: Identifiable {
  public var id: T.ID { item.id }
}

extension Sequence {
  public func numbered(startingAt start: Int = 0) -> [Numbered<Element>] {
    zip(self, start...).map { pair in Numbered(number: pair.1, item: pair.0) }
  }
}
