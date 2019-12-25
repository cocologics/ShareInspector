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
    let rootView = SharedItemsNavigationView(state: state)
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
}
