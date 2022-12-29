import ShareInspectorModel
import SwiftUI

struct SharedItemsView: View {
  @EnvironmentObject var store: Store
  var items: [SharedItem]

  var body: some View {
    List {
      Section {
        SharedItemProperty(
          label: "Number of shared items",
          detailLabel: "NSExtensionContext.inputItems.count",
          plainText: "\(items.count)"
        )
      }

      ForEach(items.numbered(startingAt: 1), id: \.item.id) { (item, number) in
        Section("Item \(number) of \(self.items.count) (NSExtensionItem)") {
          SharedItemView(item: item)
        }

        ForEach(item.attachments.numbered(startingAt: 1), id: \.item.id) { (attachment, number) in
          Section("Item \(number) · Attachment \(number) of \(item.attachments.count) (NSItemProvider)") {
            AttachmentView(
              attachment: attachment,
              loadPreviewImage: { preferredSize in
                store.loadPreviewImage(
                  item: item.id,
                  attachment: attachment.id,
                  preferredSize: preferredSize
                )
              },
              loadFileRepresentation: { uti in
                store.loadFileRepresentation(
                  item: item.id,
                  attachment: attachment.id,
                  uti: uti
                )
              }
            )
          }
        }
      }

      listFooter
    }
    .listStyle(.grouped)
  }

  @ViewBuilder private var listFooter: some View {
    Section {
      EmptyView()
    } header: {
      let text = try! AttributedString(markdown: "Made by Cocologics, makers of [ProCamera](https://www.procamera-app.com).")
      Text(text)
        .font(.body)
        .multilineTextAlignment(.center)
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, alignment: .center)
    }
  }
}

struct SharedItemView: View {
  var item: SharedItem

  var body: some View {
    SharedItemProperty(
      label: "attributed\(softHyphen)Title",
      richText: item.attributedTitle
    )
    SharedItemProperty(
      label: "attributed\(softHyphen)Content\(softHyphen)Text",
      richText: item.attributedContentText
    )
    SharedItemProperty(
      label: "Number of attachments",
      detailLabel: "NSExtensionItem.attachments.count",
      plainText: "\(item.attachments.count)"
    )
    if let userInfo = item.userInfo {
      NavigationLink {
        DictionaryListView(dictionary: userInfo)
          .navigationTitle("NSExtensionItem\(softHyphen).userInfo")
      } label: {
        SharedItemProperty(
          label: "userInfo",
          plainText: "\(userInfo.count) key/value pairs"
        )
      }
    } else {
      SharedItemProperty(label: "userInfo", plainText: nil)
    }
  }
}

struct SharedItemProperty: View {
  enum Value {
    case plainText(String)
    case richText(NSAttributedString)
  }

  var label: String
  var detailLabel: String?
  var value: Value?

  init(label: String, detailLabel: String? = nil, plainText value: String?) {
    self.label = label
    self.detailLabel = detailLabel
    self.value = value.map(Value.plainText)
  }

  init(label: String, detailLabel: String? = nil, richText value: NSAttributedString?) {
    self.label = label
    self.detailLabel = detailLabel
    self.value = value.map(Value.richText)
  }

  var body: some View {
    HStack(alignment: hStackAlignment) {
      VStack(alignment: .leading) {
        Text(label)
          .font(.callout)
        if let detailLabel {
          Text(detailLabel)
            .font(.caption)
            .foregroundColor(.secondary)
        }
      }
      .frame(minWidth: 100, alignment: .leading)

      Spacer()

      Group {
        switch value {
        case .richText(let richText)?:
          Text(AttributedString(richText))
        case .plainText(let plainText)?:
          Text(plainText).bold()
            .multilineTextAlignment(.leading)
        case nil:
          Text("nil").bold()
        }
      }
      .layoutPriority(1)
    }
  }

  private var hStackAlignment: VerticalAlignment {
    if case .richText? = value {
      return .top
    } else if detailLabel != nil {
      return .center
    } else {
      return .firstTextBaseline
    }
  }
}

struct SharedItemsView_Previews: PreviewProvider {
  static var previews: some View {
    SharedItemsView(items: [.sample])
      .environmentObject(Store(state: SharedItems(state: .success([.sample]))))
  }
}
