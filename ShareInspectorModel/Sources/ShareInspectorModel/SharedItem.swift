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
}
