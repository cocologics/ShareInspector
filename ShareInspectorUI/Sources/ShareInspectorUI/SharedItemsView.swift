import ShareInspectorModel
import SwiftUI

let softHyphen = "\u{ad}"

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
            SharedItemProperty(label: "attributed\(softHyphen)Title", value: i.item.attributedTitle?.string)
            SharedItemProperty(label: "attributed\(softHyphen)Content\(softHyphen)Text", value: i.item.attributedContentText?.string)
            SharedItemProperty(label: "Number of attachments", value: "\(i.item.attachments.count)")
            if i.item.userInfo != nil {
              NavigationLink(
                destination: DictionaryListView(dictionary: i.item.userInfo!)
                  .navigationBarTitle("NSExtensionItem\(softHyphen).userInfo")
              ) {
                SharedItemProperty(label: "userInfo", value: "\(i.item.userInfo!.count) key/value pairs")
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
        .bold()
        .frame(minWidth: 100, alignment: .leading)
      Spacer()
      Text(value ?? "(nil)")
        .multilineTextAlignment(.leading)
        .layoutPriority(1)
    }
  }
}

struct SharedItemsView_Previews: PreviewProvider {
  static var previews: some View {
    SharedItemsView(items: [
      SharedItem(
        attributedTitle: NSAttributedString(string: "Hello World"),
        attributedContentText: NSAttributedString(string: "Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet."),
        attachments: [
          Attachment(
            registeredTypeIdentifiers: ["public.jpg", "com.apple.live-photo", "public.heic"],
            suggestedName: "IMG_0001.JPG",
            previewImage: .success(UIImage(systemName: "pencil.and.ellipsis.rectangle")!)
          )
        ],
        userInfo: nil
      )
    ])
  }
}
