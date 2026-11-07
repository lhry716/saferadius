import SwiftUI
import UIKit

struct SafePalette {
    static let paper = Color(red: 0.973, green: 0.972, blue: 0.961)
    static let ink = Color(red: 0.118, green: 0.145, blue: 0.161)
    static let muted = Color(red: 0.49, green: 0.53, blue: 0.53)
    static let line = Color(red: 0.90, green: 0.92, blue: 0.91)
    static let red = Color(red: 0.86, green: 0.24, blue: 0.22)
    static let paleRed = Color(red: 0.98, green: 0.87, blue: 0.85)
    static let green = Color(red: 0.15, green: 0.57, blue: 0.39)
    static let dark = Color(red: 0.09, green: 0.11, blue: 0.14)
    static let darkCard = Color(red: 0.16, green: 0.19, blue: 0.23)
}

struct ContentView: View {
    @State private var model = AppModel()

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            SafePalette.paper.ignoresSafeArea()
            Group {
                switch model.phase {
                case .home: HomeView(model: model)
                case .searching: SearchingView(model: model)
                case .incoming: IncomingView(model: model)
                case .calling: CallView(model: model)
                case .ended: EndedView(model: model)
                case .resolved: ResolvedView(model: model)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            DemoMenu(model: model)
                .padding(.leading, 18)
                .padding(.bottom, 12)
        }
        .sheet(item: $model.sheet) { destination in
            switch destination {
            case .profile: ProfileSheet(model: model)
            case .chat: ChatSheet(model: model)
            case .map: MapSheet(model: model)
            case .emergency: EmergencySheet()
            }
        }
        .overlay(alignment: .top) {
            if let toast = model.toast {
                Text(toast)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(SafePalette.dark, in: Capsule())
                    .shadow(color: .black.opacity(0.16), radius: 14, y: 6)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: model.toast)
    }
}

private struct HomeView: View {
    @Bindable var model: AppModel
    @State private var holdStartedAt: Date?
    @FocusState private var descriptionFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                HStack(spacing: 9) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 30, height: 30)
                        .background(SafePalette.red, in: RoundedRectangle(cornerRadius: 10))
                    Text("SafeRadius")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .tracking(-0.6)
                        .foregroundStyle(SafePalette.ink)
                }
                Spacer()
                Button { model.sheet = .profile } label: {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 25, weight: .regular))
                        .foregroundStyle(SafePalette.muted)
                        .frame(width: 42, height: 42)
                        .background(.white, in: RoundedRectangle(cornerRadius: 15))
                        .overlay(RoundedRectangle(cornerRadius: 15).stroke(SafePalette.line, lineWidth: 1))
                }
                .accessibilityLabel("個人資訊與設定")
            }
            .padding(.top, 8)

            SOSControl(model: model, holdStartedAt: $holdStartedAt)
                .padding(.top, 24)

            VStack(alignment: .leading, spacing: 9) {
                HStack {
                    Text("簡單描述發生的事")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(SafePalette.ink)
                    Text("選填").font(.system(size: 10)).foregroundStyle(SafePalette.muted)
                    Spacer()
                    Text("\(model.eventDescription.count)/180")
                        .font(.system(size: 10, design: .rounded)).foregroundStyle(SafePalette.muted)
                }
                TextField("簡述目前狀況（選填）", text: $model.eventDescription, axis: .vertical)
                    .focused($descriptionFocused)
                    .lineLimit(2...4)
                    .font(.system(size: 12))
                    .foregroundStyle(SafePalette.ink)
                    .padding(13)
                    .background(Color.white, in: RoundedRectangle(cornerRadius: 15))
                    .overlay(RoundedRectangle(cornerRadius: 15).stroke(SafePalette.line, lineWidth: 1))
                    .onChange(of: model.eventDescription) { _, value in
                        if value.count > 180 { model.eventDescription = String(value.prefix(180)) }
                    }
                Text("協助者接聽前可查看")
                    .font(.system(size: 10)).foregroundStyle(SafePalette.muted)
            }
            .padding(.top, 21)

            Spacer(minLength: 8)
            HStack(spacing: 12) {
                Text("官方緊急電話").foregroundStyle(SafePalette.muted)
                Button("110") { model.sheet = .emergency }
                Rectangle().fill(SafePalette.line).frame(width: 1, height: 13)
                Button("119") { model.sheet = .emergency }
            }
            .font(.system(size: 11, weight: .medium))
            .buttonStyle(.plain)
            .padding(.top, 14)
            .padding(.bottom, 12)
        }
        .padding(.horizontal, 26)
        .padding(.top, 8)
        .background {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture { descriptionFocused = false }
        }
    }
}

