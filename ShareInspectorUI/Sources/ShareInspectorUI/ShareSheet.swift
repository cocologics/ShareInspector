import SwiftUI

/// Simple SwiftUI wrapper for UIActivityViewController.
///
/// - Note: Updating `sharedItems` after creation has no effect because it's not possible to change
///   the activity items on UIActivityViewController after it's been created. If you need update
///   functionality, you must probably wrap the UIActivityViewController in another view controller,
///   so that you can recreate the UIActivityViewController every time `updateUIViewController` is
///   called. See https://stackoverflow.com/a/57680383 for a possible solution.
public struct ShareSheet: UIViewControllerRepresentable {
  var sharedItems: [Any]

  public init(sharedItems: [Any]) {
    self.sharedItems = sharedItems
  }

  public func makeUIViewController(context: UIViewControllerRepresentableContext<ShareSheet>) -> UIActivityViewController {
    UIActivityViewController(activityItems: sharedItems, applicationActivities: nil)
  }

  public func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ShareSheet>) {
  }
}
