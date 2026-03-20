import SwiftUI
import WebKit

struct InstagramLockedWebView: UIViewRepresentable {
    let startURL: URL

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.preferences.javaScriptCanOpenWindowsAutomatically = false

        // Use the shared cookie store so existing Instagram login sessions work.
        config.websiteDataStore = .default()

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator

        // Prevent back/forward swipe navigation inside the webview.
        webView.allowsBackForwardNavigationGestures = false
        webView.scrollView.bounces = false

        webView.load(URLRequest(url: startURL))
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        // No-op
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(fallbackURL: InstagramChatConstants.fallbackURL)
    }

    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        private let fallbackURL: URL
        private var didReachDM: Bool = false

        init(fallbackURL: URL) {
            self.fallbackURL = fallbackURL
        }

        private func isInstagramHost(_ url: URL) -> Bool {
            guard let host = url.host else { return false }
            return InstagramChatConstants.allowedHosts.contains(host)
        }

        private func isFacebookHost(_ url: URL) -> Bool {
            guard let host = url.host else { return false }
            return host == "facebook.com" || host == "www.facebook.com"
        }

        private func allowedPath(_ path: String) -> Bool {
            if path.hasPrefix(InstagramChatConstants.dmPathPrefix) {
                return true
            }

            // Allow auth / login redirects even after locking, otherwise the wrapper can get stuck.
            for prefix in InstagramChatConstants.authPathPrefixes {
                if path.hasPrefix(prefix) {
                    return true
                }
            }

            return false
        }

        private func lockIfNeeded(_ url: URL) {
            if url.path.hasPrefix(InstagramChatConstants.dmPathPrefix) {
                didReachDM = true
            }
        }

        private func enforceLockDecision(for url: URL, decisionURL: URL) -> Bool {
            // If we've reached `/direct/...`, we only allow direct/auth paths.
            guard didReachDM else {
                // Before DM is reached, allow only DM and auth redirects.
                // Some Instagram auth flows may temporarily bounce through facebook.com.
                if isFacebookHost(url) {
                    return true
                }
                return allowedPath(url.path)
            }

            // After DM is reached, block everything except DM + auth.
            return allowedPath(url.path)
        }

        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.cancel)
                return
            }

            // Block non-https navigation.
            guard url.scheme == "https" || url.scheme == "http" else {
                decisionHandler(.cancel)
                return
            }

            // Ignore URLs that aren't Instagram.
            if !isInstagramHost(url) {
                // Allow facebook redirects only before we enter `/direct/...`.
                if !(isFacebookHost(url) && !didReachDM) {
                    decisionHandler(.cancel)
                    return
                }
            }

            lockIfNeeded(url)

            // If locked, prevent user from leaving DMs by tapping other tabs.
            let allowed = enforceLockDecision(for: url, decisionURL: fallbackURL)
            guard allowed else {
                decisionHandler(.cancel)
                webView.load(URLRequest(url: fallbackURL))
                return
            }

            decisionHandler(.allow)
        }

        // Prevent target="_blank" popups / new windows.
        func webView(
            _ webView: WKWebView,
            createWebViewWith configuration: WKWebViewConfiguration,
            for navigationAction: WKNavigationAction,
            windowFeatures: WKWindowFeatures
        ) -> WKWebView? {
            return nil
        }

        // Also block popups triggered by JS.
        func webView(
            _ webView: WKWebView,
            runJavaScriptAlertPanelWithMessage message: String,
            initiatedByFrame frame: WKFrameInfo,
            completionHandler: @escaping () -> Void
        ) {
            completionHandler()
        }
    }
}

