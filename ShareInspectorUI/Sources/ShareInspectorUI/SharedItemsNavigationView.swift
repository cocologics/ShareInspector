import ShareInspectorModel
import SwiftUI

public struct SharedItemsNavigationView: View {
  @EnvironmentObject var store: Store
  var onCloseTap: (() -> Void)? = nil

  public init(onCloseTap: (() -> Void)? = nil) {
    self.onCloseTap = onCloseTap
  }

  public var body: some View {
    NavigationStack {
      Group {
        switch store.state.state {
        case .success(let sharedItems):
          SharedItemsView(items: sharedItems)
        case .failure(let error):
          ErrorView(errorMessage: error.localizedDescription)
        }
      }
      .navigationTitle("Share Inspector")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button { onCloseTap?() } label: { Text("Done").bold() }
        }
      }
    }
  }
}

struct SharedItemsNavigationView_Previews: PreviewProvider {
  static var previews: some View {
    let store = Store(state: SharedItems(state: .success([.sample])))
    SharedItemsNavigationView()
      .environmentObject(store)
  }
}
