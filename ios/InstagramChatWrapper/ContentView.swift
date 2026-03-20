import SwiftUI

struct ContentView: View {
    var body: some View {
        InstagramLockedWebView(
            startURL: InstagramChatConstants.startDMInboxURL
        )
        .ignoresSafeArea()
    }
}

