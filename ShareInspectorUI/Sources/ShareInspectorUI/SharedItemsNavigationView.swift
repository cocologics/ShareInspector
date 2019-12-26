import ShareInspectorModel
import SwiftUI

public struct SharedItemsNavigationView: View {
  var state: SharedItems
  var onFooterTap: (() -> Void)? = nil

  public init(state: SharedItems, onFooterTap: (() -> Void)? = nil) {
    self.state = state
    self.onFooterTap = onFooterTap
  }

  public var body: some View {
    NavigationView {
      Group {
        if sharedItems != nil {
          SharedItemsView(items: sharedItems!, onFooterTap: onFooterTap)
        } else if error != nil {
          ErrorView(errorMessage: error!.localizedDescription)
        } else {
          ErrorView(errorMessage: "Unexpected UI state")
        }
      }
        .navigationBarTitle("Share Inspector", displayMode: .inline)
        .navigationBarItems(trailing: Button(action: {}) { Text("Done").bold() })
    }
  }

  var sharedItems: [SharedItem]? {
    switch state.state {
    case .success(let items): return items
    case .failure: return nil
    }
  }

  var error: ShareInspectorError? {
    switch state.state {
    case .success: return nil
    case .failure(let error): return error
    }
  }
}
