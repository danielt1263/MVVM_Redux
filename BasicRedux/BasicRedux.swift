//
//  Redux.swift
//
//  Created by Daniel Tartaglia on 01/16/15.
//  Copyright © 2016. MIT License.
//


public class Store<State> {
	
	public typealias Action = (inout state: State) -> Void
	public typealias Observer = (state: State) -> Void
	public typealias Dispatcher = (action: Action) -> Void
	public typealias Middleware = (next: Dispatcher, state: () -> State) -> Dispatcher
	
	public init(state: State, middleware: [Middleware] = []) {
		currentState = state
		dispatcher = middleware.reverse().reduce(self._dispatch) { (dispatcher: Dispatcher, middleware: Middleware) -> Dispatcher in
			middleware(next: dispatcher, state: { self.currentState })
		}
	}
	
	public func dispatch(action: Action) {
		guard !isDispatching else { fatalError("Cannot dispatch in the middle of a dispatch") }
		isDispatching = true
		self.dispatcher(action: action)
		isDispatching = false
	}
	
	public func subscribe(observer: Observer) -> Unsubscriber {
		let id = uniqueId
		uniqueId += 1
		subscribers[id] = observer
		let dispose = { [weak self] () -> Void in
			self?.subscribers.removeValueForKey(id)
		}
		observer(state: currentState)
		return Unsubscriber(method: dispose)
	}
	
	private func _dispatch(action: Action) {
		action(state: &currentState)
		for subscriber in subscribers.values {
			subscriber(state: currentState)
		}
	}
	
	private var isDispatching = false
	private var currentState: State
	private var uniqueId = 0
	private var subscribers: [Int: Observer] = [:]
	private var dispatcher: Dispatcher = { _ in }
}

public class Unsubscriber {
	private var method: (() -> Void)?

	init(method: () -> Void) {
		self.method = method
	}

	deinit {
		unsubscribe()
	}

	public func unsubscribe() {
		if let method = method {
			method()
		}
		method = nil
	}
}
