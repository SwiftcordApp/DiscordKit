//
//  EventDispatcher.swift
//  
//
//  Created by Vincent Kwok on 24/11/22.
//  Credits: Helloyunho for original iteration
//

import Foundation

final public class EventDispatcher<Data> {
    private let notificationCenter = NotificationCenter()

    func emit<Data>(_ eventName: NSNotification.Name, value: Data) {
        notificationCenter.post(name: eventName, object: value)
    }

    func on<Data>(_ eventName: NSNotification.Name, listener: @escaping (Data) -> ()) {
        notificationCenter.addObserver(forName: eventName, object: nil, queue: nil) { n in
            guard let obj = n.object as? Data else { return }
            listener(obj)
        }
    }
}
