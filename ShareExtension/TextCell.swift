import UIKit

/// A UITableViewCell that displays a label and a string value.
/// The value can be plain (`String`) or rich text (`NSAttributedString)`.
final class TextCell: UITableViewCell, ReusableCell {
  static let reuseIdentifier = "TextCell"
  static var shouldRegisterCellClassWithTableView = false

  @IBOutlet var label: UILabel!
  @IBOutlet var valueLabel: UILabel!

  var viewModel: LabeledValue<Text>? {
    didSet { updateUI() }
  }

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    updateUI()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }

  override func awakeFromNib() {
    super.awakeFromNib()
    updateUI()
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    viewModel = nil
  }

  private func updateUI() {
    if let viewModel = viewModel {
      label.text = viewModel.label
      switch viewModel.value {
      case .plain(let text): valueLabel.text = text
      case .rich(let attributedText): valueLabel.attributedText = attributedText
      }
    } else {
      label.text = nil
      valueLabel.text = nil
    }
  }
}
