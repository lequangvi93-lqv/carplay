//
//  WebBrowserCarViewController.swift
//  CarPlayWebBrowser
//
//  Giao diện Trình Duyệt Web Đồ Họa Đầy Đủ (Full Interactive WKWebView) trên CarPlay Screen.
//

import UIKit
import WebKit

class WebBrowserCarViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, UITextFieldDelegate {

    static weak var shared: WebBrowserCarViewController?
    
    // UI Elements
    private let topBarView = UIView()
    private let addressTextField = UITextField()
    private let backButton = UIButton(type: .system)
    private let forwardButton = UIButton(type: .system)
    private let reloadButton = UIButton(type: .system)
    private let homeButton = UIButton(type: .system)
    private let bookmarkButton = UIButton(type: .system)
    private let progressView = UIProgressView(progressViewStyle: .default)
    
    private var webView: WKWebView!
    private let bookmarksOverlayView = UIView()
    
    // Default Home Page
    private let defaultHomeURL = "https://www.google.com"

    override func viewDidLoad() {
        super.viewDidLoad()
        WebBrowserCarViewController.shared = self
        view.backgroundColor = .black
        
        setupWebView()
        setupTopBarUI()
        setupBookmarksOverlay()
        
        loadURL(urlString: defaultHomeURL)
    }
    
    // MARK: - Setup UI
    
    private func setupWebView() {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.allowsInlineMediaPlayback = true
        webConfiguration.mediaTypesRequiringUserActionForPlayback = []
        
        // Cấu hình mã giả lập User Agent hoặc Viewport cho màn hình xe hơi
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(webView)
        
        // Kích hoạt theo dõi tiến trình tải trang web
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        
        // Progress view
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progressTintColor = .systemBlue
        progressView.trackTintColor = .darkGray
        view.addSubview(progressView)
    }

    private func setupTopBarUI() {
        topBarView.backgroundColor = UIColor(white: 0.12, alpha: 1.0)
        topBarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topBarView)

        // Address TextField
        addressTextField.placeholder = "Nhập URL hoặc tìm kiếm Google..."
        addressTextField.borderStyle = .roundedRect
        addressTextField.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
        addressTextField.textColor = .white
        addressTextField.keyboardType = .URL
        addressTextField.autocapitalizationType = .none
        addressTextField.autocorrectionType = .no
        addressTextField.returnKeyType = .go
        addressTextField.delegate = self
        addressTextField.translatesAutoresizingMaskIntoConstraints = false
        
