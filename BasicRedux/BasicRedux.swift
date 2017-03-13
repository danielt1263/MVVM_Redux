//
//  Redux.swift
//
//  Created by Daniel Tartaglia on 01/16/15.
//  Copyright © 2016. MIT License.
//


public protocol Dispatcher {
	associatedtype State
	typealias Action = (_ state: inout State) -> Void
	func dispatch(_ action: Action)
}

public final
class Store<State>: Dispatcher {
	
	public typealias Action = (_ state: inout State) -> Void
	public typealias Observer = (_ state: State) -> Void
	public typealias Dispatcher = (_ action: Action) -> Void
	public typealias Middleware = (_ next: @escaping Dispatcher, _ state: @escaping () -> State) -> Dispatcher
	
	public init(state: State, middleware: [Middleware] = []) {
		currentState = state
		dispatcher = middleware.reversed().reduce(self._dispatch) { (dispatcher: @escaping Dispatcher, middleware: Middleware) -> Dispatcher in
			middleware(dispatcher, { self.currentState })
		}
	}
	
	public func dispatch(_ action: Action) {
		guard !isDispatching else { fatalError("Cannot dispatch in the middle of a dispatch") }
		isDispatching = true
		self.dispatcher(action)
		isDispatching = false
	}
	
	public func subscribe(_ observer: @escaping Observer) -> Unsubscriber {
		let id = uniqueId
		uniqueId += 1
		subscribers[id] = observer
		let dispose = { [weak self] () -> Void in
			_ = self?.subscribers.removeValue(forKey: id)
		}
		observer(currentState)
		return Unsubscriber(method: dispose)
	}
	
	private func _dispatch(_ action: Action) {
		action(&currentState)
		for subscriber in subscribers.values {
			subscriber(currentState)
		}
	}
	
	private var isDispatching = false
	private var currentState: State
	private var uniqueId = 0
	private var subscribers: [Int: Observer] = [:]
	private var dispatcher: Dispatcher = { _ in }
}

public final
class Unsubscriber {
	private var method: (() -> Void)?

	init(method: @escaping () -> Void) {
		self.method = method
	}

	deinit {
		unsubscribe()
	}

	func unsubscribe() {
		if let method = method {
			method()
		}
		method = nil
	}
}