private struct SOSControl: View {
    var model: AppModel
    @Binding var holdStartedAt: Date?

    var body: some View {
        VStack(spacing: 10) {
            TimelineView(.animation(minimumInterval: 1 / 30, paused: holdStartedAt == nil)) { context in
                let elapsed = holdStartedAt.map { context.date.timeIntervalSince($0) } ?? 0
                let progress = min(max(elapsed / 2, 0), 1)
                ZStack {
                    Circle().fill(Color(red: 1, green: 0.94, blue: 0.92)).frame(width: 244, height: 244)
                    Circle().stroke(SafePalette.paleRed, lineWidth: 1).frame(width: 236, height: 236)
                    Circle().stroke(SafePalette.paleRed.opacity(0.8), lineWidth: 1).frame(width: 195, height: 195)
                    Circle().trim(from: 0, to: progress)
                        .stroke(SafePalette.red, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 180, height: 180).rotationEffect(.degrees(-90))
                    VStack(spacing: 7) {
                        Image(systemName: "heart.fill").font(.system(size: 31, weight: .medium))
                        Text("SOS").font(.system(size: 27, weight: .heavy, design: .rounded)).tracking(2)
                        Text(holdStartedAt == nil ? "立即求助" : "持續按住…")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(width: 164, height: 164)
                    .background(SafePalette.red, in: Circle())
                    .shadow(color: SafePalette.red.opacity(0.2), radius: 17, y: 10)
                    .scaleEffect(holdStartedAt == nil ? 1 : 0.97)
                    .onLongPressGesture(minimumDuration: 2, maximumDistance: 20, pressing: { pressing in
                        if pressing { holdStartedAt = Date() } else { holdStartedAt = nil }
                    }, perform: {
                        holdStartedAt = nil
                        if model.hapticsEnabled { UIImpactFeedbackGenerator(style: .heavy).impactOccurred() }
                        model.startHelp()
                    })
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("SOS 立即求助")
                    .accessibilityHint("長按兩秒發出求助")
                }
            }
            Text(holdStartedAt == nil ? "長按 2 秒，發出求助" : "放開即可取消")
                .font(.system(size: 13, weight: .semibold)).foregroundStyle(SafePalette.ink.opacity(0.72))
        }
        .frame(maxWidth: .infinity)
    }
}

private struct SearchingView: View {
    var model: AppModel
    @State private var pulse = false
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button { model.reset() } label: { Image(systemName: "xmark").font(.system(size: 13, weight: .semibold)).foregroundStyle(SafePalette.muted).frame(width: 38, height: 38).background(.white, in: RoundedRectangle(cornerRadius: 12)) }
                VStack(alignment: .leading, spacing: 3) {
                    Text("求助已啟動").font(.system(size: 14, weight: .bold)).foregroundStyle(SafePalette.ink)
                    Text("等待協助者接聽").font(.system(size: 10)).foregroundStyle(SafePalette.muted)
                }
                Spacer()
            }.padding(.top, 8)

            ZStack {
                ForEach(0..<3) { index in
                    Circle().stroke(SafePalette.paleRed.opacity(0.75), lineWidth: 1)
                        .frame(width: CGFloat(138 + index * 60), height: CGFloat(138 + index * 60))
                        .scaleEffect(pulse ? 1.04 : 0.93)
                        .opacity(pulse ? 0.5 : 1)
                        .animation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true).delay(Double(index) * 0.24), value: pulse)
                }
                Image(systemName: "dot.radiowaves.left.and.right")
                    .font(.system(size: 38, weight: .regular)).foregroundStyle(SafePalette.red)
                    .frame(width: 100, height: 100).background(SafePalette.paleRed.opacity(0.6), in: Circle())
            }
            .frame(height: 285).padding(.top, 18).onAppear { pulse = true }

            Text("正在尋找協助者")
                .font(.system(size: 26, weight: .bold, design: .rounded)).tracking(-1).foregroundStyle(SafePalette.ink)
            Text("附近協助者將盡快接聽。\n你可以隨時取消求助。")
                .font(.system(size: 12)).lineSpacing(5).multilineTextAlignment(.center).foregroundStyle(SafePalette.muted).padding(.top, 9)
            if !model.eventDescription.isEmpty {
                VStack(alignment: .leading, spacing: 7) {
                    Label("求助說明", systemImage: "square.and.pencil").font(.system(size: 10, weight: .semibold)).foregroundStyle(SafePalette.muted)
                    Text(model.eventDescription).font(.system(size: 12)).foregroundStyle(SafePalette.ink).fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading).padding(15).background(.white, in: RoundedRectangle(cornerRadius: 17)).padding(.top, 22)
            }
            Spacer(minLength: 18)
            Label("等待協助者接聽", systemImage: "phone.fill")
                .font(.system(size: 12, weight: .medium)).foregroundStyle(SafePalette.muted)
                .padding(.vertical, 12)
            Button("取消求助") { model.reset() }.font(.system(size: 11, weight: .medium)).foregroundStyle(SafePalette.muted).padding(.top, 4)
        }
        .padding(.horizontal, 26).padding(.top, 8).padding(.bottom, 28)
    }
}

