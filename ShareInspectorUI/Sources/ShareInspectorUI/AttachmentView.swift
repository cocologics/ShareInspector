import ShareInspectorModel
import SwiftUI

struct AttachmentView: View {
  var attachment: Attachment
  var loadPreviewImage: ((_ preferredSize: CGSize) -> Void)?
  var loadFileRepresentation: ((_ uti: String) -> Void)?

  @State private var selectedUTIForQuickLook: String? = nil {
    didSet {
      print("selectedUTIForQuickLook:", selectedUTIForQuickLook ?? "nil")
    }
  }

  static var previewImageSize: CGFloat = 120

  var body: some View {
    Group {
      HStack(alignment: .top) {
        Text("Preview Image")
          .bold()
        Spacer()
        if attachment.previewImage.isNotLoaded || attachment.previewImage.isLoading {
          Rectangle()
            .fill(Color(UIColor.systemGray2))
            .frame(width: Self.previewImageSize, height: Self.previewImageSize)
            .onAppear {
              self.loadPreviewImage?(CGSize(width: Self.previewImageSize, height: Self.previewImageSize))
          }
        } else if attachment.previewImage.image != nil {
          Image(uiImage: attachment.previewImage.image!)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: Self.previewImageSize, maxHeight: Self.previewImageSize)
        } else if attachment.previewImage.isNotProvided {
          Text("(none)")
        } else if attachment.previewImage.error != nil {
          VStack(alignment: .leading) {
            Text("Error: \(attachment.previewImage.error!.localizedDescription)")
            Button(action: { self.loadPreviewImage?(CGSize(width: Self.previewImageSize, height: Self.previewImageSize)) }) {
              Text("Retry")
            }
          }
        }
      }

      SharedItemProperty(label: "registered\(softHyphen)Type\(softHyphen)Identifiers", plainText: typeIdentifiersList)
      SharedItemProperty(label: "suggested\(softHyphen)Name", plainText: attachment.suggestedName)

      ForEach(attachment.registeredTypeIdentifiers, id: \.self) { uti in
        Group {
          if self.attachment.fileRepresentation(for: uti).isNotLoaded || self.attachment.fileRepresentation(for: uti).loaded != nil {
            Button(action: {
              self.selectedUTIForQuickLook = uti
              if self.attachment.fileRepresentation(for: uti).loaded == nil {
                self.loadFileRepresentation?(uti)
              }
            }) {
              Text("Load \(uti)")
            }
          } else if self.attachment.fileRepresentation(for: uti).loadingProgress != nil {
            Text("Loading: \(self.attachment.fileRepresentation(for: uti).loadingProgress!, specifier: "%.1f")")
          } else if self.attachment.fileRepresentation(for: uti).error != nil {
            Text("Error loading \(uti): \(self.attachment.fileRepresentation(for: uti).error!.localizedDescription)")
          }
        }
      }
      .sheet(item: self.quickLookFileURL) { url in
        QuickLook(url: url)
      }
    }
  }

  private var typeIdentifiersList: String {
    let bullet = attachment.registeredTypeIdentifiers.count == 1 ? "" : "• "
    return attachment.registeredTypeIdentifiers
      .map { line in "\(bullet)\(line)" }
      .joined(separator: "\n")
  }

  private var quickLookFileURL: Binding<URL?> {
    Binding(
      get: {
        guard let uti = self.selectedUTIForQuickLook else {
          return nil
        }
        switch self.attachment.fileRepresentation(for: uti) {
        case .loaded(let url):
          return url
        case .notLoaded, .loading, .error:
          return nil
        }
      },
      set: { newValue in
        assert(newValue == nil, "Binding should only ever be set to nil (when sheet is dismissed)")
        self.selectedUTIForQuickLook = nil
      }
    )
  }
}

extension URL: Identifiable {
  public var id: String { absoluteString }
}

struct AttachmentView_Previews: PreviewProvider {
  static var previews: some View {
    let attachment1 = Attachment(
      registeredTypeIdentifiers: ["public.jpg", "public.heic"],
      suggestedName: "IMG_0001.JPG",
      previewImage: nil
    )
    let attachment2 = Attachment(
      registeredTypeIdentifiers: ["public.jpg", "com.apple.live-photo", "public.heic"],
      suggestedName: "IMG_0001.JPG",
      previewImage: .success(UIImage(systemName: "pencil.and.ellipsis.rectangle")!)
    )
    let attachment3 = Attachment(
      registeredTypeIdentifiers: ["public.jpg", "public.heic"],
      suggestedName: "IMG_0001.JPG",
      previewImage: .failure(NSError(domain: NSCocoaErrorDomain, code: 999, userInfo: [NSLocalizedDescriptionKey: "Unable to load image: File not found."]))
    )
    return Group {
      AttachmentView(attachment: attachment1)
      AttachmentView(attachment: attachment2)
      AttachmentView(attachment: attachment3)
    }
    .padding()
    .previewLayout(.sizeThatFits)
  }
}

