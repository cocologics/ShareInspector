import SwiftUI

struct RootView: View {
  var body: some View {
    VStack(alignment: .leading) {
      Text("Share Inspector")
        .bold()
        .font(.largeTitle)
        .padding(.bottom)
      Text("""
        This app has no functionality.

        To use Share Inspector, open the Share Sheet in any app and select Share Inspector from the Share Sheet.
        """)
      Spacer()
    }
    .multilineTextAlignment(.leading)
    .padding()
  }
}

struct RootView_Previews: PreviewProvider {
  static var previews: some View {
    RootView()
  }
}
