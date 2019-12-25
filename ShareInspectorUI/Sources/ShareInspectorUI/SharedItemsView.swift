import ShareInspectorModel
import SwiftUI

struct SharedItemsView: View {
  var items: [SharedItem]

  var body: some View {
    List {
      Section {
        HStack {
          Text("Number of shared items")
          Spacer()
          Text("\(items.count)")
        }
      }

      ForEach(items.numbered(startingAt: 1)) { i in
        Group {
          Section(header: Text("Item \(i.number) (NSExtensionItem)")) {
            SharedItemProperty(label: "attributedTitle", value: i.item.attributedTitle?.string)
            SharedItemProperty(label: "attributedContentText", value: i.item.attributedContentText?.string)
            SharedItemProperty(label: "Number of attachments", value: "\(i.item.attachments.count)")
            if i.item.userInfo != nil {
              NavigationLink(
                destination: DictionaryListView(dictionary: i.item.userInfo!)
                  .navigationBarTitle("NSExtensionItem.userInfo")
              ) {
                SharedItemProperty(label: "userInfo", value: "\(i.item.userInfo!.count)")
              }
            } else {
              SharedItemProperty(label: "userInfo", value: nil)
            }
          }

          ForEach(i.item.attachments.numbered(startingAt: 1)) { a in
            Section(header: Text("Item \(i.number) · Attachment \(a.number) of \(i.item.attachments.count) (NSItemProvider)")) {
              AttachmentView(attachment: a.item)
            }
          }
        }
      }
    }
    .listStyle(GroupedListStyle())
  }
}

struct SharedItemProperty: View {
  var label: String
  var value: String?

  var body: some View {
    HStack(alignment: .firstTextBaseline) {
      Text(label)
      Spacer()
      Text(value ?? "(nil)")
        .multilineTextAlignment(.leading)
    }
  }
}

struct AttachmentView: View {
  var attachment: Attachment
  @State private var previewImageState: PreviewImageState = .loading

  static var previewImageSize: CGFloat = 120

  var body: some View {
    Group {
      HStack(alignment: .top) {
        Text("Preview Image")
        Spacer()
        if previewImageState.isLoading {
          Rectangle()
            .fill(Color(UIColor.systemGray2))
            .frame(width: Self.previewImageSize, height: Self.previewImageSize)
            .onAppear {
              self.attachment.loadPreviewImage(CGSize(width: 120, height: 120)) { result in
                DispatchQueue.main.async {
                  switch result {
                  case .success(let image): self.previewImageState = .loaded(image)
                  case .failure(let error): self.previewImageState = .loadError(error)
                  case nil: self.previewImageState = .notProvided
                  }
                }
              }
          }
        } else if previewImageState.image != nil {
          Image(uiImage: previewImageState.image!)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: Self.previewImageSize, maxHeight: Self.previewImageSize)
        } else if previewImageState.isNotProvided {
          Text("(none)")
        } else if previewImageState.error != nil {
          VStack(alignment: .leading) {
            Text("Error: \(previewImageState.error!.localizedDescription)")
            Button(action: { self.previewImageState = .loading }) { Text("Retry") }
          }
        }
      }
      SharedItemProperty(label: "registeredTypeIdentifiers", value: typeIdentifiersList)
      SharedItemProperty(label: "suggestedName", value: attachment.suggestedName)
    }
  }

  private var typeIdentifiersList: String {
    let bullet = attachment.registeredTypeIdentifiers.count == 1 ? "" : "• "
    return attachment.registeredTypeIdentifiers
      .map { line in "\(bullet)\(line)" }
      .joined(separator: "\n")
  }
}

extension AttachmentView {
  enum PreviewImageState {
    case loading
    case notProvided
    case loaded(UIImage)
    case loadError(Error)

    var isLoading: Bool { if case .loading = self { return true } else { return false } }
    var isNotProvided: Bool { if case .notProvided = self { return true } else { return false } }
    var image: UIImage? { if case .loaded(let image) = self { return image } else { return nil } }
    var error: Error? { if case .loadError(let error) = self { return error } else { return nil } }
  }
}

struct SharedItems_Previews: PreviewProvider {
  static var previews: some View {
    SharedItemsView(items: [])
  }
}
