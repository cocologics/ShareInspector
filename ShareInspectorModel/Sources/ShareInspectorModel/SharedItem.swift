import Foundation

public struct SharedItem: Identifiable {
  public let id: UUID = UUID()
  public var attributedTitle: NSAttributedString?
  public var attributedContentText: NSAttributedString?
  public var attachments: [Attachment]

  public init(attributedTitle: NSAttributedString?, attributedContentText: NSAttributedString?, attachments: [Attachment]) {
    self.attributedTitle = attributedTitle
    self.attributedContentText = attributedContentText
    self.attachments = attachments
  }

  init(nsExtensionItem extensionItem: NSExtensionItem) {
    self.init(
      attributedTitle: extensionItem.attributedTitle,
      attributedContentText: extensionItem.attributedContentText,
      attachments: (extensionItem.attachments ?? []).map(Attachment.init(nsItemProvider:))
    )
  }
}
