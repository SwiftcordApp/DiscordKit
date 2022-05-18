/// EventDispatch.swift


import Foundation

/// Adapted from: https://github.com/gongzhang/swift-event-dispatch
///
/// Unfortunately the code isn't exactly fully compatible with Swift 5
/// Changes were made to improve style and to remove all warnings/errors
/// Adds optimisations to reduce
public class EventDispatch<Event>: EventDispatchProtocol {
    public typealias HandlerIdentifier = Int
    
    private typealias Handler = (Event) -> ()
    private var handlerIds = [HandlerIdentifier]()
    private var handlers = [Handler]()
    private var lastId: HandlerIdentifier = 0
    
    private let evtQueue: DispatchQueue
    
    public init() {
        evtQueue = DispatchQueue(label: UUID().uuidString, qos: .userInteractive, attributes: .concurrent, target: .main)
    }
    
    /// Register a handler closure to be called when the event is notified
    ///
    /// - Parameters:
    ///   - handler: A closure that is called with the event when this `EventDispatch`
    ///   is notified
    ///
    /// - Returns: A `HandlerIdentifier` that can be passed to `removeHandler()`
    /// to remove this handler
    public func addHandler(handler: @escaping (Event) -> ()) -> HandlerIdentifier {
        lastId += 1
        handlerIds.append(lastId)
        handlers.append(handler)
        return lastId
    }
    
    /// Similar to addHandler(), but removes the handler after it's notified
    ///
    /// - Parameters:
    ///   - handler: A closure that is called with the event when this `EventDispatch`
    ///   is notified. This closure will only be called _once_
    public func handleOnce(handler: @escaping (Event) -> ()) {
        var id: HandlerIdentifier!
        id = addHandler { [weak self] event in
            handler(event)
            _ = self?.removeHandler(handler: id)
        }
    }
    
    /// Removes a handler with a given identifier
    ///
    /// - Parameters:
    ///   - handler: THe identifier of the handler, returned from `addHandler()`
    ///
    /// - Returns: `True` if the handler exists and was removed
    public func removeHandler(handler: HandlerIdentifier) -> Bool {
        if let index = handlerIds.firstIndex(of: handler) {
            handlerIds.remove(at: index)
            let _ = handlers.remove(at: index)
            return true
        } else {
            return false
        }
    }
    
    /// Notify all handlers of this `EventDispatch` with event data
    ///
    /// This method will immediately notify all registered handlers
    /// asynchronously with the event data it is called with.
    ///
    /// - Parameters:
    ///   - event: The event data to notify handlers with
    public func notify(event: Event) {
        let copiedHandlers = handlers
        for handler in copiedHandlers {
            evtQueue.async { handler(event) }
        }
    }
}

public protocol EventDispatchProtocol {
    associatedtype EventType
    func notify(event: EventType)
}

public extension EventDispatchProtocol where EventType: Equatable {
    /// Notify all handlers of this `EventDispatch` with event data,
    /// only if the 2 event data passed to this method are different
    ///
    /// - Parameters:
    ///   - old: The old event data
    ///   - new: The new event data, handlers will be notified with
    ///   this if `new != old`
    func notifyIfChanged(old: EventType, new: EventType) {
        if old != new {
            notify(event: new)
        }
    }
}

public extension EventDispatchProtocol where EventType == Void {
    func notify() {
        notify(event: ())
    }
}