        // Custom placeholder color
        addressTextField.attributedPlaceholder = NSAttributedString(
            string: "Nhập trang web hoặc từ khóa...",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
        
        // Control Buttons
        configureButton(backButton, title: "◀", action: #selector(handleBack))
        configureButton(forwardButton, title: "▶", action: #selector(handleForward))
        configureButton(reloadButton, title: "🔄", action: #selector(handleReload))
        configureButton(homeButton, title: "🏠", action: #selector(handleHome))
        configureButton(bookmarkButton, title: "⭐", action: #selector(toggleBookmarks))

        let stackView = UIStackView(arrangedSubviews: [
            backButton, forwardButton, reloadButton, homeButton, addressTextField, bookmarkButton
        ])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        topBarView.addSubview(stackView)

        // Constraints Layout
        NSLayoutConstraint.activate([
            topBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBarView.heightAnchor.constraint(equalToConstant: 46),
            
            stackView.leadingAnchor.constraint(equalTo: topBarView.leadingAnchor, constant: 8),
            stackView.trailingAnchor.constraint(equalTo: topBarView.trailingAnchor, constant: -8),
            stackView.centerYAnchor.constraint(equalTo: topBarView.centerYAnchor),
            
            backButton.widthAnchor.constraint(equalToConstant: 36),
            forwardButton.widthAnchor.constraint(equalToConstant: 36),
            reloadButton.widthAnchor.constraint(equalToConstant: 36),
            homeButton.widthAnchor.constraint(equalToConstant: 36),
            bookmarkButton.widthAnchor.constraint(equalToConstant: 36),
            
            progressView.topAnchor.constraint(equalTo: topBarView.bottomAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 3),
            
            webView.topAnchor.constraint(equalTo: progressView.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func configureButton(_ button: UIButton, title: String, action: Selector) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = UIColor(white: 0.25, alpha: 1.0)
        button.layer.cornerRadius = 6
        button.addTarget(self, action: action, for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 34).isActive = true
    }
    
    // MARK: - Bookmark Grid Overlay
    
    private func setupBookmarksOverlay() {
        bookmarksOverlayView.backgroundColor = UIColor(white: 0.08, alpha: 0.95)
        bookmarksOverlayView.isHidden = true
        bookmarksOverlayView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bookmarksOverlayView)
        
        let titleLabel = UILabel()
        titleLabel.text = "Trang Web Yêu Thích & Lối Tắt Đơn Giản"
        titleLabel.textColor = .white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        bookmarksOverlayView.addSubview(titleLabel)
        
        let gridStack = UIStackView()
        gridStack.axis = .vertical
        gridStack.spacing = 10
        gridStack.distribution = .fillEqually
        gridStack.translatesAutoresizingMaskIntoConstraints = false
        bookmarksOverlayView.addSubview(gridStack)
        
        let bookmarks: [(String, String)] = [
            ("Google", "https://www.google.com"),
            ("YouTube", "https://m.youtube.com"),
            ("VnExpress", "https://vnexpress.net"),
            ("Dân Trí", "https://dantri.com.vn"),
            ("Zing MP3", "https://zingmp3.vn"),
            ("Google Maps", "https://maps.google.com"),
            ("Wikipedia", "https://vi.m.wikipedia.org"),
            ("Facebook", "https://m.facebook.com")
        ]
        
        var currentRow: UIStackView?
        for (index, item) in bookmarks.enumerated() {
            if index % 4 == 0 {
                currentRow = UIStackView()
                currentRow?.axis = .horizontal
                currentRow?.spacing = 10
                currentRow?.distribution = .fillEqually
                gridStack.addArrangedSubview(currentRow!)
            }
            
            let btn = UIButton(type: .system)
            btn.setTitle(item.0, for: .normal)
            btn.setTitleColor(.white, for: .normal)
            btn.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.8)
            btn.layer.cornerRadius = 8
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            btn.accessibilityHint = item.1
            btn.addTarget(self, action: #selector(bookmarkItemTapped(_:)), for: .touchUpInside)
            currentRow?.addArrangedSubview(btn)
        }
        
        NSLayoutConstraint.activate([
            bookmarksOverlayView.topAnchor.constraint(equalTo: topBarView.bottomAnchor),
            bookmarksOverlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bookmarksOverlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bookmarksOverlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: bookmarksOverlayView.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: bookmarksOverlayView.centerXAnchor),
            
            gridStack.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            gridStack.leadingAnchor.constraint(equalTo: bookmarksOverlayView.leadingAnchor, constant: 20),
            gridStack.trailingAnchor.constraint(equalTo: bookmarksOverlayView.trailingAnchor, constant: -20),
            gridStack.heightAnchor.constraint(equalToConstant: 140)
        ])
    }

    // MARK: - Actions
    
    @objc func handleBack() {
        if webView.canGoBack { webView.goBack() }
    }
    
    @objc func handleForward() {
        if webView.canGoForward { webView.goForward() }
    }
    
    @objc func handleReload() {
        webView.reload()
    }
    
    @objc func handleHome() {
        loadURL(urlString: defaultHomeURL)
    }
    
    @objc func toggleBookmarks() {
        bookmarksOverlayView.isHidden.toggle()
    }
    
    @objc func bookmarkItemTapped(_ sender: UIButton) {
        if let urlString = sender.accessibilityHint {
            bookmarksOverlayView.isHidden = true
            loadURL(urlString: urlString)
        }
    }
    
    public func loadURL(urlString: String) {
        var formattedURLString = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        if !formattedURLString.lowercased().hasPrefix("http://") && !formattedURLString.lowercased().hasPrefix("https://") {
            if formattedURLString.contains(".") && !formattedURLString.contains(" ") {
                formattedURLString = "https://" + formattedURLString
            } else {
                // Google Search Query
                let query = formattedURLString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                formattedURLString = "https://www.google.com/search?q=\(query)"
            }
        }
        
        if let url = URL(string: formattedURLString) {
            addressTextField.text = formattedURLString
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }

    // MARK: - UITextField Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let text = textField.text, !text.isEmpty {
            loadURL(urlString: text)
        }
        return true
    }
    
    // MARK: - WKNavigationDelegate & KVO
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
            progressView.isHidden = webView.estimatedProgress >= 1.0
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        addressTextField.text = webView.url?.absoluteString
        backButton.isEnabled = webView.canGoBack
        forwardButton.isEnabled = webView.canGoForward
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
    }
}
