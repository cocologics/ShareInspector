import ShareInspectorModel
import SwiftUI

// Used to insert line breaking hints into long words in text labels.
let softHyphen = "\u{ad}"

struct SharedItemsView: View {
  @EnvironmentObject var store: Store
  var items: [SharedItem]
  var onFooterTap: (() -> Void)? = nil

  var body: some View {
    List {
      Section(footer: Text("The NSExtensionItems passed to the Share Extension via NSExtensionContext.inputItems.")) {
        SharedItemProperty(label: "Number of shared items", plainText: "\(items.count)")
      }

      ForEach(items.numbered(startingAt: 1), id: \.item.id) { (item, number) in
        Group {
          Section(header: Text("NSExtensionItem \(number) of \(self.items.count)").bold()) {
            SharedItemProperty(label: "attributed\(softHyphen)Title", richText: item.attributedTitle)
            SharedItemProperty(label: "attributed\(softHyphen)Content\(softHyphen)Text", richText: item.attributedContentText)
            SharedItemProperty(label: "Number of attachments", plainText: "\(item.attachments.count)")
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
            Section(header: Text("Item \(number) · Attachment \(number) of \(item.attachments.count) (NSItemProvider)").bold()) {
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
  var value: Value?

  init(label: String, plainText value: String?) {
    self.label = label
    self.value = value.map(Value.plainText)
  }

  init(label: String, richText value: NSAttributedString?) {
    self.label = label
    self.value = value.map(Value.richText)
  }

  var body: some View {
    HStack(alignment: value?.richText != nil ? .top : .firstTextBaseline) {
      Text(label)
        .font(.callout)
        .frame(minWidth: 100, alignment: .leading)
      Spacer()
      if value?.richText != nil {
        AttributedText(text: value!.richText!)
          .layoutPriority(1)
      } else {
        Text(value?.plainText ?? "(nil)")
          .multilineTextAlignment(.leading)
          .layoutPriority(1)
      }
    }
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
