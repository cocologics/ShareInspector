import UIKit

/// A UITableViewCell that displays a label and an image.
/// The image is loaded dynamically by the cell.
final class ImageCell: UITableViewCell, ReusableCell {
  static let reuseIdentifier = "ImageCell"
  static let shouldRegisterCellClassWithTableView = false

  static let smallImageSize: CGFloat = 50
  static let largeImageSize: CGFloat = 120

  @IBOutlet var label: UILabel!
  /// Displays meta information such as image size or error messages if loading fails.
  @IBOutlet var infoLabel: UILabel!
  @IBOutlet var thumbnailView: UIImageView!
  @IBOutlet var thumbnailViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet var thumbnailViewWidthConstraint: NSLayoutConstraint!

  var viewModel: LabeledValue<LoadImageHandler>? {
    didSet {
      updateUI()
      viewModel?.value(CGSize(width: ImageCell.largeImageSize, height: 2 * ImageCell.largeImageSize)) { result in
        // TODO: Handle cell reuse. Do nothing if the cell has been reused in the meantime.
        DispatchQueue.main.async {
          self.loadedImage = result
        }
      }
    }
  }

  private var loadedImage: Result<UIImage, Error>? {
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
    infoLabel.preferredMaxLayoutWidth = CGFloat.greatestFiniteMagnitude
    updateUI()
  }

  private func updateUI() {
    if let viewModel = viewModel {
      label.text = viewModel.label
      switch loadedImage {
      case nil:
        thumbnailView.image = nil
        thumbnailViewHeightConstraint.constant = ImageCell.smallImageSize
        thumbnailViewWidthConstraint.constant = ImageCell.smallImageSize
        infoLabel.text = nil
      case .success(let image)?:
        let aspectRatio = image.size.width / image.size.height
        let isValidAspectRatio = aspectRatio.isFinite && aspectRatio > 0
        thumbnailView.image = image
        thumbnailViewHeightConstraint.constant = ImageCell.largeImageSize
        thumbnailViewWidthConstraint.constant =  isValidAspectRatio ? aspectRatio * ImageCell.largeImageSize : ImageCell.largeImageSize
        infoLabel.text = "\(image.size.width) × \(image.size.height) pt"
      case .failure(let error):
        thumbnailView.image = nil
        if let error = error as? ShareInspectorError, error.code == .noPreviewImageProvided {
          thumbnailViewHeightConstraint.constant = ImageCell.smallImageSize
          thumbnailViewWidthConstraint.constant = ImageCell.smallImageSize
          infoLabel.text = "(none)"
        } else {
          thumbnailViewHeightConstraint.constant = ImageCell.largeImageSize
          thumbnailViewWidthConstraint.constant = ImageCell.largeImageSize
          infoLabel.text = "Loading error: \(error.localizedDescription)"
        }
      }
    } else {
      label.text = nil
      infoLabel.text = nil
      thumbnailView.image = nil
      thumbnailViewHeightConstraint.constant = ImageCell.smallImageSize
      thumbnailViewWidthConstraint.constant = ImageCell.smallImageSize
    }
  }
}
