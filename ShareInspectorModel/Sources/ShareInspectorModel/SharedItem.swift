import Foundation

public struct SharedItem: Identifiable {
  public let id: UUID = UUID()
  public var attributedTitle: NSAttributedString?
  public var attributedContentText: NSAttributedString?
  public var attachments: [Attachment]
  public var userInfo: [String: Any]?

  public init(attributedTitle: NSAttributedString?, attributedContentText: NSAttributedString?, attachments: [Attachment], userInfo: [String: Any]?) {
    self.attributedTitle = attributedTitle
    self.attributedContentText = attributedContentText
    self.attachments = attachments
    self.userInfo = userInfo
  }

  init(nsExtensionItem extensionItem: NSExtensionItem) {
    self.init(
      attributedTitle: extensionItem.attributedTitle,
      attributedContentText: extensionItem.attributedContentText,
      attachments: (extensionItem.attachments ?? []).map(Attachment.init(nsItemProvider:)),
      userInfo: extensionItem.userInfo  as? [String: Any]
    )
  }

  /// Provides mutating access to an `Attachment` by its id.
  ///
  /// - Note: Does nothing for non-existent attachment ids
  ///   (i.e. no new attachment will be inserted).
  public subscript(attachment id: Attachment.ID) -> Attachment? {
    get {
      attachments.first(where: { $0.id == id })
    }
    set {
      guard let attachmentIndex = attachments.firstIndex(where: { $0.id == id }) else {
        return
      }
      if let newValue = newValue {
        attachments[attachmentIndex] = newValue
      } else {
        attachments.remove(at: attachmentIndex)
      }
    }
  }
}
