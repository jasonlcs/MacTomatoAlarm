import AppKit

/// Renders the menu bar label as a single coloured "pill" image so the
/// menu bar item shows a filled rounded-rectangle background (like other
/// status items) instead of a flat monochrome icon + text.
enum MenuBarLabelRenderer {
    /// Draws a rounded-rectangle pill containing the tinted icon and,
    /// optionally, the remaining-time text.
    /// - Parameters:
    ///   - symbolName: SF Symbol name to draw inside the pill.
    ///   - text: time string to show, or `nil` to show only the icon.
    ///   - color: pill background colour.
    static func render(symbolName: String, text: String?, color: NSColor) -> NSImage {
        let height: CGFloat = 20
        let iconSize: CGFloat = 15
        let horizontalPadding: CGFloat = 6
        let spacing: CGFloat = 3
        let cornerRadius: CGFloat = height / 2

        let font = NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .semibold)
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: NSColor.white,
        ]

        let attributed = text.map { NSAttributedString(string: $0, attributes: textAttributes) }
        let textSize = attributed?.size() ?? .zero

        let symbolConfig = NSImage.SymbolConfiguration(pointSize: iconSize, weight: .bold)
        let rawIcon = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil)
            ?? NSImage(systemSymbolName: "timer", accessibilityDescription: nil)
            ?? NSImage()
        let baseIcon = rawIcon.withSymbolConfiguration(symbolConfig) ?? rawIcon
        let whiteIcon = tinted(baseIcon, with: .white)
        let iconWidth = whiteIcon.size.width

        var contentWidth = iconWidth
        if attributed != nil {
            contentWidth += spacing + ceil(textSize.width)
        }
        let totalWidth = horizontalPadding * 2 + contentWidth

        let image = NSImage(size: NSSize(width: totalWidth, height: height), flipped: false) { _ in
            // Pill background
            let pillRect = NSRect(x: 0, y: 0, width: totalWidth, height: height)
            let path = NSBezierPath(roundedRect: pillRect, xRadius: cornerRadius, yRadius: cornerRadius)
            color.setFill()
            path.fill()

            // Icon
            let iconRect = NSRect(
                x: horizontalPadding,
                y: (height - whiteIcon.size.height) / 2,
                width: iconWidth,
                height: whiteIcon.size.height
            )
            whiteIcon.draw(in: iconRect)

            // Text
            if let attributed {
                let textOrigin = NSPoint(
                    x: horizontalPadding + iconWidth + spacing,
                    y: (height - textSize.height) / 2
                )
                attributed.draw(at: textOrigin)
            }
            return true
        }
        image.isTemplate = false
        return image
    }

    private static func tinted(_ image: NSImage, with color: NSColor) -> NSImage {
        let result = NSImage(size: image.size, flipped: false) { _ in
            image.draw(in: NSRect(origin: .zero, size: image.size))
            color.set()
            NSRect(origin: .zero, size: image.size).fill(using: .sourceAtop)
            return true
        }
        result.isTemplate = false
        return result
    }
}
