import UIKit

final class ShareViewController: UIViewController {
  var viewModel = ShareViewModel(extensionContext: nil) {
    didSet {
      guard isViewLoaded else { return }
      tableView?.reloadData()
    }
  }

  @IBOutlet var tableView: UITableView?
  private var reuseIdentifiers: Set<String> = []

  override func loadView() {
    super.loadView()
    viewModel = ShareViewModel(extensionContext: extensionContext)
  }

  @IBAction func done(_ sender: UIBarButtonItem) {
    extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
  }
}

extension ShareViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return viewModel.sections.count
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.sections[section].cells.count
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return viewModel.sections[section].sectionTitle
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let section = viewModel.sections[indexPath.section]
    let descriptor = section.cells[indexPath.row]

    // Register cell types lazily
    if descriptor.shouldRegisterCellClassWithTableView && !reuseIdentifiers.contains(descriptor.reuseIdentifier) {
      tableView.register(descriptor.cellClass, forCellReuseIdentifier: descriptor.reuseIdentifier)
      reuseIdentifiers.insert(descriptor.reuseIdentifier)
    }

    let cell = tableView.dequeueReusableCell(withIdentifier: descriptor.reuseIdentifier, for: indexPath)
    if let resizingCell = cell as? ResizingCell {
      resizingCell.cellDidResize = { [weak tableView] in
        guard let tableView = tableView else { return }
        tableView.beginUpdates()
        tableView.endUpdates()
      }
    }
    descriptor.configure(cell)
    return cell
  }
}
