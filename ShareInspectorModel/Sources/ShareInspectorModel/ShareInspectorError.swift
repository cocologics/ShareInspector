import Foundation

public enum ShareInspectorError: Swift.Error, CustomNSError {
  case noExtensionContext
  case unexpectedItemType([Any])
  case unableToCastToUIImage(actualType: String)

  var errorMessage: String {
    switch self {
    case .noExtensionContext:
      return "Share extension received no NSExtensionContext."
    case .unexpectedItemType(let items):
      return "\(items.count) of the shared items are not of type NSExtensionItem."
    case .unableToCastToUIImage(let actualType):
      return "Expected preview image to be UIImage, host app provided \(actualType)."
    }
  }

  public static let errorDomain: String = "SharedItems.Error"

  public var errorCode: Int {
    switch self {
    case .noExtensionContext: return 1
    case .unexpectedItemType: return 2
    case .unableToCastToUIImage: return 3
    }
  }

  public var errorUserInfo: [String: Any] {
    [NSLocalizedDescriptionKey: errorMessage]
  }
}
