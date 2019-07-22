import UIKit

final class OverviewCell: UITableViewCell {
  static let reuseIdentifier = "OverviewCell"

  var viewModel: OverviewSectionViewModel? {
    didSet {
      if let viewModel = viewModel {
        overviewTextLabel.text = viewModel.text
      } else {
        overviewTextLabel.text = nil
      }
    }
  }

  @IBOutlet var overviewTextLabel: UILabel!

  override func prepareForReuse() {
    super.prepareForReuse()
    viewModel = nil
  }
}
