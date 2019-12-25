import Foundation

public struct SharedItems {
  public private(set) var state: Result<[SharedItem], ShareInspectorError>

  public init(state: Result<[SharedItem], ShareInspectorError>) {
    self.state = state
  }
  
  public init(extensionContext: NSExtensionContext?) {
    self.state = Self.parseNSExtensionContext(extensionContext)
  }

  private static func parseNSExtensionContext(_ extensionContext: NSExtensionContext?) -> Result<[SharedItem], ShareInspectorError> {
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
