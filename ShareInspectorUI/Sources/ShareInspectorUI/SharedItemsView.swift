import SwiftUI

public struct SharedItemsView: View {
  public init() {
  }

  public var body: some View {
    VStack {
      Rectangle().fill(Color.red)
    }
  }
}

struct SharedItems_Previews: PreviewProvider {
  static var previews: some View {
    SharedItemsView()
  }
}
