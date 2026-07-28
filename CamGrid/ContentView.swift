import SwiftUI
import WebKit

struct CamGridWebView: NSViewRepresentable {
    final class Coordinator: NSObject, WKScriptMessageHandler {
        weak var webView: WKWebView?

        func userContentController(
            _ userContentController: WKUserContentController,
            didReceive message: WKScriptMessage
        ) {
            guard message.name == "camGridFullscreen",
                  let window = webView?.window else {
                return
            }

            window.toggleFullScreen(nil)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()

        configuration.userContentController.add(
            context.coordinator,
            name: "camGridFullscreen"
        )

        let webView = WKWebView(
            frame: .zero,
            configuration: configuration
        )

        context.coordinator.webView = webView

        webView.setValue(false, forKey: "drawsBackground")
        webView.allowsMagnification = true

        loadCamGrid(in: webView)

        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        // Nothing to update yet.
    }

    static func dismantleNSView(
        _ webView: WKWebView,
        coordinator: Coordinator
    ) {
        webView.configuration.userContentController
            .removeScriptMessageHandler(
                forName: "camGridFullscreen"
            )
    }

    private func loadCamGrid(in webView: WKWebView) {
        guard let indexURL = Bundle.main.url(
            forResource: "index",
            withExtension: "html"
        ) else {
            assertionFailure(
                "index.html was not found in the app bundle."
            )
            return
        }

        webView.loadFileURL(
            indexURL,
            allowingReadAccessTo:
                indexURL.deletingLastPathComponent()
        )
    }
}

struct ContentView: View {
    var body: some View {
        CamGridWebView()
            .frame(
                minWidth: 1000,
                minHeight: 650
            )
            .background(Color.black)
    }
}

#Preview {
    ContentView()
}
