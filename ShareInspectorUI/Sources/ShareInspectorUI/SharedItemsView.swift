import ShareInspectorModel
import SwiftUI

struct SharedItemsView: View {
  @EnvironmentObject var store: Store
  var items: [SharedItem]
  var onFooterTap: (() -> Void)? = nil

  var body: some View {
    List {
      Section {
        SharedItemProperty(label: "Number of shared items", detailLabel: "NSExtensionContext.inputItems.count", plainText: "\(items.count)")
      }

      ForEach(items.numbered(startingAt: 1), id: \.item.id) { (item, number) in
        Group {
          Section(header: Text("Item \(number) of \(self.items.count) (NSExtensionItem)")) {
            SharedItemProperty(label: "attributed\(softHyphen)Title", richText: item.attributedTitle)
            SharedItemProperty(label: "attributed\(softHyphen)Content\(softHyphen)Text", richText: item.attributedContentText)
            SharedItemProperty(label: "Number of attachments", detailLabel: "NSExtensionItem.attachments.count", plainText: "\(item.attachments.count)")
            if item.userInfo != nil {
              NavigationLink(
                destination: DictionaryListView(dictionary: item.userInfo!)
                  .navigationBarTitle("NSExtensionItem\(softHyphen).userInfo")
              ) {
                SharedItemProperty(label: "userInfo", plainText: "\(item.userInfo!.count) key/value pairs")
              }
            } else {
              SharedItemProperty(label: "userInfo", plainText: nil)
            }
          }

          ForEach(item.attachments.numbered(startingAt: 1), id: \.item.id) { (attachment, number) in
            Section(header: Text("Item \(number) · Attachment \(number) of \(item.attachments.count) (NSItemProvider)")) {
              AttachmentView(
                attachment: attachment,
                loadPreviewImage: { preferredSize in
                  self.store.loadPreviewImage(item: item.id, attachment: attachment.id, preferredSize: preferredSize)
                },
                loadFileRepresentation: { uti in
                  self.store.loadFileRepresentation(item: item.id, attachment: attachment.id, uti: uti)
                }
              )
            }
          }
        }
      }

      ListFooter(onTap: { self.onFooterTap?() })
    }
    .listStyle(GroupedListStyle())
  }
}

struct SharedItemProperty: View {
  enum Value {
    case plainText(String)
    case richText(NSAttributedString)

    var plainText: String? { if case .plainText(let text) = self { return text } else { return nil } }
    var richText: NSAttributedString? { if case .richText(let text) = self { return text } else { return nil } }
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
        if detailLabel != nil {
          Text(detailLabel!)
            .font(.caption)
            .foregroundColor(.secondary)
        }
      }
      .frame(minWidth: 100, alignment: .leading)
      Spacer()
      if value?.richText != nil {
        AttributedText(text: value!.richText!)
          .layoutPriority(1)
      } else {
        Text(value?.plainText ?? "(nil)")
          .bold()
          .multilineTextAlignment(.leading)
          .layoutPriority(1)
      }
    }
  }

  private var hStackAlignment: VerticalAlignment {
    if value?.richText != nil { return .top }
    else if detailLabel != nil { return .center }
    else { return .firstTextBaseline }
  }
}

struct SharedItemsView_Previews: PreviewProvider {
  static var previews: some View {
    SharedItemsView(items: [
      SharedItem(
        attributedTitle: NSAttributedString(
          string: "Hello World",
          attributes: [
            .link: URL(string: "https://cocologics.com")!,
          ]
        ),
        attributedContentText: NSAttributedString(
          string: "Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet.",
          attributes: [
            .font: UIFont.preferredFont(forTextStyle: .title1),
            .underlineStyle: NSUnderlineStyle.double.rawValue,
          ]
        ),
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