private struct IncomingView: View {
    var model: AppModel
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 0.14, green: 0.17, blue: 0.21), SafePalette.dark], startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
            ScrollView {
                VStack(spacing: 0) {
                    Label("附近即時求助", systemImage: "dot.radiowaves.left.and.right")
                        .font(.system(size: 12, weight: .semibold)).foregroundStyle(Color(red: 0.96, green: 0.63, blue: 0.59)).padding(.top, 36)
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 52, weight: .light)).foregroundStyle(Color.white.opacity(0.88))
                        .frame(width: 108, height: 108).background(Color.white.opacity(0.08), in: Circle())
                        .overlay(Circle().stroke(Color.white.opacity(0.18), lineWidth: 1)).padding(.top, 42)
                    Text("有人需要幫助").font(.system(size: 27, weight: .bold, design: .rounded)).foregroundStyle(.white).padding(.top, 23)
                    Text("正在等待你的回應").font(.system(size: 13)).foregroundStyle(Color.white.opacity(0.62)).padding(.top, 7)
                    VStack(alignment: .leading, spacing: 13) {
                        Text("求助資訊").font(.system(size: 10, weight: .semibold)).tracking(1.3).foregroundStyle(Color.white.opacity(0.65))
                        infoRow("求助類型", "即時語音求助")
                        infoRow("位置", "尚未分享")
                        infoRow("精確位置", "尚未分享")
                        VStack(alignment: .leading, spacing: 7) {
                            Text("求助者事件簡述").font(.system(size: 10, weight: .medium)).foregroundStyle(Color.white.opacity(0.58))
                            Text(model.eventDescription).font(.system(size: 12)).lineSpacing(4).foregroundStyle(.white).fixedSize(horizontal: false, vertical: true)
                        }.padding(.top, 3)
                    }
                    .padding(17).background(SafePalette.darkCard, in: RoundedRectangle(cornerRadius: 19))
                    .overlay(RoundedRectangle(cornerRadius: 19).stroke(Color.white.opacity(0.08), lineWidth: 1)).padding(.top, 32)
                    HStack(spacing: 48) {
                        actionButton("略過", icon: "xmark", color: Color.white.opacity(0.23)) { model.reset() }
                        actionButton("接聽協助", icon: "phone.fill", color: SafePalette.green) { model.acceptCall() }
                    }.padding(.top, 35)
                    Text("接聽代表願意通話，不代表必須親自前往現場。")
                        .font(.system(size: 10)).foregroundStyle(Color.white.opacity(0.55)).padding(.top, 22).padding(.bottom, 28)
                }.padding(.horizontal, 27)
            }
        }
        .preferredColorScheme(.dark)
    }
    private func infoRow(_ title: String, _ value: String) -> some View {
        HStack { Text(title).foregroundStyle(Color.white.opacity(0.57)); Spacer(); Text(value).foregroundStyle(.white) }.font(.system(size: 12))
    }
    private func actionButton(_ title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 9) {
                Image(systemName: icon).font(.system(size: 23, weight: .semibold)).foregroundStyle(.white)
                    .frame(width: 70, height: 70).background(color, in: Circle())
                Text(title).font(.system(size: 12, weight: .medium)).foregroundStyle(.white)
            }
        }.buttonStyle(.plain)
    }
}

