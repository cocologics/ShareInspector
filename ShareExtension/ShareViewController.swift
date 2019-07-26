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
    tableView!.rowHeight = UITableView.automaticDimension
    viewModel = ShareViewModel(extensionContext: extensionContext)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    // Set our tint color on the parent navigation controller.
    // We do this from here because this is our entry point for the Share Extension.
    navigationController?.view.tintColor = .systemGreen
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

extension ShareViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    // Hack: Reload the cell in order to resize it (to fix autolayout issues)
    tableView.beginUpdates()
    tableView.reloadRows(at: [indexPath], with: .automatic)
    tableView.endUpdates()
    tableView.deselectRow(at: indexPath, animated: true)
  }
}
