import Foundation
import AppKit

struct UpdateChecker {
    static let shared = UpdateChecker()

    private let repo = "jasonlcs/MacTomatoAlarm"

    struct Release: Codable {
        let tagName: String
        let htmlUrl: String
        let assets: [Asset]

        enum CodingKeys: String, CodingKey {
            case tagName = "tag_name"
            case htmlUrl = "html_url"
            case assets
        }
    }

    struct Asset: Codable {
        let name: String
        let browserDownloadUrl: String

        enum CodingKeys: String, CodingKey {
            case name
            case browserDownloadUrl = "browser_download_url"
        }
    }

    var currentVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
    }

    var currentBuild: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0"
    }

    // MARK: - Public API

    func checkForUpdates(showUpToDate: Bool = false) async {
        let latest = await fetchLatestRelease()
        await MainActor.run {
            handleUpdateResult(latest, showUpToDate: showUpToDate)
        }
    }

    func autoCheckIfNeeded() async {
        let defaults = UserDefaults.standard
        guard defaults.bool(forKey: "autoCheckUpdates") else { return }
        let lastCheck = Date(timeIntervalSince1970: defaults.double(forKey: "lastUpdateCheck"))
        guard Date().timeIntervalSince(lastCheck) > 3600 else { return }
        defaults.set(Date().timeIntervalSince1970, forKey: "lastUpdateCheck")
        let latest = await fetchLatestRelease()
        guard let release = latest, isNewer(release.tagName, than: currentVersion) else { return }
        await MainActor.run {
            showUpdateAlert(release: release)
        }
    }

    // MARK: - Private

    private func fetchLatestRelease() async -> Release? {
        guard let url = URL(string: "https://api.github.com/repos/\(repo)/releases/latest") else {
            return nil
        }
        var request = URLRequest(url: url)
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")
        request.timeoutInterval = 10

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                return nil
            }
            let decoder = JSONDecoder()
            return try decoder.decode(Release.self, from: data)
        } catch {
            return nil
        }
    }

    private func isNewer(_ tagName: String, than current: String) -> Bool {
        let latest = tagName.hasPrefix("v") ? String(tagName.dropFirst()) : tagName
        return latest.compare(current, options: .numeric) == .orderedDescending
    }

    private func handleUpdateResult(_ release: Release?, showUpToDate: Bool) {
        guard let release else {
            showAlert(title: "檢查更新失敗", message: "無法連線至 GitHub，請稍後再試。")
            return
        }
        if isNewer(release.tagName, than: currentVersion) {
            showUpdateAlert(release: release)
        } else if showUpToDate {
            showAlert(title: "已是最新版本", message: "MacTomatoAlarm \(currentVersion) 是目前最新版本。")
        }
    }

    private func showUpdateAlert(release: Release) {
        let dmgAsset = release.assets.first { $0.name.hasSuffix(".dmg") }
        let downloadURL = dmgAsset?.browserDownloadUrl ?? release.htmlUrl

        let alert = NSAlert()
        alert.messageText = "有新版本可用"
        alert.informativeText = "MacTomatoAlarm \(release.tagName) 已發佈（目前版本 \(currentVersion)）。\n是否前往下載？"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "下載")
        alert.addButton(withTitle: "稍後")
        alert.icon = NSImage(named: NSImage.applicationIconName)

        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            if let url = URL(string: downloadURL) {
                NSWorkspace.shared.open(url)
            }
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .informational
        alert.addButton(withTitle: "好")
        alert.runModal()
    }
}
