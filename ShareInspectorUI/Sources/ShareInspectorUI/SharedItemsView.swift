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
            HStack {
              Text("attributedTitle")
              Spacer()
              Text(i.item.attributedTitle?.string ?? "(nil)")
            }
            HStack {
              Text("attributedContentText")
              Spacer()
              Text(i.item.attributedContentText?.string ?? "(nil)")
            }
            HStack {
              Text("Number of attachments")
              Spacer()
              Text("\(i.item.attachments.count)")
            }
          }

          ForEach(i.item.attachments.numbered(startingAt: 1)) { a in
            Section(header: Text("Item \(i.number) · Attachment \(a.number) of \(i.item.attachments.count) (NSItemProvider)")) {
              HStack {
                Text("suggestedName")
                Spacer()
                Text(a.item.suggestedName ?? "(nil)")
              }
            }
          }
        }
      }
    }
    .listStyle(GroupedListStyle())
  }
}

struct SharedItems_Previews: PreviewProvider {
  static var previews: some View {
    SharedItemsView(items: [])
  }
}
