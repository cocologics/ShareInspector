import Foundation

public struct SharedItems {
  public private(set) var state: Result<[SharedItem], ShareInspectorError>

  public init(state: Result<[SharedItem], ShareInspectorError>) {
    self.state = state
  }
  
  public init(extensionContext: NSExtensionContext?) {
    self.state = Self.parseNSExtensionContext(extensionContext)
  }

  /// Provides mutating access to a `SharedItem` by its id.
  ///
  /// - Note: Does nothing for non-existent item ids
  ///   (i.e. no new shared item will be inserted).
  public subscript(sharedItem id: SharedItem.ID) -> SharedItem? {
    get {
      switch state {
      case .success(let sharedItems):
        return sharedItems.first(where: { $0.id == id })
      case .failure:
        return nil
      }
    }
    set {
      switch state {
      case .success(var sharedItemsToUpdate):
        guard let itemIndex = sharedItemsToUpdate.firstIndex(where: { $0.id == id }) else {
          return
        }
        if let newValue = newValue {
          sharedItemsToUpdate[itemIndex] = newValue
        } else {
          sharedItemsToUpdate.remove(at: itemIndex)
        }
        state = .success(sharedItemsToUpdate)
      case .failure:
        break
      }
    }
  }

  private static func parseNSExtensionContext(
    _ extensionContext: NSExtensionContext?
  ) -> Result<[SharedItem], ShareInspectorError> {
    guard let extensionContext = extensionContext else {
      return .failure(.noExtensionContext)
    }
    guard let sharedItems = extensionContext.inputItems as? [NSExtensionItem],
      sharedItems.count == extensionContext.inputItems.count
    else {
      let items = extensionContext.inputItems.filter { $0 as? NSExtensionItem == nil }
      return .failure(.unexpectedItemType(items))
    }
    return .success(sharedItems.map(SharedItem.init(nsExtensionItem:)))
  }
}
