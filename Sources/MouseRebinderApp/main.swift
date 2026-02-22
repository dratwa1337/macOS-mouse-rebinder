import SwiftUI
import AppKit
import ApplicationServices

// Represents one selectable keyboard key in the UI.
struct KeyOption: Identifiable, Hashable {
    let id: String
    let label: String
    let keyCode: CGKeyCode?

    static let all: [KeyOption] = [
        KeyOption(id: "none", label: "None", keyCode: nil),
        KeyOption(id: "a", label: "A", keyCode: 0),
        KeyOption(id: "b", label: "B", keyCode: 11),
        KeyOption(id: "c", label: "C", keyCode: 8),
        KeyOption(id: "d", label: "D", keyCode: 2),
        KeyOption(id: "e", label: "E", keyCode: 14),
        KeyOption(id: "f", label: "F", keyCode: 3),
        KeyOption(id: "g", label: "G", keyCode: 5),
        KeyOption(id: "h", label: "H", keyCode: 4),
        KeyOption(id: "i", label: "I", keyCode: 34),
        KeyOption(id: "j", label: "J", keyCode: 38),
        KeyOption(id: "k", label: "K", keyCode: 40),
        KeyOption(id: "l", label: "L", keyCode: 37),
        KeyOption(id: "m", label: "M", keyCode: 46),
        KeyOption(id: "n", label: "N", keyCode: 45),
        KeyOption(id: "o", label: "O", keyCode: 31),
        KeyOption(id: "p", label: "P", keyCode: 35),
        KeyOption(id: "q", label: "Q", keyCode: 12),
        KeyOption(id: "r", label: "R", keyCode: 15),
        KeyOption(id: "s", label: "S", keyCode: 1),
        KeyOption(id: "t", label: "T", keyCode: 17),
        KeyOption(id: "u", label: "U", keyCode: 32),
        KeyOption(id: "v", label: "V", keyCode: 9),
        KeyOption(id: "w", label: "W", keyCode: 13),
        KeyOption(id: "x", label: "X", keyCode: 7),
        KeyOption(id: "y", label: "Y", keyCode: 16),
        KeyOption(id: "z", label: "Z", keyCode: 6),
        KeyOption(id: "1", label: "1", keyCode: 18),
        KeyOption(id: "2", label: "2", keyCode: 19),
        KeyOption(id: "3", label: "3", keyCode: 20),
        KeyOption(id: "4", label: "4", keyCode: 21),
        KeyOption(id: "5", label: "5", keyCode: 23),
        KeyOption(id: "6", label: "6", keyCode: 22),
        KeyOption(id: "7", label: "7", keyCode: 26),
        KeyOption(id: "8", label: "8", keyCode: 28),
        KeyOption(id: "9", label: "9", keyCode: 25),
        KeyOption(id: "0", label: "0", keyCode: 29),
        KeyOption(id: "f1", label: "F1", keyCode: 122),
        KeyOption(id: "f2", label: "F2", keyCode: 120),
        KeyOption(id: "f3", label: "F3", keyCode: 99),
        KeyOption(id: "f4", label: "F4", keyCode: 118),
        KeyOption(id: "f5", label: "F5", keyCode: 96),
        KeyOption(id: "f6", label: "F6", keyCode: 97),
        KeyOption(id: "f7", label: "F7", keyCode: 98),
        KeyOption(id: "f8", label: "F8", keyCode: 100),
        KeyOption(id: "f9", label: "F9", keyCode: 101),
        KeyOption(id: "f10", label: "F10", keyCode: 109),
        KeyOption(id: "f11", label: "F11", keyCode: 103),
        KeyOption(id: "f12", label: "F12", keyCode: 111),
        KeyOption(id: "control", label: "Control ⌃", keyCode: 59),
        KeyOption(id: "option", label: "Option ⌥", keyCode: 58),
        KeyOption(id: "command", label: "Command ⌘", keyCode: 55),
        KeyOption(id: "tilde", label: "Tilde (~)", keyCode: 50),
        KeyOption(id: "minus", label: "Minus (-)", keyCode: 27),
        KeyOption(id: "equal", label: "Equal (=)", keyCode: 24),
        KeyOption(id: "return", label: "Return", keyCode: 36),
        KeyOption(id: "escape", label: "Escape", keyCode: 53),
        KeyOption(id: "shift", label: "Shift", keyCode: 56),
        KeyOption(id: "space", label: "Space", keyCode: 49),
        KeyOption(id: "tab", label: "Tab", keyCode: 48),
        KeyOption(id: "fn", label: "Fn", keyCode: 63)
    ]

