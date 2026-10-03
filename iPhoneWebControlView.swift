//
//  iPhoneWebControlView.swift
//  CarPlayWebBrowser
//
//  Giao diện ứng dụng trên iPhone: Bộ điều khiển từ xa, bàn phím và nhập URL nhanh cho CarPlay.
//

import SwiftUI

struct iPhoneWebControlView: View {
    @State private var urlInput: String = ""
    @State private var statusMessage: String = "Sẵn sàng kết nối với màn hình CarPlay"
    @State private var activeTab: Int = 0
    
    let quickLinks = [
        ("Google", "https://www.google.com", "magnifyingglass"),
        ("YouTube", "https://m.youtube.com", "play.tv"),
        ("VnExpress", "https://vnexpress.net", "newspaper"),
        ("Dân Trí", "https://dantri.com.vn", "doc.text"),
        ("Zing MP3", "https://zingmp3.vn", "music.note"),
        ("Google Maps", "https://maps.google.com", "map"),
        ("Wikipedia", "https://vi.m.wikipedia.org", "book"),
        ("Báo Mới", "https://baomoi.com", "globe")
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header Status Card
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "car.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                        Text("Trạng Thái CarPlay")
                            .font(.headline)
                        Spacer()
                        Circle()
                            .fill(Color.green)
                            .frame(width: 10, height: 10)
                    }
                    
                    Text(statusMessage)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // URL / Search Input Bar
                VStack(alignment: .leading, spacing: 8) {
                    Text("Nhập Trang Web Hoặc Từ Khóa Tìm Kiếm")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("https://google.com hoặc từ khóa...", text: $urlInput, onCommit: {
                            sendURLToCarPlay(urlString: urlInput)
                        })
                        .textFieldStyle(PlainTextFieldStyle())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        
                        if !urlInput.isEmpty {
                            Button(action: { urlInput = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Button(action: {
                            sendURLToCarPlay(urlString: urlInput)
                        }) {
                            Text("Mở Trên Xe")
                                .font(.system(size: 14, weight: .bold))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding(10)
                    .background(Color(UIColor.tertiarySystemBackground))
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                
                // Navigation Control Buttons for CarPlay
                VStack(alignment: .leading, spacing: 10) {
                    Text("Bảng Điều Khiển Nhanh CarPlay")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 15) {
                        ControlButton(title: "Trang Chủ", systemImage: "house.fill") {
                            sendURLToCarPlay(urlString: "https://www.google.com")
                        }
                        
                        ControlButton(title: "Quay Lại", systemImage: "chevron.left") {
                            WebBrowserCarViewController.shared?.handleBack()
                        }
                        
                        ControlButton(title: "Tiến Tới", systemImage: "chevron.right") {
                            WebBrowserCarViewController.shared?.handleForward()
                        }
                        
                        ControlButton(title: "Tải Lại", systemImage: "arrow.clockwise") {
                            WebBrowserCarViewController.shared?.handleReload()
                        }
                    }
                }
                .padding(.horizontal)
                
                // Quick Bookmarks Grid
                VStack(alignment: .leading, spacing: 10) {
                    Text("Lối Tắt Trang Web Phổ Biến")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(quickLinks, id: \.1) { item in
                            Button(action: {
                                urlInput = item.1
                                sendURLToCarPlay(urlString: item.1)
                            }) {
                                HStack {
                                    Image(systemName: item.2)
                                        .font(.system(size: 18))
                                        .foregroundColor(.blue)
                                        .frame(width: 24)
                                    
                                    Text(item.0)
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "arrow.up.right.square")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .padding(12)
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(10)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("CarPlay Web Browser")
        }
    }
    
    private func sendURLToCarPlay(urlString: String) {
        guard !urlString.isEmpty else { return }
        
        if let controller = WebBrowserCarViewController.shared {
            controller.loadURL(urlString: urlString)
            statusMessage = "Đã mở: \(urlString) trên màn hình CarPlay"
        } else {
            statusMessage = "Đã gửi lệnh mở '\(urlString)'. Hãy kết nối CarPlay để hiển thị."
        }
    }
}

struct ControlButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.system(size: 20))
                Text(title)
                    .font(.system(size: 11, weight: .medium))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
        }
    }
}

struct iPhoneWebControlView_Previews: PreviewProvider {
    static var previews: some View {
        iPhoneWebControlView()
    }
}
