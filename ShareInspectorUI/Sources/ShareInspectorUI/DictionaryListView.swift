import SwiftUI

/// Displays a dictionary's contents in a List.
struct DictionaryListView: View {
  var keyValuePairs: [(key: String, value: Any)]

  init(dictionary: [String: Any]) {
    self.keyValuePairs = dictionary.sorted { lhs, rhs in
      lhs.key.localizedStandardCompare(rhs.key) == .orderedAscending
    }
  }

  var body: some View {
    List {
      ForEach(keyValuePairs, id: \.key) { key, value in
        Section {
          VStack(alignment: .leading, spacing: 8) {
            Text(key).bold()
            Text(String(describing: type(of: value)))
            Text(String(describing: value))
          }
        }
      }
    }
    .listStyle(.grouped)
  }
}

struct DictionaryListView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      DictionaryListView(dictionary: ["Key 1": "Value 1", "Key 2": 42])
        .navigationTitle("Preview")
        .navigationBarTitleDisplayMode(.inline)
    }
  }
}
