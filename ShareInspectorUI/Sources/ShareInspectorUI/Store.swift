import Combine
import CoreGraphics
import Foundation
import ShareInspectorModel

public final class Store: ObservableObject {
  @Published public private(set) var state: SharedItems

  public init(state: SharedItems) {
    self.state = state
  }
}

extension Store {
  public func loadPreviewImage(item: SharedItem.ID, attachment: Attachment.ID, preferredSize: CGSize) {
    state[sharedItem: item]?[attachment: attachment]?.previewImage = .loading
    state[sharedItem: item]?[attachment: attachment]?.loadPreviewImage(preferredSize) { result in
      switch result {
      case .success(let image):
        self.state[sharedItem: item]?[attachment: attachment]?.previewImage = .loaded(image)
      case .failure(let error):
        self.state[sharedItem: item]?[attachment: attachment]?.previewImage = .error(error)
      case nil:
        self.state[sharedItem: item]?[attachment: attachment]?.previewImage = .notProvided
      }
    }
  }

  public func loadFileRepresentation(item: SharedItem.ID, attachment: Attachment.ID, uti: String) {
    // Set initial state
    state[sharedItem: item]?[attachment: attachment]?.fileRepresentations[uti] = .loading(progress: 0)
    var progressObserver: NSKeyValueObservation?
    let progress = state[sharedItem: item]?[attachment: attachment]?.loadFileRepresentation(uti) { result in
      // Loading finished.
      // Stop observing progress object.
      progressObserver?.invalidate()
      progressObserver = nil
      // Update state with final result.
      switch result {
      case .success(let url):
        self.state[sharedItem: item]?[attachment: attachment]?.fileRepresentations[uti] = .loaded(url)
      case .failure(let error):
        self.state[sharedItem: item]?[attachment: attachment]?.fileRepresentations[uti] = .error(error)
      }
    }
    // Update state with loading progress.
    progressObserver = progress?.observe(\.fractionCompleted, options: .initial) { p, _ in
      self.state[sharedItem: item]?[attachment: attachment]?.fileRepresentations[uti] = .loading(progress: p.fractionCompleted)
    }
  }
}
