import Foundation
import ShareInspectorModel
import UIKit

extension SharedItem {
  static let sample: Self = SharedItem(
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
}
