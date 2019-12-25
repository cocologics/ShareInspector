import ShareInspectorModel
import SwiftUI

struct SharedItemProperty: View {
  var label: String
  var value: String?

  var body: some View {
    HStack {
      Text(label)
      Spacer()
      Text(value ?? "(nil)")
    }
  }
}

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
              SharedItemProperty(label: "registeredTypeIdentifiers", value: self.typeIdentifiersList(for: a.item))
              SharedItemProperty(label: "suggestedName", value: a.item.suggestedName)
            }
          }
        }
      }
    }
    .listStyle(GroupedListStyle())
  }

  private func typeIdentifiersList(for attachment: Attachment) -> String {
    let bullet = attachment.registeredTypeIdentifiers.count == 1 ? "" : "• "
    return attachment.registeredTypeIdentifiers
      .map { line in "\(bullet)\(line)" }
      .joined(separator: "\n")
  }
}

struct SharedItems_Previews: PreviewProvider {
  static var previews: some View {
    SharedItemsView(items: [])
  }
}
