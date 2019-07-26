import UIKit

/// A UITableViewCell that displays a label and a string value.
/// The value can be plain (`String`) or rich text (`NSAttributedString)`.
final class TextCell: UITableViewCell, ReusableCell {
  static let reuseIdentifier = "TextCell"
  static var shouldRegisterCellClassWithTableView = false

  @IBOutlet var contentStack: UIStackView!
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
    label.preferredMaxLayoutWidth = CGFloat.greatestFiniteMagnitude
    valueLabel.preferredMaxLayoutWidth = CGFloat.greatestFiniteMagnitude
    updateUI()
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    viewModel = nil
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    let layoutAxis = preferredLayoutAxis
    switch layoutAxis {
    case .horizontal where contentStack.axis != .horizontal:
      contentStack.axis = .horizontal
      contentStack.distribution = .fill
      contentStack.alignment = .firstBaseline
      valueLabel.textAlignment = .right
    case .vertical where contentStack.axis != .vertical:
      contentStack.axis = .vertical
      contentStack.distribution = .fill
      contentStack.alignment = .fill
      valueLabel.textAlignment = .left
    default:
      break
    }
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

  private var preferredLayoutAxis: NSLayoutConstraint.Axis {
    let labelWidth = label.intrinsicContentSize.width
    let valueWidth = valueLabel.intrinsicContentSize.width
    let hasValidIntrinsicWidth = labelWidth != UIView.noIntrinsicMetric && valueWidth != UIView.noIntrinsicMetric
    guard hasValidIntrinsicWidth else {
      return .vertical
    }

    let valueHasLineBreaks = (valueLabel.text ?? "").lineCount > 1
    guard !valueHasLineBreaks else {
      return .vertical
    }

    let requiredWidthIfHorizontal = labelWidth + contentStack.spacing + valueWidth
    let hasEnoughHorizontalSpace = contentStack.bounds.width >= requiredWidthIfHorizontal
    return hasEnoughHorizontalSpace ? .horizontal : .vertical
  }
}
