import SwiftUI
import Combine

class KeyboardObserver: ObservableObject {
    @Published var keyboardHeight: CGFloat = 0
    private var cancellable: AnyCancellable?

    init() {
        cancellable = NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)
            .compactMap { notification -> CGFloat? in
                if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    if frame.origin.y >= UIScreen.main.bounds.height {
                        return 0
                    } else {
                        return frame.height
                    }
                }
                return nil
            }
            .assign(to: \.keyboardHeight, on: self)
    }
}

