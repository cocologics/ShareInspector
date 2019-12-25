import Foundation
import UIKit

public struct Attachment: Identifiable {
  /// Type of the function for loading the attachments's preview image asynchronously.
  /// - Parameter preferredSize: The preferred image size in points. The returned
  ///   image may be bigger or smaller than this size.
  /// - Parameter callback: The callback function to call when loading has completed
  ///   or failed. The callback is passed the result of the loading process.
  ///   Possible values are `.success`, `.failure`, or `nil`. `nil` means the
  ///   item provider provided no preview image.
  public typealias LoadImageHandler = (_ preferredSize: CGSize, _ callback: @escaping (Result<UIImage, Error>?) -> Void) -> Void

  public let id: UUID = UUID()
  public var registeredTypeIdentifiers: [String]
  public var suggestedName: String?
  public var loadPreviewImage: LoadImageHandler
}

extension Attachment {
  public init(registeredTypeIdentifiers: [String], suggestedName: String?, previewImage: UIImage?) {
    self.registeredTypeIdentifiers = registeredTypeIdentifiers
    self.suggestedName = suggestedName
    self.loadPreviewImage = { _, callback in
      if let previewImage = previewImage {
        callback(.success(previewImage))
      } else {
        callback(nil)
      }
    }
  }

  init(nsItemProvider itemProvider: NSItemProvider) {
    self.init(
      registeredTypeIdentifiers: itemProvider.registeredTypeIdentifiers,
      suggestedName: itemProvider.suggestedName,
      loadPreviewImage: Self.makeLoadPreviewImageHandler(itemProvider: itemProvider)
    )
  }

  private static func makeLoadPreviewImageHandler(itemProvider: NSItemProvider) -> LoadImageHandler {
    let loadPreviewImage: LoadImageHandler = { preferredSize, callback in
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
          callback(nil)
        }
      }
      itemProvider.loadPreviewImage(options: options, completionHandler: completionHandler)
    }
    return loadPreviewImage
  }
}