private struct CallView: View {
    var model: AppModel
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 0.14, green: 0.17, blue: 0.21), SafePalette.dark], startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Text("SafeRadius").font(.system(size: 13, weight: .bold)).foregroundStyle(Color.white.opacity(0.85))
                    Text("/ \(model.role.title)視角").font(.system(size: 11)).foregroundStyle(Color.white.opacity(0.4))
                    Spacer()
                    HStack(spacing: 6) { Circle().fill(Color.green).frame(width: 6, height: 6); Text("語音已連接").font(.system(size: 10, weight: .medium)).foregroundStyle(Color.green.opacity(0.9)) }
                }.padding(.top, 8)

                VStack(spacing: 0) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 42, weight: .light)).foregroundStyle(Color.white.opacity(0.9))
                        .frame(width: 78, height: 78).background(Color.white.opacity(0.08), in: Circle()).padding(.bottom, 13)
                    Text(model.role.otherTitle).font(.system(size: 23, weight: .bold, design: .rounded)).foregroundStyle(.white)
                    TimelineView(.periodic(from: .now, by: 1)) { context in
                        let seconds = Int(context.date.timeIntervalSince(model.callStartedAt ?? context.date))
                        Text("通話中 · \(String(format: "%02d:%02d", max(0, seconds) / 60, max(0, seconds) % 60))")
                            .font(.system(size: 12, design: .rounded)).foregroundStyle(Color.white.opacity(0.6)).padding(.top, 7)
                    }
                    HStack(spacing: 4) {
                        ForEach([7.0, 14, 9, 12, 6], id: \.self) { height in
                            Capsule().fill(Color(red: 0.35, green: 0.81, blue: 0.61)).frame(width: 3, height: height)
                        }
                    }.padding(.top, 13)
                }.padding(.top, 29)

                HStack(spacing: 12) {
                    Image(systemName: model.assistance == .enRoute ? "figure.walk" : model.assistance == .arrived ? "checkmark.circle.fill" : "waveform")
                        .font(.system(size: 17)).foregroundStyle(Color(red: 0.47, green: 0.9, blue: 0.69))
                        .frame(width: 38, height: 38).background(Color.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 12))
                    VStack(alignment: .leading, spacing: 5) {
                        Text(model.assistanceTitle).font(.system(size: 13, weight: .semibold)).foregroundStyle(.white)
                        Text(model.assistanceDetail).font(.system(size: 10)).foregroundStyle(Color.white.opacity(0.65))
                    }
                    Spacer(minLength: 0)
                }.padding(13).background(SafePalette.darkCard, in: RoundedRectangle(cornerRadius: 18)).padding(.top, 21)

                HStack(alignment: .top, spacing: 8) {
                    Text("事件").font(.system(size: 10, weight: .bold)).foregroundStyle(Color.white.opacity(0.68))
                    Text(model.eventDescription.isEmpty ? "即時語音求助，尚未填寫事件簡述" : model.eventDescription)
                        .font(.system(size: 10)).foregroundStyle(Color.white.opacity(0.8)).lineLimit(2)
                    Spacer(minLength: 0)
                }.padding(11).overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.1), lineWidth: 1)).padding(.top, 10)

                if model.role == .helper {
                    Button { model.advanceAssistance() } label: {
                        Label(helperActionTitle, systemImage: helperActionIcon)
                            .font(.system(size: 12, weight: .semibold)).frame(maxWidth: .infinity).padding(.vertical, 14)
                            .foregroundStyle(model.assistance == .arrived ? SafePalette.ink : .white)
                            .background(model.assistance == .arrived ? Color.white : SafePalette.green, in: RoundedRectangle(cornerRadius: 14))
                    }.disabled(model.assistance == .arrived).padding(.top, 13)
                } else {
                    Button { model.locationShared.toggle(); model.showToast(model.locationShared ? "位置已分享" : "已停止分享位置") } label: {
                        Label(model.locationShared ? "已分享位置 · 點此停止" : "分享我的位置", systemImage: model.locationShared ? "checkmark" : "location.fill")
                            .font(.system(size: 12, weight: .semibold)).frame(maxWidth: .infinity).padding(.vertical, 14)
                            .foregroundStyle(.white).background(model.locationShared ? SafePalette.darkCard : SafePalette.green, in: RoundedRectangle(cornerRadius: 14))
                    }.padding(.top, 13)
                }

                Button { model.sheet = .map } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "map").font(.system(size: 17)).foregroundStyle(Color.white.opacity(0.8))
                        VStack(alignment: .leading, spacing: 3) {
                            Text("位置與導航").font(.system(size: 12, weight: .semibold)).foregroundStyle(.white)
                            Text(model.locationShared ? "已分享給配對協助者" : "精確位置尚未分享").font(.system(size: 10)).foregroundStyle(Color.white.opacity(0.55))
                        }
                        Spacer()
                        Image(systemName: "chevron.right").font(.system(size: 10, weight: .semibold)).foregroundStyle(Color.white.opacity(0.45))
                    }.padding(14).background(SafePalette.darkCard, in: RoundedRectangle(cornerRadius: 16))
                }.buttonStyle(.plain).padding(.top, 11)

                Spacer(minLength: 12)
                HStack(spacing: 0) {
                    controlButton(model.muted ? "mic.slash.fill" : "mic.fill", title: model.muted ? "取消靜音" : "靜音", selected: model.muted) { model.muted.toggle() }
                    controlButton(model.speakerOn ? "speaker.wave.2.fill" : "speaker.slash.fill", title: model.speakerOn ? "關閉擴音" : "擴音", selected: model.speakerOn) { model.speakerOn.toggle() }
                    controlButton("message", title: "訊息", selected: false) { model.sheet = .chat }
                    controlButton("phone.down.fill", title: "掛斷", selected: true, hang: true) { model.hangUp() }
                }.padding(.bottom, 12)
                Button { model.sheet = .emergency } label: {
                    Text("需要緊急服務？ 110／119").font(.system(size: 10)).foregroundStyle(Color.white.opacity(0.58)).underline()
                }.padding(.bottom, 8)
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
        }
        .preferredColorScheme(.dark)
    }

    private var helperActionTitle: String {
        switch model.assistance {
        case .talking: "我願意前往協助"
        case .offered: "我已開始前往"
        case .enRoute: "回報已抵達"
        case .arrived: "已回報抵達"
        }
    }
    private var helperActionIcon: String {
        switch model.assistance {
        case .talking: "heart.fill"
        case .offered: "location.north.fill"
        case .enRoute: "checkmark"
        case .arrived: "checkmark.circle.fill"
        }
    }
    private func controlButton(_ icon: String, title: String, selected: Bool, hang: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 7) {
                Image(systemName: icon).font(.system(size: 19, weight: .medium)).foregroundStyle(.white)
                    .frame(width: 54, height: 54).background(hang ? SafePalette.red : selected ? Color.white.opacity(0.25) : Color.white.opacity(0.12), in: Circle())
                Text(title).font(.system(size: 10)).foregroundStyle(Color.white.opacity(0.85))
            }.frame(maxWidth: .infinity)
        }.buttonStyle(.plain)
    }
}

