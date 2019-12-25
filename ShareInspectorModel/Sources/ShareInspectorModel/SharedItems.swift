import Foundation

public struct SharedItems {
  public private(set) var state: Result<[SharedItem], SharedItems.Error>

  public init(state: Result<[SharedItem], SharedItems.Error>) {
    self.state = state
  }
  
  public init(extensionContext: NSExtensionContext?) {
    self.state = Self.parseNSExtensionContext(extensionContext)
  }

  private static func parseNSExtensionContext(_ extensionContext: NSExtensionContext?) -> Result<[SharedItem], SharedItems.Error> {
    guard let extensionContext = extensionContext else {
      return .failure(.noExtensionContext)
    }
    guard let sharedItems = extensionContext.inputItems as? [NSExtensionItem],
      sharedItems.count == extensionContext.inputItems.count else {
        return .failure(.unexpectedItemType(extensionContext.inputItems.filter { $0 as? NSExtensionItem == nil }))
    }
    return .success(sharedItems.map(SharedItem.init(nsExtensionItem:)))
  }
}

extension SharedItems {
  public enum Error: Swift.Error, CustomNSError {
    case noExtensionContext
    case unexpectedItemType([Any])

    var errorMessage: String {
      switch self {
      case .noExtensionContext:
        return "Share extension received no NSExtensionContext."
      case .unexpectedItemType(let items):
        return "\(items.count) of the shared items are not of type NSExtensionItem."
      }
    }

    public static let errorDomain: String = "SharedItems.Error"

    public var errorCode: Int {
      switch self {
      case .noExtensionContext: return 1
      case .unexpectedItemType: return 2
      }
    }

    public var errorUserInfo: [String: Any] {
      [NSLocalizedDescriptionKey: errorMessage]
    }
  }
}
