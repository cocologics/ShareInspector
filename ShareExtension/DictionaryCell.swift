import UIKit

/// A UITableViewCell that displays a label and the contents of a dictionary.
/// The dictionary keys must be strings.
final class DictionaryCell: UITableViewCell, ReusableCell, ResizingCell {
  static let reuseIdentifier = "DictionaryCell"
  static let shouldRegisterCellClassWithTableView = false

  @IBOutlet var label: UILabel!
  /// The stack view in which the elements of the dictionary are displayed
  @IBOutlet var elementsStack: UIStackView!
  @IBOutlet var expandButton: UIButton!

  var viewModel: LabeledValue<[String: Any]?>? {
    didSet { updateUI() }
  }

  var isExpanded: Bool = false {
    didSet {
      updateUI()
      cellDidResize?()
    }
  }

  var cellDidResize: (() -> ())?

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
    expandButton.titleLabel?.adjustsFontForContentSizeCategory = true
    updateUI()
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    cellDidResize = nil
  }

  @IBAction func toggleExpandCollapse() {
    isExpanded.toggle()
  }

  private func updateUI() {
    // Remove all existing views in elementsStack
    for subview in elementsStack.arrangedSubviews {
      subview.removeFromSuperview()
    }

    // Rebuild elementsStack from current state
    if let viewModel = viewModel {
      label.text = viewModel.label
      expandButton.setTitle(isExpanded ? "Collapse" : "Expand", for: .normal)

      switch (viewModel.value, isExpanded) {
      case (let dict?, true):
        expandButton.isHidden = false
        let subStacks = dict
          .sorted(by: { $0.key < $1.key })
          .map(DictionaryCell.makeSubStack(element:))
        subStacks.forEach(elementsStack.addArrangedSubview)
      case (let dict?, false):
        expandButton.isHidden = false
        let infoLabel = UILabel()
        infoLabel.font = .preferredFont(forTextStyle: .body)
        infoLabel.text = "\(dict.count) key/value \(dict.count == 1 ? "pair" : "pairs")"
        elementsStack.addArrangedSubview(infoLabel)
      case (nil, _):
        expandButton.isHidden = true
        let nilLabel = UILabel()
        nilLabel.font = .preferredFont(forTextStyle: .body)
        nilLabel.text = "(nil)"
        elementsStack.addArrangedSubview(nilLabel)
      }
    } else {
      label.text = nil
      expandButton.isHidden = true
    }
  }

  private class func makeSubStack(element: (key: String, value: Any)) -> UIStackView {
    let (key, value) = element
    let keyLabel = UILabel()
    keyLabel.font = .preferredFont(forTextStyle: .body)
    keyLabel.numberOfLines = 0
    keyLabel.text = key

    let valueLabel = UILabel()
    valueLabel.font = .preferredFont(forTextStyle: .body)
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