private struct EndedView: View {
    var model: AppModel
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "phone.down.circle.fill").font(.system(size: 42)).foregroundStyle(SafePalette.muted)
            Text(model.role == .helper ? "通話已結束" : "你還需要幫助嗎？")
                .font(.system(size: 25, weight: .bold, design: .rounded)).foregroundStyle(SafePalette.ink)
            Text(model.role == .helper ? "本次語音已中斷，求助是否完成仍由求助者確認。" : "通話已結束，但這次求助尚未標記完成。")
                .font(.system(size: 12)).foregroundStyle(SafePalette.muted).multilineTextAlignment(.center).lineSpacing(4)
            if model.role == .helper {
                Button { model.role = .seeker } label: { Label("查看求助狀態", systemImage: "person.crop.circle") }
                    .buttonStyle(PrimaryButtonStyle()).padding(.top, 8)
                Button("返回首頁") { model.reset() }.buttonStyle(SecondaryButtonStyle())
            } else {
                Button { model.retrySearch() } label: { Label("繼續尋找協助者", systemImage: "dot.radiowaves.left.and.right") }
                    .buttonStyle(PrimaryButtonStyle()).padding(.top, 8)
                Button { model.resolveHelp() } label: { Label("我已安全，結束求助", systemImage: "checkmark.shield") }
                    .buttonStyle(SecondaryButtonStyle())
            }
            Text("掛斷語音不會自動結束求助事件")
                .font(.system(size: 10)).foregroundStyle(SafePalette.muted).padding(.top, 5)
            Spacer()
        }.padding(.horizontal, 28).frame(maxWidth: .infinity).background(SafePalette.paper.ignoresSafeArea())
    }
}

private struct ResolvedView: View {
    var model: AppModel
    var body: some View {
        VStack(spacing: 14) {
            Spacer()
            Image(systemName: "checkmark.shield.fill").font(.system(size: 48)).foregroundStyle(SafePalette.green)
            Text("求助已結束").font(.system(size: 26, weight: .bold, design: .rounded)).foregroundStyle(SafePalette.ink)
            Text("你已安全結束這次求助。")
                .font(.system(size: 12)).foregroundStyle(SafePalette.muted).multilineTextAlignment(.center)
            Button("返回首頁") { model.reset() }.buttonStyle(PrimaryButtonStyle()).padding(.top, 10)
            Spacer()
        }.padding(.horizontal, 28).frame(maxWidth: .infinity).background(SafePalette.paper.ignoresSafeArea())
    }
}

