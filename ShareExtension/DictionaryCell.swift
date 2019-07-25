import UIKit

/// A UITableViewCell that displays a label and the contents of a dictionary.
/// The dictionary keys must be strings.
final class DictionaryCell: UITableViewCell, ReusableCell {
  static let reuseIdentifier = "DictionaryCell"
  static var shouldRegisterCellClassWithTableView = false

  @IBOutlet var label: UILabel!
  /// The stack view in which the elements of the dictionary are displayed
  @IBOutlet var elementsStack: UIStackView!

  var viewModel: LabeledValue<[String: Any]?>? {
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
      if let dict = viewModel.value {
        let subStacks = dict
          .sorted(by: { $0.key < $1.key })
          .map(DictionaryCell.makeSubStack(element:))
        subStacks.forEach(elementsStack.addArrangedSubview)
      } else {
        for subview in elementsStack.arrangedSubviews {
          subview.removeFromSuperview()
        }
        let nilLabel = UILabel()
        nilLabel.text = "(nil)"
        elementsStack.addArrangedSubview(nilLabel)
      }
    } else {
      label.text = nil
      for subview in elementsStack.arrangedSubviews {
        subview.removeFromSuperview()
      }
    }
  }

  private class func makeSubStack(element: (key: String, value: Any)) -> UIStackView {
    let (key, value) = element
    let keyLabel = UILabel()
    keyLabel.numberOfLines = 0
    keyLabel.text = key

    let valueLabel = UILabel()
    valueLabel.numberOfLines = 0
    valueLabel.text = String(describing: value)

    let stack = UIStackView(arrangedSubviews: [
      keyLabel,
      valueLabel
    ])
    stack.axis = .vertical
    stack.spacing = 4
    return stack
  }
}
