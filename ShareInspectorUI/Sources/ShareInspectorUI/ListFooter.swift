import SwiftUI

struct ListFooter: View {
  var onTap: () -> Void

  var body: some View {
    return Section(
      header: HStack {
        Spacer()
        Button(action: { self.onTap() }) {
          Text("Made by Cocologics, makers of ")
            .foregroundColor(Color.secondary)
            + Text("ProCamera")
            + Text(".")
              .foregroundColor(Color.secondary)
        }
        .font(.body)
        .multilineTextAlignment(.center)
        Spacer()
      },
      content: { EmptyView() }
    )
  }
}

struct ListFooter_Previews: PreviewProvider {
  static var previews: some View {
    ListFooter(onTap: {})
      .previewLayout(.sizeThatFits)
  }
}