private struct DemoMenu: View {
    var model: AppModel
    var body: some View {
        Menu {
            Section("測試工具") {
                Button("回到首頁", systemImage: "house") { model.reset() }
                Button("模擬來電", systemImage: "phone.arrow.down.left") { model.simulateIncoming() }
                if model.phase == .searching { Button("模擬接聽", systemImage: "phone.fill") { model.acceptCall() } }
                if model.phase == .incoming { Button("接聽協助", systemImage: "phone.fill") { model.acceptCall() } }
                if model.phase == .calling || model.phase == .ended {
                    Button("切換求助者／協助者視角", systemImage: "person.2") {
                        model.role = model.role == .seeker ? .helper : .seeker
                    }
                    Button("加入對方訊息", systemImage: "message") { model.simulateReply() }
                    if model.role == .helper { Button("推進協助狀態", systemImage: "figure.walk") { model.advanceAssistance() } }
                }
            }
        } label: {
            Label("DEMO", systemImage: "slider.horizontal.3")
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 13).padding(.vertical, 9)
                .background(SafePalette.dark.opacity(0.94), in: Capsule())
        }
        .accessibilityLabel("DEMO 控制台")
        .padding(.bottom, 2)
    }
}

private struct ProfileSheet: View {
    @Bindable var model: AppModel
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(spacing: 14) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 27, weight: .medium))
                            .foregroundStyle(.white)
                            .frame(width: 62, height: 62)
                            .background(Color(red: 0.40, green: 0.46, blue: 0.50), in: Circle())
                        VStack(alignment: .leading, spacing: 4) {
                            Text(model.displayName).font(.system(size: 16, weight: .semibold))
                            Text("SafeRadius 帳戶").font(.system(size: 12)).foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 5)
                }
                Section {
                    TextField("顯示名稱", text: $model.displayName).textInputAutocapitalization(.never)
                    TextField("個人簡介", text: $model.bio, axis: .vertical).lineLimit(2...4)
                } header: { Text("個人資料") }
                Section("接收求助偏好") {
                    Toggle("接收附近求助", isOn: $model.notifyEnabled)
                    Toggle("通知聲音", isOn: $model.soundEnabled)
                    Toggle("震動回饋", isOn: $model.hapticsEnabled)
                }
                Section("基本設定") {
                    LabeledContent("位置權限", value: "尚未開啟")
                    LabeledContent("隱私", value: "配對後依授權分享位置")
                    LabeledContent("關於 SafeRadius", value: "SafeRadius")
                }
                Section {
                    Text("此版本尚未連接通話、定位與通知服務。")
                        .font(.footnote).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("個人資訊")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("完成") { model.sheet = nil } } }
        }
        .presentationDetents([.medium, .large]).presentationDragIndicator(.visible)
    }
}

private struct ChatSheet: View {
    @Bindable var model: AppModel
    @State private var draft = ""
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 13) {
                            ForEach(model.messages) { message in
                                ChatBubble(message: message, currentRole: model.role)
                                    .id(message.id)
                            }
                        }.padding(.horizontal, 17).padding(.vertical, 16)
                    }
                    .defaultScrollAnchor(.bottom)
                    .onChange(of: model.messages.count) { _, _ in
                        if let last = model.messages.last { withAnimation(.easeOut(duration: 0.2)) { proxy.scrollTo(last.id, anchor: .bottom) } }
                    }
                }
                HStack(spacing: 9) {
                    TextField("輸入訊息…", text: $draft, axis: .vertical).lineLimit(1...4)
                        .font(.system(size: 13)).padding(.horizontal, 13).padding(.vertical, 11)
                        .background(SafePalette.paper, in: RoundedRectangle(cornerRadius: 14))
                        .onSubmit(send)
                    Button(action: send) {
                        Image(systemName: "arrow.up").font(.system(size: 14, weight: .bold)).foregroundStyle(.white)
                            .frame(width: 42, height: 42).background(SafePalette.green, in: RoundedRectangle(cornerRadius: 14))
                    }.disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty).opacity(draft.isEmpty ? 0.55 : 1)
                }.padding(14).background(.white)
                Text("訊息已送出").font(.system(size: 9)).foregroundStyle(SafePalette.muted).padding(.bottom, 9)
            }
            .navigationTitle("即時訊息")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("完成") { model.sheet = nil } } }
        }
        .presentationDetents([.medium, .large]).presentationDragIndicator(.visible)
    }
    private func send() { model.sendMessage(draft); draft = "" }
}

