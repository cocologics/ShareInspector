import ShareInspectorUI
import SwiftUI

struct RootView: View {
  @State private var itemToShare: ItemToShare? = nil

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 16) {
        Text("Share Inspector")
          .bold()
          .font(.largeTitle)
          .padding(.top)
        Text("""
          This app only exists for its share extension; it has no functionality itself.

          To use the extension, open the Share Sheet in any app and select “Inspector” from the Share Sheet.
          """)

        Divider()
          .padding([.top, .bottom])

        Text("Test Area")
          .bold()
          .font(.title)
        Text("""
          These buttons open Share Sheets for various data types. Useful for testing the extension.
          """)
        ShareButton(
          text: "Share a URL",
          action: { self.itemToShare = .url(URL(string: "https://www.procamera-app.com")!) }
        )
        ShareButton(
          text: "Share a String",
          action: { self.itemToShare = .string("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.") }
        )
        ShareButton(
          text: "Share a Photo (as UIImage)",
          action: { self.itemToShare = .image(UIImage(contentsOfFile: Bundle.main.path(forResource: "city_lights_africa_8k", ofType: "jpg")!)!) }
        )
        ShareButton(
          text: "Share a Photo (as a File URL)",
          action: { self.itemToShare = .file(Bundle.main.url(forResource: "city_lights_africa_8k", withExtension: "jpg")!) }
        )

        Spacer()
      }
      .multilineTextAlignment(.leading)
      .padding()
      .sheet(item: $itemToShare, onDismiss: { self.itemToShare = nil }) { item in
        ShareSheet(sharedItems: [item.eraseToAny()])
      }
    }
  }
}

struct ShareButton: View {
  var text: LocalizedStringKey
  var action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack(alignment: .firstTextBaseline) {
        Image(systemName: "square.and.arrow.up")
        Text(text)
      }
    }
  }
}

struct RootView_Previews: PreviewProvider {
  static var previews: some View {
    RootView()
  }
}

enum ItemToShare: Identifiable {
  case url(URL)
  case string(String)
  case image(UIImage)
  case file(URL)

  var id: String {
    switch self {
    case .url(let url): return "url-" + url.absoluteString
    case .string(let string): return "string-" + string
    case .image(let image): return "image-" + String(describing: ObjectIdentifier(image))
    case .file(let fileURL): return "file-" + fileURL.absoluteString
    }
  }

  func eraseToAny() -> Any {
    switch self {
    case .url(let url): return url
    case .string(let string): return string
    case .image(let image): return image
    case .file(let file): return file
    }
  }
}
