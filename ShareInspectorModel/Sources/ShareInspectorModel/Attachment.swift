import Foundation

public struct Attachment: Identifiable {
  public let id: UUID = UUID()
  public var registeredTypeIdentifiers: [String]
  public var suggestedName: String?

  public init(registeredTypeIdentifiers: [String], suggestedName: String?) {
    self.registeredTypeIdentifiers = registeredTypeIdentifiers
    self.suggestedName = suggestedName
  }

  init(nsItemProvider itemProvider: NSItemProvider) {
    self.init(
      registeredTypeIdentifiers: itemProvider.registeredTypeIdentifiers,
      suggestedName: itemProvider.suggestedName
    )
  }
}
