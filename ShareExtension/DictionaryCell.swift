import UIKit

/// A UITableViewCell that displays a label and the contents of a dictionary.
/// The dictionary keys must be strings.
final class DictionaryCell: UITableViewCell, ReusableCell, ResizingCell {
  static let reuseIdentifier = "DictionaryCell"
  static let shouldRegisterCellClassWithTableView = false

  @IBOutlet var label: UILabel!
  /// The stack view in which the elements of the dictionary are displayed
  @IBOutlet var elementsStack: UIStackView!
  @IBOutlet var collapseButton: UIButton!

  var viewModel: LabeledValue<[String: Any]?>? {
    didSet { updateUI() }
  }

  var cellDidResize: (() -> ())?

  var isCollapsed = true {
    didSet {
      updateUI()
      cellDidResize?()
    }
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
    updateUI()
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    viewModel = nil
    cellDidResize = nil
  }

  @IBAction func toggleCollapse() {
    self.isCollapsed.toggle()
  }

  private func updateUI() {
    collapseButton.setTitle(isCollapsed ? "Expand" : "Collapse", for: .normal)

    // Remove all existing views in elementsStack
    for subview in elementsStack.arrangedSubviews {
      subview.removeFromSuperview()
    }

    // Rebuild elementsStack from current state
    if let viewModel = viewModel {
      label.text = viewModel.label
      switch (viewModel.value, isCollapsed) {
      case (let dict?, true):
        collapseButton.isHidden = false
        let infoLabel = UILabel()
        infoLabel.text = "\(dict.count) key/value \(dict.count == 1 ? "pair" : "pairs")"
        elementsStack.addArrangedSubview(infoLabel)
      case (let dict?, false):
        collapseButton.isHidden = false
        let subStacks = dict
          .sorted(by: { $0.key < $1.key })
          .map(DictionaryCell.makeSubStack(element:))
        subStacks.forEach(elementsStack.addArrangedSubview)
      case (_, _):
        collapseButton.isHidden = true
        let nilLabel = UILabel()
        nilLabel.text = "(nil)"
        elementsStack.addArrangedSubview(nilLabel)
      }
    } else {
      label.text = nil
      collapseButton.isHidden = true
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
