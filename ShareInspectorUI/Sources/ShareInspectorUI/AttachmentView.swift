import ShareInspectorModel
import SwiftUI

struct AttachmentView: View {
  var attachment: Attachment
  var loadPreviewImage: ((_ preferredSize: CGSize) -> Void)?
  var loadFileRepresentation: ((_ uti: String) -> Void)?

  @State private var quickLookUTI: String? = nil {
    didSet {
      print("quickLookUTI:", quickLookUTI ?? "nil")
    }
  }

  static var previewImageSize: CGFloat = 120

  var body: some View {
    HStack(alignment: .top) {
      Text("Preview Image")
        .font(.callout)
      Spacer()
      previewImage
    }

    SharedItemProperty(
      label: "registered\(softHyphen)Type\(softHyphen)Identifiers",
      plainText: typeIdentifiersList
    )
    SharedItemProperty(
      label: "suggested\(softHyphen)Name",
      plainText: attachment.suggestedName
    )

    ForEach(attachment.registeredTypeIdentifiers, id: \.self) { uti in
      switch attachment.fileRepresentation(for: uti) {
      case .notLoaded:
        Button("Load \(uti)") {
          quickLookUTI = uti
          loadFileRepresentation?(uti)
        }
      case .loaded(_):
        Button("Load \(uti)") {
          quickLookUTI = uti
        }
      case .loading(progress: let progress):
        Text("Loading: \(progress, specifier: "%.1f")")
      case .error(let error):
        Text("Error loading \(uti): \(error.localizedDescription)")
      }
    }
    .sheet(item: quickLookFileURL) { url in
      QuickLook(url: url)
    }
  }

  @ViewBuilder private var previewImage: some View {
    switch attachment.previewImage {
    case .notProvided:
      Text("(none provided)")
        .bold()

    case .notLoaded, .loading:
      let size = CGSize(width: Self.previewImageSize, height: Self.previewImageSize)
      Rectangle()
        .fill(Color(uiColor: .systemGray2))
        .frame(width: size.width, height: size.height)
        .onAppear {
          self.loadPreviewImage?(size)
      }

    case .loaded(let image):
      Image(uiImage: image)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(maxWidth: Self.previewImageSize, maxHeight: Self.previewImageSize)

    case .error(let error):
      VStack(alignment: .leading) {
        Text("⚠️ Error: \(error.localizedDescription)")
          .bold()
        Text("Domain: \((error as NSError).domain)")
          .font(.caption)
          .foregroundStyle(.secondary)
        Text("Code: \(String((error as NSError).code))")
          .font(.caption)
          .foregroundColor(.secondary)
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
        guard let uti = self.quickLookUTI else {
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
        self.quickLookUTI = nil
      }
    )
  }
}

// TODO: Workaround, not good
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
    return List {
      Section {
        AttachmentView(attachment: attachment1)
      }
      Section {
        AttachmentView(attachment: attachment2)
      }
      Section {
        AttachmentView(attachment: attachment3)
      }
    }
    .listStyle(.grouped)
  }
}

