import ShareInspectorModel
import SwiftUI

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
      SharedItemProperty(label: "registered\(softHyphen)Type\(softHyphen)Identifiers", value: typeIdentifiersList)
      SharedItemProperty(label: "suggested\(softHyphen)Name", value: attachment.suggestedName)
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

struct AttachmentView_Previews: PreviewProvider {
  static var previews: some View {
    return Group {
      VStack(spacing: 8) {
        AttachmentView(attachment: Attachment(
          registeredTypeIdentifiers: ["public.jpg", "public.heic"],
          suggestedName: "IMG_0001.JPG",
          previewImage: nil
        ))
      }
      VStack(spacing: 8) {
        AttachmentView(attachment: Attachment(
          registeredTypeIdentifiers: ["public.jpg", "com.apple.live-photo", "public.heic"],
          suggestedName: "IMG_0001.JPG",
          previewImage: .success(UIImage(systemName: "pencil.and.ellipsis.rectangle")!)
        ))
      }
      VStack(spacing: 8) {
        AttachmentView(attachment: Attachment(
          registeredTypeIdentifiers: ["public.jpg", "public.heic"],
          suggestedName: "IMG_0001.JPG",
          previewImage: .failure(NSError(domain: NSCocoaErrorDomain, code: 999, userInfo: [NSLocalizedDescriptionKey: "Unable to load image: File not found."]))
        ))
      }
    }
    .padding()
    .previewLayout(.sizeThatFits)
  }
}