    static func byID(_ id: String) -> KeyOption {
        all.first(where: { $0.id == id }) ?? all[0]
    }
}

final class RebindStore: ObservableObject {
    // Any setting change is persisted and immediately applied to the event tap.
    @Published var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: "isEnabled")
            EventTapManager.shared.configure(enabled: isEnabled, mappings: mappings)
        }
    }

    @Published var mouse3KeyID: String {
        didSet {
            UserDefaults.standard.set(mouse3KeyID, forKey: "mouse3KeyID")
            EventTapManager.shared.configure(enabled: isEnabled, mappings: mappings)
        }
    }

    @Published var mouse4KeyID: String {
        didSet {
            UserDefaults.standard.set(mouse4KeyID, forKey: "mouse4KeyID")
            EventTapManager.shared.configure(enabled: isEnabled, mappings: mappings)
        }
    }

    @Published var mouse5KeyID: String {
        didSet {
            UserDefaults.standard.set(mouse5KeyID, forKey: "mouse5KeyID")
            EventTapManager.shared.configure(enabled: isEnabled, mappings: mappings)
        }
    }

    // Maps mouse button numbers (2/3/4) to macOS key codes.
    var mappings: [Int64: CGKeyCode] {
        var result: [Int64: CGKeyCode] = [:]
        let map = [2: mouse3KeyID, 3: mouse4KeyID, 4: mouse5KeyID]
        for (button, keyID) in map {
            if let keyCode = KeyOption.byID(keyID).keyCode {
                result[Int64(button)] = keyCode
            }
        }
        return result
    }

    init() {
        let defaults = UserDefaults.standard
        self.isEnabled = defaults.object(forKey: "isEnabled") as? Bool ?? true
        self.mouse3KeyID = defaults.string(forKey: "mouse3KeyID") ?? "none"
        self.mouse4KeyID = defaults.string(forKey: "mouse4KeyID") ?? "none"
        self.mouse5KeyID = defaults.string(forKey: "mouse5KeyID") ?? "none"

        EventTapManager.shared.configure(enabled: isEnabled, mappings: mappings)
    }
}

final class EventTapManager {
    static let shared = EventTapManager()

    // Accessed by both UI thread and event tap thread.
    private let lock = NSLock()
    private var tap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var eventThread: Thread?
    private var eventRunLoop: CFRunLoop?

    private var isEnabled = true
    private var mappings: [Int64: CGKeyCode] = [:]

    private init() {}

    // Updates runtime behavior and starts/stops tap as needed.
    func configure(enabled: Bool, mappings: [Int64: CGKeyCode]) {
        lock.lock()
        self.isEnabled = enabled
        self.mappings = mappings
        let needsTap = enabled && !mappings.isEmpty
        lock.unlock()

        if needsTap {
            startTapIfNeeded()
        } else {
            stopTap()
        }
    }

    private func startTapIfNeeded() {
        lock.lock()
        if tap != nil {
            lock.unlock()
            return
        }
        lock.unlock()

        // Requires Accessibility permission to observe/inject global input.
        if !AXIsProcessTrusted() {
            return
        }

        // Listen only to non-primary mouse button down/up events.
        let mask = (1 << CGEventType.otherMouseDown.rawValue) | (1 << CGEventType.otherMouseUp.rawValue)
        let callback: CGEventTapCallBack = { _, type, event, _ in
            EventTapManager.shared.handle(type: type, event: event)
        }

        guard let newTap = CGEvent.tapCreate(
            tap: .cghidEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(mask),
            callback: callback,
            userInfo: nil
        ) else {
            return
        }

        let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, newTap, 0)

