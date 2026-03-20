# instagram-chat-pwa

## Option 3: Native iOS "messages-only" wrapper (WKWebView)

This repo started as a PWA redirect. For iOS, the closest way to reduce “temptation” is a native wrapper that loads Instagram DM pages and blocks navigation to other Instagram sections once you’re in `/direct/...`.

### Build steps in Xcode
1. Open Xcode.
2. Create a new iOS app project: **App** (SwiftUI).
3. Use any name (you can keep `InstagramChatWrapper`), and set a Bundle Identifier like `com.yourname.InstagramChatWrapper`.
4. In Xcode’s file navigator:
   - Add the Swift files from this repo:
     - `ios/InstagramChatWrapper/InstagramChatWrapperApp.swift`
     - `ios/InstagramChatWrapper/ContentView.swift`
     - `ios/InstagramChatWrapper/InstagramChatConstants.swift`
     - `ios/InstagramChatWrapper/InstagramLockedWebView.swift`
   - Replace your generated `ContentView.swift` with the repo one (or set your app entry to use it).
5. Run on a device.

### Notes / limitations
- This wrapper can block navigation away from `/direct/...` by intercepting link navigations inside the webview.
- It cannot stop every possible way of leaving the app (e.g. closing the app, iOS app switcher).
- Instagram may change its internal URLs/flows; if you notice the lock behavior breaking, we’ll adjust the allowed path rules.
