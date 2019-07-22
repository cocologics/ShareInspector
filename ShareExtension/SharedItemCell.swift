import UIKit

final class SharedItemCell: UITableViewCell {
  static let reuseIdentifier = "SharedItemCell"

  var viewModel: SharedItemSectionViewModel? {
    didSet {
      if let viewModel = viewModel {
        attributedTitleLabel.attributedText = viewModel.attributedTitle ?? NSAttributedString(string: "(nil)")
        attributedContentTextLabel.attributedText = viewModel.attributedContentText ?? NSAttributedString(string: "(nil)")
        attachmentCountLabel.text = "\(viewModel.attachmentCount) \(viewModel.attachmentCount == 1 ? "attachment" : "attachments")"
        userInfoLabel.text = viewModel.userInfoText ?? "(nil)"
      } else {
        // TODO: reset font, textColor, and other style-related properties to their defaults
        // in case the previous attributed string overrode the defaults
        attributedTitleLabel.text = nil
        attributedContentTextLabel.text = nil
        attachmentCountLabel.text = nil
        userInfoLabel.text = nil
      }
    }
  }

  @IBOutlet var attributedTitleLabel: UILabel!
  @IBOutlet var attributedContentTextLabel: UILabel!
  @IBOutlet var attachmentCountLabel: UILabel!
  @IBOutlet var userInfoLabel: UILabel!

  override func prepareForReuse() {
    super.prepareForReuse()
    viewModel = nil
  }
}
