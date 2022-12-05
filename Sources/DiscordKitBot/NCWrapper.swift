//
//  NCWrapper.swift
//  
//
//  Created by Vincent Kwok on 24/11/22.
//  Credits: Helloyunho for original iteration
//

import Foundation

public struct NCWrapper<Data> {
    private let notificationCenter: NotificationCenter

    private let name: NSNotification.Name

    init(_ name: NSNotification.Name, notificationCenter: NotificationCenter = .default) {
        self.name = name
        self.notificationCenter = notificationCenter
    }

    func emit(value: Data) {
        notificationCenter.post(name: name, object: value)
    }

    public func listen(listener: @escaping (Data) -> ()) {
        notificationCenter.addObserver(forName: name, object: nil, queue: nil) { n in
            guard let obj = n.object as? Data else { return }
            listener(obj)
        }
    }

    public func listen(listener: @escaping (Data) async -> ()) {
        listen { data in Task { await listener(data) } }
    }
}

// Wrapper functions if the data is of type void
extension NCWrapper where Data == () {
    func emit() {
        emit(value: ())
    }

    public func listen(listener: @escaping () -> ()) {
        listen { _ in listener() }
    }
    public func listen(listener: @escaping () async -> ()) {
        listen { _ in await listener() }
    }
}
