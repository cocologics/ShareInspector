import Foundation

/// A section in a table or collection view.
protocol SectionViewModel {
  var rowCount: Int { get }
  var sectionTitle: String? { get }
}

struct OverviewSectionViewModel: SectionViewModel {
  var rowCount: Int { return 1 }
  var sectionTitle: String? { return "Overview" }

  var text: String
}

struct SharedItemSectionViewModel: SectionViewModel {
  var rowCount: Int { return 1 }
  var sectionTitle: String? {
    return "Shared Item \(number)"
  }

  var number: Int
  var attributedTitle: NSAttributedString?
  var attributedContentText: NSAttributedString?
  var attachmentCount: Int
  var userInfoText: String?
}

struct AttachmentsSectionViewModel: SectionViewModel {
  var rowCount: Int { return attachments.count }
  var sectionTitle: String? {
    return "\(attachments.count) \(attachments.count == 1 ? "attachment" : "attachments")"
  }

  var attachments: [Attachment]

  struct Attachment {
    var registeredTypeIdentifiers: [String]
    var suggestedName: String?
  }
}

/// View model for ShareViewController
struct ShareViewModel {
  var sections: [SectionViewModel]

  /// View model for ShareViewController
  init(extensionContext: NSExtensionContext?) {
    var sections: [SectionViewModel] = []

    // Overview section
    guard let extensionContext = extensionContext else {
      sections.append(OverviewSectionViewModel(text: """
        Error: Share extension received no NSExtensionContext.
        """))
      self.sections = sections
      return
    }
    guard let sharedItems = extensionContext.inputItems as? [NSExtensionItem] else {
      sections.append(OverviewSectionViewModel(text:
        """
        Share extension received \(extensionContext.inputItems.count) shared \(extensionContext.inputItems.count == 1 ? "item" : "items").

        Error: Elements in extensionContext.inputItems are not of type NSExtensionItem.
        """))
      self.sections = sections
      return
    }
    sections.append(OverviewSectionViewModel(text: """
      Share extension received \(sharedItems.count) shared \(sharedItems.count == 1 ? "item" : "items").
      """))

    // Sections for the shared items
    // For each shared item, we create:
    // - An overview section with the data provided by NSExtensionItem.
    // - An attachments section that lists all attachments (NSItemProvider) of the shared item.
    for (counter, sharedItem) in zip(1..., sharedItems) {
      let attachments = sharedItem.attachments ?? []

      // Shared item overview
      sections.append(SharedItemSectionViewModel(
        number: counter,
        attributedTitle: sharedItem.attributedTitle,
        attributedContentText: sharedItem.attributedContentText,
        attachmentCount: attachments.count,
        userInfoText: sharedItem.userInfo.map(String.init(reflecting:)) ?? "(nil)"))

      // Attachments
      sections.append(AttachmentsSectionViewModel(attachments: attachments.map { itemProvider in
        AttachmentsSectionViewModel.Attachment(
          registeredTypeIdentifiers: itemProvider.registeredTypeIdentifiers,
          suggestedName: itemProvider.suggestedName)
      }))
    }

    self.sections = sections
  }
}