private struct ChatBubble: View {
    let message: AppModel.Message
    let currentRole: AppModel.Role
    var body: some View {
        if let sender = message.sender {
            let mine = sender == currentRole
            VStack(alignment: mine ? .trailing : .leading, spacing: 4) {
                Text(mine ? "我" : sender.title).font(.system(size: 9)).foregroundStyle(SafePalette.muted).padding(.horizontal, 4)
                Text(message.text).font(.system(size: 12)).lineSpacing(3).foregroundStyle(mine ? .white : SafePalette.ink)
                    .padding(.horizontal, 13).padding(.vertical, 10)
                    .background(mine ? SafePalette.green : Color(red: 0.93, green: 0.95, blue: 0.93), in: RoundedRectangle(cornerRadius: 15))
            }.frame(maxWidth: .infinity, alignment: mine ? .trailing : .leading)
        } else {
            Text(message.text).font(.system(size: 10)).foregroundStyle(SafePalette.muted)
                .padding(.horizontal, 12).padding(.vertical, 8).background(SafePalette.paper, in: Capsule())
                .frame(maxWidth: .infinity)
        }
    }
}

private struct MapSheet: View {
    var model: AppModel
    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            Capsule().fill(Color.gray.opacity(0.25)).frame(width: 38, height: 5).frame(maxWidth: .infinity).padding(.top, 10)
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("位置與導航").font(.system(size: 21, weight: .bold, design: .rounded)).foregroundStyle(SafePalette.ink)
                    Text("需要時再展開，語音通話會持續進行").font(.system(size: 11)).foregroundStyle(SafePalette.muted)
                }
                Spacer()
                Button { model.sheet = nil } label: { Image(systemName: "xmark").font(.system(size: 11, weight: .bold)).foregroundStyle(SafePalette.muted).frame(width: 30, height: 30).background(SafePalette.paper, in: Circle()) }
            }
            if model.locationShared {
                MockMapView()
                    .frame(height: 225).clipShape(RoundedRectangle(cornerRadius: 20))
                HStack(spacing: 7) { Image(systemName: "shield.lefthalf.filled"); Text("路線預覽 · 僅本次協助者可見") }
                    .font(.system(size: 10)).foregroundStyle(SafePalette.muted)
                if model.role == .helper {
                    Label("路線資訊", systemImage: "figure.walk")
                        .font(.system(size: 11, weight: .medium)).foregroundStyle(SafePalette.ink)
                    Button { model.showToast("導航已開始") } label: {
                        Label("開始導航", systemImage: "location.north.fill")
                    }.buttonStyle(PrimaryButtonStyle())
                } else {
                    Button { model.locationShared = false; model.showToast("已停止分享位置") } label: {
                        Label("停止分享位置", systemImage: "location.slash")
                    }.buttonStyle(SecondaryButtonStyle())
                }
            } else {
                VStack(spacing: 9) {
                    Image(systemName: "lock.fill").font(.system(size: 25)).foregroundStyle(SafePalette.muted)
                    Text("尚未分享精確位置").font(.system(size: 13, weight: .semibold)).foregroundStyle(SafePalette.ink)
                    Text("求助者分享後，才會顯示精確位置。")
                        .font(.system(size: 11)).multilineTextAlignment(.center).foregroundStyle(SafePalette.muted)
                }.frame(maxWidth: .infinity).frame(height: 195).padding(10).background(SafePalette.paper, in: RoundedRectangle(cornerRadius: 18))
                if model.role == .seeker {
                    Button { model.locationShared = true; model.showToast("位置已分享") } label: {
                        Label("同意分享我的位置", systemImage: "location.fill")
                    }.buttonStyle(PrimaryButtonStyle())
                } else {
                    Text("等待求助者授權分享位置").font(.system(size: 11)).foregroundStyle(SafePalette.muted).frame(maxWidth: .infinity).padding(.vertical, 12)
                }
            }
            Spacer(minLength: 5)
        }
        .padding(.horizontal, 22).padding(.bottom, 22)
        .presentationDetents([.medium, .large]).presentationDragIndicator(.visible)
    }
}

