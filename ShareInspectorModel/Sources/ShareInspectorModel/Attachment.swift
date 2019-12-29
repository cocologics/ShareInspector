import Foundation
import UIKit

public struct Attachment: Identifiable {
  /// Type of the function for asynchronously loading the attachments's preview image.
  ///
  /// - Parameter preferredSize: The preferred image size in points. The returned
  ///   image may be bigger or smaller than this size.
  /// - Parameter callback: The callback function to call when loading has completed
  ///   or failed. The callback is passed the result of the loading process.
  ///   Possible values are `.success`, `.failure`, or `nil`. `nil` means the
  ///   item provider provided no preview image.
  ///   The callback is always called on `DispatchQueue.main`.
  public typealias LoadImageHandler = (_ preferredSize: CGSize, _ callback: @escaping (Result<UIImage, Error>?) -> Void) -> Void

  /// Type of the function for asynchronously loading a file representation of the attachment
  /// for a specified type identifier.
  ///
  /// - Parameter uti: The file type to load as a uniform type identifier (UTI), e.g. "public.jpeg".
  ///   Must be one of the elements in `registeredTypeIdentifiers`.
  /// - Parameter callback: The callback function to call when loading has completed
  ///   or failed. The callback is passed the result of the loading process.
  ///   The callback is always called on `DispatchQueue.main`.
  /// - Returns: Loading progress.
  public typealias LoadFileRepresentationHandler = (_ uti: String, _ callback: @escaping (Result<URL, Error>) -> Void) -> Progress

  public let id: UUID = UUID()
  public var registeredTypeIdentifiers: [String]
  public var suggestedName: String?

  public var loadPreviewImage: LoadImageHandler
  public var previewImage: PreviewImageState = .notLoaded

  public var loadFileRepresentation: LoadFileRepresentationHandler
  public var fileRepresentations: [String: FileRepresentationState] = [:]
}

extension Attachment {
  public init(registeredTypeIdentifiers: [String], suggestedName: String?, previewImage: Result<UIImage, Error>?) {
    self.registeredTypeIdentifiers = registeredTypeIdentifiers
    self.suggestedName = suggestedName
    self.loadPreviewImage = { _, callback in callback(previewImage) }
    self.loadFileRepresentation = { _, _ in Progress.discreteProgress(totalUnitCount: 1) }
  }

  init(nsItemProvider itemProvider: NSItemProvider) {
    self.init(
      registeredTypeIdentifiers: itemProvider.registeredTypeIdentifiers,
      suggestedName: itemProvider.suggestedName,
      loadPreviewImage: Self.makeLoadPreviewImageHandler(itemProvider: itemProvider),
      loadFileRepresentation: Self.makeLoadFileRepresentationHandler(itemProvider: itemProvider)
    )
  }

  public func fileRepresentation(for uti: String) -> FileRepresentationState {
    fileRepresentations[uti] ?? .notLoaded
  }

  private static func makeLoadPreviewImageHandler(itemProvider: NSItemProvider) -> LoadImageHandler {
    let loadPreviewImage: LoadImageHandler = { preferredSize, callback in
      let options: [AnyHashable: Any] = [
        NSItemProviderPreferredImageSizeKey: NSValue(cgSize: preferredSize)
      ]
      itemProvider.loadPreviewImage(options: options) { image, error in
        let result: Result<UIImage, Error>?
        switch (image, error) {
        case (let image as UIImage, _):
          result = .success(image)
        case (_?, _):
          result = .failure(error ?? ShareInspectorError.unableToCastToUIImage(actualType: "\(type(of: image))"))
        case (nil, let error?):
          result = .failure(error)
        case (nil, nil):
          // Item provider didn't provide a preview image
          result = nil
        }
        DispatchQueue.main.async {
          callback(result)
        }
      }
    }
    return loadPreviewImage
  }

  private static func makeLoadFileRepresentationHandler(itemProvider: NSItemProvider) -> LoadFileRepresentationHandler {
    let handler: LoadFileRepresentationHandler = { uti, callback in
      return itemProvider.loadFileRepresentation(forTypeIdentifier: uti) { url, error in
        let result: Result<URL, Error>
        switch (url, error) {
        case (let sourceURL?, _):
          do {
            // Copy file to a temp location we control as system will delete its file when this
            // completion handler returns.
            let fileManager = FileManager.default
            let cachesDir = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let subdir = cachesDir.appendingPathComponent("NSItemProvider-Attachments", isDirectory: true)
            if !fileManager.fileExists(atPath: subdir.path) {
              try fileManager.createDirectory(at: subdir, withIntermediateDirectories: true, attributes: nil)
            }
            let targetURL = subdir.appendingPathComponent(sourceURL.lastPathComponent)
            if fileManager.fileExists(atPath: targetURL.path) {
              try fileManager.removeItem(at: targetURL)
            }
            try fileManager.copyItem(at: sourceURL, to: targetURL)
            // TODO: Delete the file when we no longer need it.
            result = .success(targetURL)
          } catch {
            result = .failure(error)
          }
        case (nil, let error?):
          result = .failure(error)
        case (nil, nil):
          result = .failure(ShareInspectorError.unknown)
        }
        DispatchQueue.main.async {
          callback(result)
        }
      }
    }
    return handler
  }
}

extension Attachment {
  public enum PreviewImageState {
    case notLoaded
    case loading
    case notProvided
    case loaded(UIImage)
    case error(Error)

    public var isNotLoaded: Bool { if case .notLoaded = self { return true } else { return false } }
    public var isLoading: Bool { if case .loading = self { return true } else { return false } }
    public var isNotProvided: Bool { if case .notProvided = self { return true } else { return false } }
    public var image: UIImage? { if case .loaded(let image) = self { return image } else { return nil } }
    public var error: Error? { if case .error(let error) = self { return error } else { return nil } }
  }
}

extension Attachment {
  public enum FileRepresentationState {
    case notLoaded
    case loading(progress: Double)
    case loaded(URL)
    case error(Error)

    public var isNotLoaded: Bool { if case .notLoaded = self { return true } else { return false } }
    public var loadingProgress: Double? { if case .loading(let progress) = self { return progress } else { return nil } }
    public var loaded: URL? { if case .loaded(let url) = self { return url } else { return nil } }
    public var error: Error? { if case .error(let error) = self { return error } else { return nil } }
  }
}
