import Foundation
import UIKit

struct LabeledValue<Value> {
  var label: String
  var value: Value
}

enum Text {
  case plain(String)
  case rich(NSAttributedString)
}

extension LabeledValue where Value == Text {
  var cellDescriptor: CellDescriptor {
    return CellDescriptor { (cell: TextCell) in
      cell.viewModel = self
    }
  }
}

extension LabeledValue where Value == [String: Any]? {
  var cellDescriptor: CellDescriptor {
    return CellDescriptor { (cell: DictionaryCell) in
      cell.viewModel = self
    }
  }
}

/// View model for ShareViewController
struct ShareViewModel {
  var sections: [Section]

  init(extensionContext: NSExtensionContext?) {
    self.sections = ShareViewModel.makeSections(extensionContext: extensionContext)
  }

  private static func makeSections(extensionContext: NSExtensionContext?) -> [Section] {
    var sections: [Section] = []

    // Overview section
    guard let extensionContext = extensionContext else {
      sections.append(Notice(label: "Error", message: "Share extension received no NSExtensionContext."))
      return sections
    }
    sections.append(Overview(sharedItemsCount: extensionContext.inputItems.count))

    guard let sharedItems = extensionContext.inputItems as? [NSExtensionItem] else {
      sections.append(Notice(label: "Error", message: "Error: Elements in extensionContext.inputItems are not of type NSExtensionItem."))
      return sections
    }

    // Sections for the shared items
    // For each shared item, we create:
    // - An overview section with the data provided by NSExtensionItem.
    // - One attachment section per attachment (NSItemProvider) of the shared item.
    for (itemNumber, sharedItem) in zip(1..., sharedItems) {
      let attachments = sharedItem.attachments ?? []

      // Shared item overview
      sections.append(SharedItemOverview(
        itemNumber: itemNumber,
        attributedTitle: sharedItem.attributedTitle,
        attributedContentText: sharedItem.attributedContentText,
        attachmentCount: attachments.count,
        userInfo: sharedItem.userInfo as? [String: Any]))

      // Attachments
      for (attachmentNumber, itemProvider) in zip(1..., attachments) {
        sections.append(Attachment(
          itemNumber: itemNumber,
          attachmentNumber: attachmentNumber,
          attachmentCount: attachments.count,
          itemProvider: itemProvider))
      }
    }

    return sections
  }
}

extension ShareViewModel {
  /// A section for displaying a piece of text (e.g. an error message)
  struct Notice: Section {
    var label: String
    var message: String

    var sectionTitle: String? { return nil }
    var cells: [CellDescriptor] {
      return [
        LabeledValue(label: label, value: Text.plain(message)).cellDescriptor
      ]
    }
  }

  struct Overview: Section {
    var sharedItemsCount: Int

    var sectionTitle: String? { return nil }
    var cells: [CellDescriptor] {
      return [
        LabeledValue(
          label: "Number of shared items",
          value: Text.plain("\(sharedItemsCount)")).cellDescriptor,
      ]
    }
  }

  struct SharedItemOverview: Section {
    var itemNumber: Int
    var attributedTitle: NSAttributedString?
    var attributedContentText: NSAttributedString?
    var attachmentCount: Int
    var userInfo: [String: Any]?

    var sectionTitle: String? {
      return "Item \(itemNumber) (NSExtensionItem)"
    }

    var cells: [CellDescriptor] {
      return [
        LabeledValue(
          label: "attributedTitle",
          value: attributedTitle.map(Text.rich) ?? Text.plain("(nil)")).cellDescriptor,
        LabeledValue(
          label: "attributedContentText",
          value: attributedContentText.map(Text.rich) ?? Text.plain("(nil)")).cellDescriptor,
        LabeledValue(
          label: "Number of attachments",
          value: Text.plain("\(attachmentCount)")).cellDescriptor,
        LabeledValue(
          label: "userInfo",
          value: userInfo).cellDescriptor,
      ]
    }
  }

  struct Attachment: Section {
    typealias LoadPreviewImage = (_ preferredSize: CGSize, _ callback: @escaping (Result<UIImage, Error>) -> ()) -> ()

    var itemNumber: Int
    var attachmentNumber: Int
    var attachmentCount: Int
    var registeredTypeIdentifiers: [String]
    var suggestedName: String?
    var loadPreviewImage: LoadPreviewImage

    init(itemNumber: Int, attachmentNumber: Int, attachmentCount: Int, itemProvider: NSItemProvider) {
      self.itemNumber = itemNumber
      self.attachmentNumber = attachmentNumber
      self.attachmentCount = attachmentCount
      self.registeredTypeIdentifiers = itemProvider.registeredTypeIdentifiers
      self.suggestedName = itemProvider.suggestedName
      self.loadPreviewImage = Attachment.makeLoadPreviewImageHandler(itemProvider: itemProvider)
    }

    var sectionTitle: String? {
      return "Item \(itemNumber) · Attachment \(attachmentNumber) of \(attachmentCount) (NSItemProvider)"
    }

    var cells: [CellDescriptor] {
      let bullet = registeredTypeIdentifiers.count == 1 ? "" : "• "
      let typeIdentifiersList = registeredTypeIdentifiers
        .map { line in "\(bullet)\(line)" }
        .joined(separator: "\n")
      return [
        LabeledValue(
          label: "registeredTypeIdentifiers",
          value: Text.plain(typeIdentifiersList)).cellDescriptor,
        LabeledValue(
          label: "suggestedName",
          value: Text.plain(suggestedName ?? "(nil)")).cellDescriptor,
      ]
    }

    private static func makeLoadPreviewImageHandler(itemProvider: NSItemProvider) -> LoadPreviewImage {
      let loadPreviewImage: Attachment.LoadPreviewImage = { preferredSize, callback in
        let options: [AnyHashable: Any] = [
          NSItemProviderPreferredImageSizeKey: NSValue(cgSize: preferredSize)
        ]
        let completionHandler: (NSSecureCoding?, Error?) -> () = { result, error in
          switch (result, error) {
          case (let image as UIImage, _):
            callback(.success(image))
          case (_?, _):
            callback(.failure(error ?? ShareInspectorError.unableToCastToUIImage(actualType: "\(type(of: result))")))
          case (nil, let error?):
            callback(.failure(error))
          case (nil, nil):
            callback(.failure(ShareInspectorError.noPreviewImageProvided))
          }
        }
        itemProvider.loadPreviewImage(options: options, completionHandler: completionHandler)
      }
      return loadPreviewImage
    }
  }
}

struct ShareInspectorError: Error {
  var message: String

  static func unableToCastToUIImage(actualType: String) -> ShareInspectorError {
    return ShareInspectorError(message: "Expected preview image to be UIImage, host app provided \(actualType)")
  }
  static let noPreviewImageProvided = ShareInspectorError(message: "Host app provided no preview image")
}