        // Run the event tap on a dedicated run loop thread.
        let thread = Thread {
            let runLoop = CFRunLoopGetCurrent()
            self.lock.lock()
            self.eventRunLoop = runLoop
            self.lock.unlock()
            CFRunLoopAddSource(runLoop, source, .commonModes)
            CGEvent.tapEnable(tap: newTap, enable: true)
            CFRunLoopRun()
        }
        thread.name = "MouseRebinder.EventTap"

        lock.lock()
        self.tap = newTap
        self.runLoopSource = source
        self.eventThread = thread
        lock.unlock()

        thread.start()
    }

    private func stopTap() {
        lock.lock()
        guard let tap = tap else {
            lock.unlock()
            return
        }
        let source = runLoopSource
        let runLoop = eventRunLoop
        self.tap = nil
        self.runLoopSource = nil
        self.eventThread = nil
        self.eventRunLoop = nil
        lock.unlock()

        if let source {
            CFRunLoopSourceInvalidate(source)
        }
        CFMachPortInvalidate(tap)
        if let runLoop {
            CFRunLoopStop(runLoop)
        }
    }

    private func handle(type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        let button = event.getIntegerValueField(.mouseEventButtonNumber)

        lock.lock()
        let enabled = isEnabled
        let keyCode = mappings[button]
        lock.unlock()

        guard enabled, let keyCode else {
            // Pass through untouched when disabled or not mapped.
            return Unmanaged.passUnretained(event)
        }

        if type == .otherMouseDown {
            // Trigger on press so mapped actions can fire while mouse is moving.
            postKeystroke(keyCode: keyCode)
        }

        // Consume original mouse button event to avoid duplicate behavior.
        return nil
    }

    private func postKeystroke(keyCode: CGKeyCode) {
        guard let source = CGEventSource(stateID: .combinedSessionState),
              let keyDown = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: true),
              let keyUp = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: false) else {
            return
        }

        keyDown.post(tap: .cghidEventTap)
        keyUp.post(tap: .cghidEventTap)
    }
}

@main
struct MouseRebinderApp: App {
    @StateObject private var store = RebindStore()

    init() {
        // Prompt for Accessibility access on launch.
        let options = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as String: true] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(options)
    }

    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
                .frame(width: 420, height: 260)
        }
        .windowResizability(.contentSize)
    }
}

struct ContentView: View {
    @ObservedObject var store: RebindStore

    private var statusText: String {
        store.isEnabled ? "Active" : "Inactive"
    }

    private var statusColor: Color {
        store.isEnabled ? .green : .red
    }

    var body: some View {
        // Minimal configuration UI for three mouse buttons.
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Toggle("Enable rebinding", isOn: $store.isEnabled)
                Spacer()
                Circle()
                    .fill(statusColor)
                    .frame(width: 10, height: 10)
                Text(statusText)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: 340, alignment: .leading)

            mappingPicker(title: "Mouse3 (scroll click)", selection: $store.mouse3KeyID)
            mappingPicker(title: "Mouse4", selection: $store.mouse4KeyID)
            mappingPicker(title: "Mouse5", selection: $store.mouse5KeyID)

            Spacer()

            Text("Tip: Grant Accessibility permission in System Settings > Privacy & Security > Accessibility.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(20)
    }

    @ViewBuilder
    private func mappingPicker(title: String, selection: Binding<String>) -> some View {
        HStack {
            Text(title)
                .frame(width: 180, alignment: .leading)
            Picker(title, selection: selection) {
                ForEach(KeyOption.all) { option in
                    Text(option.label).tag(option.id)
                }
            }
            .labelsHidden()
            .frame(maxWidth: 450)
        }
    }
}
