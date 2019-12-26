import ShareInspectorModel
import SwiftUI

public struct SharedItemsNavigationView: View {
  var state: SharedItems
  var onCloseTap: (() -> Void)? = nil
  var onFooterTap: (() -> Void)? = nil

  public init(state: SharedItems, onCloseTap: (() -> Void)? = nil, onFooterTap: (() -> Void)? = nil) {
    self.state = state
    self.onCloseTap = onCloseTap
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
      .navigationBarItems(trailing: Button(action: { self.onCloseTap?() }) { Text("Done").bold() })
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
