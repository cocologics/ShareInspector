import UIKit

final class AttachmentCell: UITableViewCell {
  static let reuseIdentifier = "AttachmentCell"

  var viewModel: AttachmentsSectionViewModel.Attachment? {
    didSet {
      if let viewModel = viewModel {
        registeredTypesLabel.text = viewModel.registeredTypeIdentifiers.joined(separator: ", ")
        suggestedNameLabel.text = viewModel.suggestedName ?? "(nil)"
      } else {
        registeredTypesLabel.text = nil
        suggestedNameLabel.text = nil
      }
    }
  }

  @IBOutlet var registeredTypesLabel: UILabel!
  @IBOutlet var suggestedNameLabel: UILabel!

  override func prepareForReuse() {
    super.prepareForReuse()
    viewModel = nil
  }
}
