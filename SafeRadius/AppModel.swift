import Foundation
import Observation

@MainActor
@Observable
final class AppModel {
    enum Phase: Equatable { case home, searching, incoming, calling, ended, resolved }
    enum Role: String { case seeker, helper
        var title: String { self == .seeker ? "求助者" : "協助者" }
        var otherTitle: String { self == .seeker ? "你的協助者" : "求助者（匿名）" }
    }
    enum Assistance: Equatable { case talking, offered, enRoute, arrived }
    enum Sheet: String, Identifiable { case profile, chat, map, emergency
        var id: String { rawValue }
    }
    struct Message: Identifiable {
        let id = UUID()
        let sender: Role?
        let text: String
        let sentAt = Date()
    }

    var phase: Phase = .home
    var role: Role = .seeker
    var assistance: Assistance = .talking
    var sheet: Sheet?
    var notifyEnabled = true
    var soundEnabled = true
    var hapticsEnabled = true
    var locationShared = false
    var muted = false
    var speakerOn = false
    var eventDescription = ""
    var displayName = "訪客 01"
    var bio = "願意在能力範圍內協助附近的人。"
    var messages: [Message] = []
    var callStartedAt: Date?
    var toast: String?

    var assistanceTitle: String {
        switch assistance {
        case .talking: "正在語音協助"
        case .offered: "協助者準備前往"
        case .enRoute: "協助者前往中"
        case .arrived: "協助者已抵達"
        }
    }
    var assistanceDetail: String {
        switch assistance {
        case .talking: "雙方可以先確認情況與需要的協助"
        case .offered: "協助者已表示願意前往，尚未出發"
        case .enRoute: "已回報開始前往，可保持通話"
        case .arrived: "協助者已回報抵達現場"
        }
    }

    func startHelp() {
        phase = .searching
        role = .seeker
        assistance = .talking
        locationShared = false
        callStartedAt = nil
        showToast("展示模式：求助已啟動，尚未通知真實使用者")
    }

    func simulateIncoming() {
        guard notifyEnabled else {
            showToast("請先開啟接收附近求助")
            return
        }
        phase = .incoming
        role = .helper
        assistance = .talking
        if eventDescription.isEmpty {
            eventDescription = "我現在遇到一些狀況，希望附近有人可以先和我通話協助。"
        }
    }

    func acceptCall() {
        if messages.isEmpty {
            messages.append(Message(sender: nil, text: "已接通語音，可同時透過文字傳送資訊。"))
            if !eventDescription.isEmpty {
                messages.append(Message(sender: .seeker, text: eventDescription))
            }
            messages.append(Message(sender: .helper, text: "我先陪你通話，告訴我現在最需要什麼協助。"))
        }
        phase = .calling
        callStartedAt = Date()
        showToast("展示語音連線已接通")
    }

    func retrySearch() {
        phase = .searching
        role = .seeker
        assistance = .talking
        locationShared = false
        callStartedAt = nil
    }

    func hangUp() {
        phase = .ended
        callStartedAt = nil
    }

    func resolveHelp() {
        phase = .resolved
        locationShared = false
    }

    func reset() {
        phase = .home
        role = .seeker
        assistance = .talking
        locationShared = false
        muted = false
        speakerOn = false
        messages = []
        callStartedAt = nil
        eventDescription = ""
        sheet = nil
    }

    func advanceAssistance() {
        switch assistance {
        case .talking: assistance = .offered
        case .offered: assistance = .enRoute
        case .enRoute: assistance = .arrived
        case .arrived: break
        }
    }

    func sendMessage(_ text: String) {
        let clean = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return }
        messages.append(Message(sender: role, text: clean))
    }

    func simulateReply() {
        let sender: Role = role == .seeker ? .helper : .seeker
        let reply = role == .seeker
            ? "我先陪你通話。你可以移動到明亮、有人的地方嗎？"
            : "收到，我會陪你確認狀況。你分享位置後我再出發。"
        messages.append(Message(sender: sender, text: reply))
        showToast("已收到示範訊息")
    }

    func showToast(_ text: String) {
        toast = text
        Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(2.4))
            if self?.toast == text { self?.toast = nil }
        }
    }
}
