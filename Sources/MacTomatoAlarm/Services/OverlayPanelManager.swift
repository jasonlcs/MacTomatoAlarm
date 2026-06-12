import AppKit
import SwiftUI

@MainActor
final class OverlayPanelManager {
    static let shared = OverlayPanelManager()
    private var panel: NSPanel?
    private var hostingController: NSHostingController<OverlayTimerView>?

    func showOrUpdate(_ time: String, phase: TimerPhase) {
        let view = OverlayTimerView(text: time, phase: phase)
        if panel == nil {
            createPanel(with: view)
        } else {
            hostingController?.rootView = view
            hostingController?.view.setFrameSize(panel!.frame.size)
        }
        guard let panel, !panel.isVisible else { return }
        showAnimated()
    }

    func hide() {
        hideAnimated()
    }

    private func createPanel(with view: OverlayTimerView) {
        let rect = NSRect(x: 0, y: 0, width: 280, height: 100)
        let p = NSPanel(
            contentRect: rect,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        p.level = .floating
        p.isOpaque = false
        p.backgroundColor = .clear
        p.hasShadow = false
        p.ignoresMouseEvents = true
        p.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        let controller = NSHostingController(rootView: view)
        controller.view.frame = NSRect(origin: .zero, size: rect.size)
        p.contentViewController = controller

        panel = p
        hostingController = controller
    }

    private func showAnimated() {
        guard let panel, let screen = NSScreen.main else { return }

        let w = panel.frame.width
        let h = panel.frame.height
        let x = (screen.frame.width - w) / 2
        let menuBarBottom = screen.visibleFrame.maxY
        let targetY = menuBarBottom - h
        let startY = screen.frame.height + 10

        panel.setFrame(NSRect(x: x, y: startY, width: w, height: h), display: false)
        panel.orderFront(nil)
        panel.setFrame(NSRect(x: x, y: targetY, width: w, height: h), display: true, animate: true)
    }

    private func hideAnimated() {
        guard let panel, let screen = NSScreen.main else { return }

        let x = panel.frame.origin.x
        let targetY = screen.frame.height + 10
        let w = panel.frame.width
        let h = panel.frame.height
        let target = NSRect(x: x, y: targetY, width: w, height: h)

        panel.setFrame(target, display: true, animate: true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.panel?.orderOut(nil)
        }
    }
}
