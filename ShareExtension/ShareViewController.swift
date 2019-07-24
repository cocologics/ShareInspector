import UIKit

protocol SectionViewModel {
  var rowCount: Int { get }
  var sectionTitle: String? { get }
}

struct OverviewSectionViewModel: SectionViewModel {
  var rowCount: Int { return 1 }
  var sectionTitle: String? { return "Overview" }

  var text: String
}

struct SharedItemSectionViewModel: SectionViewModel {
  var rowCount: Int { return 1 }
  var sectionTitle: String? {
    return "Shared Item \(number)"
  }

  var number: Int
  var attributedTitle: NSAttributedString?
  var attributedContentText: NSAttributedString?
  var attachmentCount: Int
  var userInfoText: String?
}

struct AttachmentsSectionViewModel: SectionViewModel {
  var rowCount: Int { return attachments.count }
  var sectionTitle: String? {
    return "\(attachments.count) \(attachments.count == 1 ? "attachment" : "attachments")"
  }

  var attachments: [Attachment]

  struct Attachment {
    var registeredTypeIdentifiers: [String]
    var suggestedName: String?
  }
}


struct ShareViewModel {
  var sections: [SectionViewModel]

  init(extensionContext: NSExtensionContext?) {
    var sections: [SectionViewModel] = []

    // Overview section
    guard let extensionContext = extensionContext else {
      sections.append(OverviewSectionViewModel(text: """
        Error: Share extension received no NSExtensionContext.
        """))
      self.sections = sections
      return
    }
    guard let sharedItems = extensionContext.inputItems as? [NSExtensionItem] else {
      sections.append(OverviewSectionViewModel(text:
        """
        Share extension received \(extensionContext.inputItems.count) shared \(extensionContext.inputItems.count == 1 ? "item" : "items").

        Error: Elements in extensionContext.inputItems are not of type NSExtensionItem.
        """))
      self.sections = sections
      return
    }
    sections.append(OverviewSectionViewModel(text: """
      Share extension received \(sharedItems.count) shared \(sharedItems.count == 1 ? "item" : "items").
      """))

    // Create content for all shared items
    for (counter, sharedItem) in zip(1..., sharedItems) {
      let attachments = sharedItem.attachments ?? []

      // Shared item overview
      sections.append(SharedItemSectionViewModel(
        number: counter,
        attributedTitle: sharedItem.attributedTitle,
        attributedContentText: sharedItem.attributedContentText,
        attachmentCount: attachments.count,
        userInfoText: sharedItem.userInfo.map(String.init(reflecting:)) ?? "(nil)"))

      // Attachments
      sections.append(AttachmentsSectionViewModel(attachments: attachments.map { itemProvider in
        AttachmentsSectionViewModel.Attachment(
          registeredTypeIdentifiers: itemProvider.registeredTypeIdentifiers,
          suggestedName: itemProvider.suggestedName)
      }))
    }

    self.sections = sections
  }
}

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
