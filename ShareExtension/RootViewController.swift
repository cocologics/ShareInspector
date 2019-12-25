import SwiftUI
import UIKit

@objc(RootViewController)
final class RootViewController: UIViewController {
  var hostingVC: UIHostingController<SharedItemsView>!

  override func loadView() {
    super.loadView()
    hostingVC = UIHostingController(rootView: SharedItemsView())
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
