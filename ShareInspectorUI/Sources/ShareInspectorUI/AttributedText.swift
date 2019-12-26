import SwiftUI

/// A view that can display an `NSAttributedString`.
/// Uses `UILabel` under the hood.
struct AttributedText: View {
  var text: NSAttributedString
  @State private var preferredSize: CGSize?

  var body: some View {
    GeometryReader { geometry in
      UILabelProxy(text: self.text, maxLayoutWidth: max(self.preferredSize?.width ?? 0, geometry.size.width))
        .background(GeometryReader { inner in
          Color.clear
            .preference(key: SizePreference.self, value: inner.size)
        })
        .frame(width: self.preferredSize?.width ?? 0, height: self.preferredSize?.height ?? 0)
        .fixedSize()
        .onPreferenceChange(SizePreference.self) {
          self.preferredSize = $0
      }
    }
    .frame(width: preferredSize?.width, height: preferredSize?.height)
  }
}

struct SizePreference: PreferenceKey {
  static var defaultValue: CGSize = .zero

  static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
    value = nextValue() == .zero ? value : nextValue()
  }
}

private struct UILabelProxy: UIViewRepresentable {
  var text: NSAttributedString
  var maxLayoutWidth: CGFloat

  func makeUIView(context: UIViewRepresentableContext<UILabelProxy>) -> UILabel {
    let label = UILabel()
    return label
  }

  func updateUIView(_ label: UILabel, context: UIViewRepresentableContext<UILabelProxy>) {
    label.attributedText = text
    label.preferredMaxLayoutWidth = maxLayoutWidth
    label.isEnabled = context.environment.isEnabled
    label.numberOfLines = context.environment.lineLimit ?? 0
    label.textAlignment = NSTextAlignment(multilineTextAlignment: context.environment.multilineTextAlignment)
  }
}

extension NSTextAlignment {
  init(multilineTextAlignment: TextAlignment) {
    switch multilineTextAlignment {
    // TODO: Take right-to-left scripts into account.
    case .leading: self = .left
    case .center: self = .center
    case .trailing: self = .right
    }
  }
}