private struct MockMapView: View {
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            ZStack {
                Color(red: 0.91, green: 0.94, blue: 0.89)
                RoundedRectangle(cornerRadius: 13).fill(Color(red: 0.84, green: 0.9, blue: 0.82)).frame(width: 78, height: 53).position(x: size.width * 0.2, y: size.height * 0.23)
                RoundedRectangle(cornerRadius: 10).fill(Color(red: 0.85, green: 0.91, blue: 0.84)).frame(width: 94, height: 58).position(x: size.width * 0.76, y: size.height * 0.25)
                RoundedRectangle(cornerRadius: 12).fill(Color(red: 0.87, green: 0.92, blue: 0.85)).frame(width: 84, height: 54).position(x: size.width * 0.23, y: size.height * 0.76)
                RoundedRectangle(cornerRadius: 11).fill(Color(red: 0.86, green: 0.92, blue: 0.84)).frame(width: 104, height: 49).position(x: size.width * 0.76, y: size.height * 0.77)
                Path { path in
                    path.move(to: CGPoint(x: size.width * 0.02, y: size.height * 0.48)); path.addLine(to: CGPoint(x: size.width * 0.98, y: size.height * 0.48))
                    path.move(to: CGPoint(x: size.width * 0.47, y: 0)); path.addLine(to: CGPoint(x: size.width * 0.47, y: size.height))
                }.stroke(.white, style: StrokeStyle(lineWidth: 17, lineCap: .round))
                Path { path in
                    path.move(to: CGPoint(x: size.width * 0.14, y: size.height * 0.86))
                    path.addCurve(to: CGPoint(x: size.width * 0.82, y: size.height * 0.17), control1: CGPoint(x: size.width * 0.26, y: size.height * 0.49), control2: CGPoint(x: size.width * 0.72, y: size.height * 0.59))
                }.stroke(.white, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                Path { path in
                    path.move(to: CGPoint(x: size.width * 0.14, y: size.height * 0.86))
                    path.addCurve(to: CGPoint(x: size.width * 0.82, y: size.height * 0.17), control1: CGPoint(x: size.width * 0.26, y: size.height * 0.49), control2: CGPoint(x: size.width * 0.72, y: size.height * 0.59))
                }.stroke(Color(red: 0.2, green: 0.48, blue: 0.68), style: StrokeStyle(lineWidth: 5, lineCap: .round, dash: [1, 0]))
                mapMarker(icon: "figure.walk", color: Color(red: 0.2, green: 0.48, blue: 0.68)).position(x: size.width * 0.14, y: size.height * 0.86)
                mapMarker(icon: "mappin.and.ellipse", color: SafePalette.red).position(x: size.width * 0.82, y: size.height * 0.17)
                Text("求助者位置").font(.system(size: 9, weight: .semibold)).padding(.horizontal, 8).padding(.vertical, 5).background(.white, in: Capsule()).position(x: size.width * 0.82, y: size.height * 0.08)
            }
        }
    }
    private func mapMarker(icon: String, color: Color) -> some View {
        Image(systemName: icon).font(.system(size: 13, weight: .bold)).foregroundStyle(.white)
            .frame(width: 32, height: 32).background(color, in: Circle()).overlay(Circle().stroke(.white, lineWidth: 3)).shadow(color: .black.opacity(0.2), radius: 5, y: 2)
    }
}

private struct EmergencySheet: View {
    var body: some View {
        VStack(spacing: 15) {
            Capsule().fill(Color.gray.opacity(0.25)).frame(width: 38, height: 5).padding(.top, 10)
            Text("官方緊急服務").font(.system(size: 22, weight: .bold, design: .rounded))
            Text("有立即危險或需要救護，請撥打官方緊急電話。")
                .font(.system(size: 12)).multilineTextAlignment(.center).foregroundStyle(SafePalette.muted)
            HStack(spacing: 12) {
                emergencyNumber("110", title: "警察")
                emergencyNumber("119", title: "消防救護")
            }
            Spacer(minLength: 10)
        }.padding(.horizontal, 24).presentationDetents([.medium]).presentationDragIndicator(.visible)
    }
    private func emergencyNumber(_ number: String, title: String) -> some View {
        VStack(spacing: 5) { Text(number).font(.system(size: 24, weight: .bold, design: .rounded)).foregroundStyle(SafePalette.ink); Text(title).font(.system(size: 11)).foregroundStyle(SafePalette.muted) }
            .frame(maxWidth: .infinity).padding(.vertical, 20).background(SafePalette.paper, in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.system(size: 13, weight: .semibold)).frame(maxWidth: .infinity).padding(.vertical, 15)
            .foregroundStyle(.white).background(SafePalette.red, in: RoundedRectangle(cornerRadius: 15))
            .scaleEffect(configuration.isPressed ? 0.985 : 1).animation(.easeOut(duration: 0.14), value: configuration.isPressed)
    }
}
private struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.system(size: 13, weight: .semibold)).frame(maxWidth: .infinity).padding(.vertical, 15)
            .foregroundStyle(SafePalette.ink).background(.white, in: RoundedRectangle(cornerRadius: 15))
            .overlay(RoundedRectangle(cornerRadius: 15).stroke(SafePalette.line, lineWidth: 1))
            .scaleEffect(configuration.isPressed ? 0.985 : 1).animation(.easeOut(duration: 0.14), value: configuration.isPressed)
    }
}

#Preview {
    ContentView()
}
