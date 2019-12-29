import QuickLook
import SwiftUI

/// SwiftUI wrapper for QLPreviewController.
struct QuickLook: UIViewControllerRepresentable {
  var url: URL? = nil

  func makeCoordinator() -> Coordinator {
    Coordinator(url: url)
  }

  func makeUIViewController(context: UIViewControllerRepresentableContext<QuickLook>) -> QLPreviewController {
    let vc = QLPreviewController()
    vc.dataSource = context.coordinator
    return vc
  }

  func updateUIViewController(_ uiViewController: QLPreviewController, context: UIViewControllerRepresentableContext<QuickLook>) {
  }
}

extension QuickLook {
  class Coordinator {
    var url: URL?

    init(url: URL?) {
      self.url = url
    }
  }
}

extension QuickLook.Coordinator: QLPreviewControllerDataSource {
  func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
    url == nil ? 0 : 1
  }

  func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
    url! as NSURL
  }
}
