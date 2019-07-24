import UIKit

final class ShareViewController: UIViewController {
  var viewModel = ShareViewModel(extensionContext: nil) {
    didSet {
      guard isViewLoaded else { return }
      tableView?.reloadData()
    }
  }

  @IBOutlet var tableView: UITableView?

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
    return viewModel.sections[section].rowCount
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return viewModel.sections[section].sectionTitle
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let section = viewModel.sections[indexPath.section]
    switch section {
    case let s as OverviewSectionViewModel:
      let cell = tableView.dequeueReusableCell(withIdentifier: OverviewCell.reuseIdentifier, for: indexPath) as! OverviewCell
      assert(indexPath.row == 0, "Not expecting more than one row in this section, indexPath: \(indexPath)")
      cell.viewModel = s
      return cell
    case let s as SharedItemSectionViewModel:
      let cell = tableView.dequeueReusableCell(withIdentifier: SharedItemCell.reuseIdentifier, for: indexPath) as! SharedItemCell
      assert(indexPath.row == 0, "Not expecting more than one row in this section, indexPath: \(indexPath)")
      cell.viewModel = s
      return cell
    case let s as AttachmentsSectionViewModel:
      let cell = tableView.dequeueReusableCell(withIdentifier: AttachmentCell.reuseIdentifier, for: indexPath) as! AttachmentCell
      cell.viewModel = s.attachments[indexPath.row]
      return cell
    default:
      return tableView.dequeueReusableCell(withIdentifier: "UnknownCell", for: indexPath)
    }

//    cell.textLabel?.text = "\(attachments.count) \(attachments.count == 1 ? "attachment" : "attachments")"
//    cell.detailTextLabel?.text = String(describing: attachments.map { itemProvider in
//      itemProvider.registeredTypeIdentifiers
//    })
  }
}

extension ShareViewController: UITabBarDelegate {

}
