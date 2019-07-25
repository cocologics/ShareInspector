import UIKit

/// A section in a table view.
protocol Section {
  var sectionTitle: String? { get }
  var cells: [CellDescriptor] { get }
}

/// A recipe for creating a specific table view cell.
///
/// Inspired by: [objc.io, Generic Table View Controllers](https://talk.objc.io/episodes/S01E26-generic-table-view-controllers-part-2)
struct CellDescriptor {
  let cellClass: UITableViewCell.Type
  let reuseIdentifier: String
  let shouldRegisterCellClassWithTableView: Bool
  // Type-erased in order to use multiple concrete CellDescriptor values
  // in a single table view.
  let configure: (UITableViewCell) -> ()

  init<Cell: UITableViewCell & ReusableCell>(configure: @escaping (Cell) -> ()) {
    self.cellClass = Cell.self
    self.reuseIdentifier = Cell.self.reuseIdentifier
    self.shouldRegisterCellClassWithTableView = Cell.self.shouldRegisterCellClassWithTableView
    self.configure = { cell in
      configure(cell as! Cell)
    }
  }
}

protocol ReusableCell {
  static var reuseIdentifier: String { get }
  /// Should be false if the table view doesn't have to register the cell class.
  /// For example, this is the case for cells that are created as prototype cells
  /// of the table view in a storyboard.
  /// Should be true for cells that are created in code.
  static var shouldRegisterCellClassWithTableView: Bool { get }
}

protocol ResizingCell: UITableViewCell {
  var cellDidResize: (() -> ())? { get set }
}
