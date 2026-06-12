import AppKit

guard CommandLine.arguments.count >= 3 else {
    print("Usage: DMGBackground <icon-path> <output-path>")
    exit(1)
}

let iconPath = CommandLine.arguments[1]
let outputPath = CommandLine.arguments[2]

let width: CGFloat = 640
let height: CGFloat = 480

let image = NSImage(size: NSSize(width: width, height: height))

image.lockFocus()

let ctx = NSGraphicsContext.current!.cgContext

let colors = [
    NSColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1).cgColor,
    NSColor(red: 0.95, green: 0.95, blue: 0.96, alpha: 1).cgColor,
]
let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                          colors: colors as CFArray,
                          locations: [0.0, 1.0])!
ctx.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 0),
                       end: CGPoint(x: 0, y: height),
                       options: [])

let appIcon = NSImage(contentsOfFile: iconPath)
let iconSize: CGFloat = 128
let iconRect = CGRect(x: (width - iconSize) / 2, y: height - iconSize - 50, width: iconSize, height: iconSize)
appIcon?.draw(in: iconRect)

let title = "MacTomatoAlarm"
let titleAttrs: [NSAttributedString.Key: Any] = [
    .font: NSFont.boldSystemFont(ofSize: 28),
    .foregroundColor: NSColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1),
]
let titleSize = (title as NSString).size(withAttributes: titleAttrs)
let titleRect = CGRect(x: (width - titleSize.width) / 2, y: iconRect.minY - titleSize.height - 16,
                       width: titleSize.width, height: titleSize.height)
(title as NSString).draw(in: titleRect, withAttributes: titleAttrs)

let subtitle = "拖曳到 Applications 資料夾"
let subAttrs: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 16),
    .foregroundColor: NSColor(red: 0.45, green: 0.45, blue: 0.48, alpha: 1),
]
let subSize = (subtitle as NSString).size(withAttributes: subAttrs)
let subRect = CGRect(x: (width - subSize.width) / 2, y: titleRect.minY - subSize.height - 8,
                     width: subSize.width, height: subSize.height)
(subtitle as NSString).draw(in: subRect, withAttributes: subAttrs)

let arrowPath = NSBezierPath()
let arrowY: CGFloat = subRect.minY - 60
let arrowSize: CGFloat = 40
arrowPath.move(to: NSPoint(x: width / 2 - arrowSize, y: arrowY))
arrowPath.line(to: NSPoint(x: width / 2 + arrowSize, y: arrowY))
arrowPath.line(to: NSPoint(x: width / 2 + arrowSize - 12, y: arrowY - 10))
arrowPath.move(to: NSPoint(x: width / 2 + arrowSize, y: arrowY))
arrowPath.line(to: NSPoint(x: width / 2 + arrowSize - 12, y: arrowY + 10))

NSColor(red: 0.35, green: 0.35, blue: 0.38, alpha: 0.6).setStroke()
arrowPath.lineWidth = 2.5
arrowPath.lineCapStyle = .round
arrowPath.stroke()

let appLabel = "MacTomatoAlarm.app"
let appLabelAttrs: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 13),
    .foregroundColor: NSColor(red: 0.3, green: 0.3, blue: 0.33, alpha: 1),
]
let appLabelSize = (appLabel as NSString).size(withAttributes: appLabelAttrs)
(appLabel as NSString).draw(
    in: CGRect(x: width / 2 - arrowSize - appLabelSize.width - 20,
               y: arrowY - appLabelSize.height / 2,
               width: appLabelSize.width, height: appLabelSize.height),
    withAttributes: appLabelAttrs)

let appsLabel = "Applications"
let appsLabelAttrs: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 13),
    .foregroundColor: NSColor(red: 0.3, green: 0.3, blue: 0.33, alpha: 1),
]
let appsLabelSize = (appsLabel as NSString).size(withAttributes: appsLabelAttrs)
(appsLabel as NSString).draw(
    in: CGRect(x: width / 2 + arrowSize + 20,
               y: arrowY - appsLabelSize.height / 2,
               width: appsLabelSize.width, height: appsLabelSize.height),
    withAttributes: appsLabelAttrs)

image.unlockFocus()

guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
    print("Failed to create CGImage")
    exit(1)
}

let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
guard let pngData = bitmapRep.representation(using: .png, properties: [:]) else {
    print("Failed to create PNG data")
    exit(1)
}

try pngData.write(to: URL(fileURLWithPath: outputPath))
print("Background image created at \(outputPath)")
