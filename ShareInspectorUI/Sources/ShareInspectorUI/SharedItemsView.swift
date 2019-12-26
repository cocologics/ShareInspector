import ShareInspectorModel
import SwiftUI

// Used to insert line breaking hints into long words in text labels.
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
            SharedItemProperty(label: "attributed\(softHyphen)Title", richText: i.item.attributedTitle)
            SharedItemProperty(label: "attributed\(softHyphen)Content\(softHyphen)Text", richText: i.item.attributedContentText)
            SharedItemProperty(label: "Number of attachments", plainText: "\(i.item.attachments.count)")
            if i.item.userInfo != nil {
              NavigationLink(
                destination: DictionaryListView(dictionary: i.item.userInfo!)
                  .navigationBarTitle("NSExtensionItem\(softHyphen).userInfo")
              ) {
                SharedItemProperty(label: "userInfo", plainText: "\(i.item.userInfo!.count) key/value pairs")
              }
            } else {
              SharedItemProperty(label: "userInfo", plainText: nil)
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
        .bold()
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
