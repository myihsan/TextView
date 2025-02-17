import SwiftUI

/// A SwiftUI TextView implementation that supports both scrolling and auto-sizing layouts
public struct TextView: View {

    @Environment(\.layoutDirection) private var layoutDirection

    @Binding private var text: NSMutableAttributedString
    @Binding private var selectedRange: NSRange
    @Binding private var markedTextRange: UITextRange?
    @Binding private var isEmpty: Bool

    @State private var calculatedHeight: CGFloat = 44

    private var onEditingChanged: (() -> Void)?
    private var shouldEditInRange: ((Range<String.Index>, String) -> Bool)?
    private var onCommit: (() -> Void)?

    var placeholderView: AnyView?
    var foregroundColor: UIColor = .label
    var autocapitalization: UITextAutocapitalizationType = .sentences
    var multilineTextAlignment: TextAlignment = .leading
    var font: UIFont = .preferredFont(forTextStyle: .body)
    var returnKeyType: UIReturnKeyType?
    var clearsOnInsertion: Bool = false
    var autocorrection: UITextAutocorrectionType = .default
    var truncationMode: NSLineBreakMode = .byTruncatingTail
    var keyboard: UIKeyboardType = .default
    var isEditable: Bool = true
    var isSelectable: Bool = true
    var isScrollingEnabled: Bool = false
    var enablesReturnKeyAutomatically: Bool?
    var autoDetectionTypes: UIDataDetectorTypes = []
    var allowRichText: Bool

    /// Makes a new TextView with the specified configuration
    /// - Parameters:
    ///   - text: A binding to the text
    ///   - shouldEditInRange: A closure that's called before an edit it applied, allowing the consumer to prevent the change
    ///   - onEditingChanged: A closure that's called after an edit has been applied
    ///   - onCommit: If this is provided, the field will automatically lose focus when the return key is pressed
    public init(_ text: Binding<String>,
                _ selectedRange: Binding<NSRange>,
                _ markedTextRange: Binding<UITextRange?>,
         shouldEditInRange: ((Range<String.Index>, String) -> Bool)? = nil,
         onEditingChanged: (() -> Void)? = nil,
         onCommit: (() -> Void)? = nil
    ) {
        _text = Binding(
            get: { NSMutableAttributedString(string: text.wrappedValue) },
            set: { text.wrappedValue = $0.string }
        )
      
        _selectedRange = selectedRange
        _markedTextRange = markedTextRange

        _isEmpty = Binding(
            get: { text.wrappedValue.isEmpty },
            set: { _ in }
        )

        self.onCommit = onCommit
        self.shouldEditInRange = shouldEditInRange
        self.onEditingChanged = onEditingChanged

        allowRichText = false
    }

    /// Makes a new TextView that supports `NSAttributedString`
    /// - Parameters:
    ///   - text: A binding to the attributed text
    ///   - onEditingChanged: A closure that's called after an edit has been applied
    ///   - onCommit: If this is provided, the field will automatically lose focus when the return key is pressed
    public init(_ text: Binding<NSMutableAttributedString>,
                _ selectedRange: Binding<NSRange>,
                _ markedTextRange: Binding<UITextRange?>,
                onEditingChanged: (() -> Void)? = nil,
                onCommit: (() -> Void)? = nil
    ) {
        _text = text
        _selectedRange = selectedRange
        _markedTextRange = markedTextRange
        _isEmpty = Binding(
            get: { text.wrappedValue.string.isEmpty },
            set: { _ in }
        )

        self.onCommit = onCommit
        self.onEditingChanged = onEditingChanged

        allowRichText = true
    }

    public var body: some View {
        Representable(
            text: $text,
            selectedRange: $selectedRange,
            markedTextRange: $markedTextRange,
            calculatedHeight: $calculatedHeight,
            foregroundColor: foregroundColor,
            autocapitalization: autocapitalization,
            multilineTextAlignment: multilineTextAlignment,
            font: font,
            returnKeyType: returnKeyType,
            clearsOnInsertion: clearsOnInsertion,
            autocorrection: autocorrection,
            truncationMode: truncationMode,
            isEditable: isEditable,
            keyboard: keyboard,
            isSelectable: isSelectable,
            isScrollingEnabled: isScrollingEnabled,
            enablesReturnKeyAutomatically: enablesReturnKeyAutomatically,
            autoDetectionTypes: autoDetectionTypes,
            allowsRichText: allowRichText,
            onEditingChanged: onEditingChanged,
            shouldEditInRange: shouldEditInRange,
            onCommit: onCommit
        )
        .frame(
            minHeight: isScrollingEnabled ? 0 : calculatedHeight,
            maxHeight: isScrollingEnabled ? .infinity : calculatedHeight
        )
        .background(
            placeholderView?
                .foregroundColor(Color(.placeholderText))
                .multilineTextAlignment(multilineTextAlignment)
                .font(Font(font))
                .padding(.horizontal, isScrollingEnabled ? 5 : 0)
                .padding(.vertical, isScrollingEnabled ? 8 : 0)
                .opacity(isEmpty ? 1 : 0),
            alignment: .topLeading
        )
    }

}

final class UIKitTextView: UITextView {

    override var keyCommands: [UIKeyCommand]? {
        return (super.keyCommands ?? []) + [
            UIKeyCommand(input: UIKeyCommand.inputEscape, modifierFlags: [], action: #selector(escape(_:)))
        ]
    }

    @objc private func escape(_ sender: Any) {
        resignFirstResponder()
    }

}
