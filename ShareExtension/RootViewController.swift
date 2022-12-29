import SafariServices
import ShareInspectorModel
import ShareInspectorUI
import SwiftUI
import UIKit

@objc(RootViewController)
final class RootViewController: UIViewController {
  override func loadView() {
    super.loadView()
    view.tintColor = UIColor(named: "pcTintColor")!

    let store = Store(state: SharedItems(extensionContext: extensionContext))
    let rootView = SharedItemsNavigationView(
      onCloseTap: { [unowned self] in self.closeShareExtension() }
    ).environmentObject(store)
    let hostingVC = UIHostingController(rootView: rootView)
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
}
