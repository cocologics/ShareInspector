import SafariServices
import ShareInspectorModel
import ShareInspectorUI
import SwiftUI
import UIKit

@objc(RootViewController)
final class RootViewController: UIViewController {
  var hostingVC: UIHostingController<SharedItemsNavigationView>!

  override func loadView() {
    super.loadView()

    let state = SharedItems(extensionContext: extensionContext)
    let rootView = SharedItemsNavigationView(
      state: state,
      onCloseTap: { [unowned self] in self.closeShareExtension() },
      onFooterTap: { [unowned self] in self.openProCameraWebsite() }
    )
    hostingVC = UIHostingController(rootView: rootView)
    addChild(hostingVC)
    view.addSubview(hostingVC.view)
    hostingVC.view.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      hostingVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      hostingVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      hostingVC.view.topAnchor.constraint(equalTo: view.topAnchor),
      hostingVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
    hostingVC.didMove(toParent: self)
  }

  private func closeShareExtension() {
    extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
  }

  private func openProCameraWebsite() {
    // App extensions can't call UIApplication.shared.open(_:options:completionHandler:).
    // Use SFSafariViewController.
    let url = URL(string: "https://www.procamera-app.com")!
    let safari = SFSafariViewController(url: url)
    safari.modalPresentationStyle = .fullScreen
    // TODO: This doesn't seem to work. SFSafariViewController uses white status bar text
    // on a light background in light mode.
    safari.modalPresentationCapturesStatusBarAppearance = true
    present(safari, animated: true, completion: nil)
  }
}
