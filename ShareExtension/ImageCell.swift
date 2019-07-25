import UIKit

/// A UITableViewCell that displays a label and an image.
/// The image is loaded dynamically by the cell.
final class ImageCell: UITableViewCell, ReusableCell, ResizingCell {
  static let reuseIdentifier = "ImageCell"
  static var shouldRegisterCellClassWithTableView = false

  @IBOutlet var label: UILabel!
  /// Displays meta information such as image size or error messages if loading fails.
  @IBOutlet var infoLabel: UILabel!
  @IBOutlet var thumbnailView: UIImageView!
  @IBOutlet var thumbnailViewHeightConstraint: NSLayoutConstraint!

  var viewModel: LabeledValue<LoadImageHandler>? {
    didSet {
      updateUI()
      viewModel?.value(CGSize(width: 300, height: 300)) { result in
        // TODO: Handle cell reuse. Do nothing if the cell has been reused in the meantime.
        DispatchQueue.main.async {
          self.loadedImage = result
        }
      }
    }
  }

  var cellDidResize: (() -> ())?

  private var loadedImage: Result<UIImage, Error>? {
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
    infoLabel.preferredMaxLayoutWidth = CGFloat.greatestFiniteMagnitude
    updateUI()
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    viewModel = nil
    cellDidResize = nil
  }

  private func updateUI() {
    if let viewModel = viewModel {
      label.text = viewModel.label
      switch loadedImage {
      case nil:
        thumbnailView.image = nil
        thumbnailViewHeightConstraint.constant = 50
        infoLabel.text = nil
      case .success(let image)?:
        thumbnailView.image = image
        thumbnailViewHeightConstraint.constant = 120
        infoLabel.text = "\(image.size.width) × \(image.size.height) pt"
      case .failure(let error):
        thumbnailView.image = nil
        if let error = error as? ShareInspectorError, error.code == .noPreviewImageProvided {
          thumbnailViewHeightConstraint.constant = 50
          infoLabel.text = "(none)"
        } else {
          thumbnailViewHeightConstraint.constant = 120
          infoLabel.text = "Loading error: \(error.localizedDescription)"
        }
      }
    } else {
      label.text = nil
      infoLabel.text = nil
      thumbnailView.image = nil
      thumbnailViewHeightConstraint.constant = 50
    }
  }
}
