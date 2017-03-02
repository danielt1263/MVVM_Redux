//
//  Redux.swift
//
//  Created by Daniel Tartaglia on 01/16/15.
//  Copyright © 2016. MIT License.
//


open class Store<State> {
	
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
	
	open func dispatch(_ action: Action) {
		guard !isDispatching else { fatalError("Cannot dispatch in the middle of a dispatch") }
		isDispatching = true
		self.dispatcher(action)
		isDispatching = false
	}
	
	open func subscribe(_ observer: @escaping Observer) -> Unsubscriber {
		let id = uniqueId
		uniqueId += 1
		subscribers[id] = observer
		let dispose = { [weak self] () -> Void in
			_ = self?.subscribers.removeValue(forKey: id)
		}
		observer(currentState)
		return Unsubscriber(method: dispose)
	}
	
	fileprivate func _dispatch(_ action: Action) {
		action(&currentState)
		for subscriber in subscribers.values {
			subscriber(currentState)
		}
	}
	
	fileprivate var isDispatching = false
	fileprivate var currentState: State
	fileprivate var uniqueId = 0
	fileprivate var subscribers: [Int: Observer] = [:]
	fileprivate var dispatcher: Dispatcher = { _ in }
}

open class Unsubscriber {
	fileprivate var method: (() -> Void)?

	init(method: @escaping () -> Void) {
		self.method = method
	}

	deinit {
		unsubscribe()
	}

	open func unsubscribe() {
		if let method = method {
			method()
		}
		method = nil
	}
}
