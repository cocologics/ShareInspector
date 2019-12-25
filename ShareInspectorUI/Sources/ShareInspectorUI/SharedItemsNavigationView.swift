import ShareInspectorModel
import SwiftUI

public struct SharedItemsNavigationView: View {
  var state: SharedItems

  public init(state: SharedItems) {
    self.state = state
  }

  public var body: some View {
    NavigationView {
      Group {
        if sharedItems != nil {
          SharedItemsView(items: sharedItems!)
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
