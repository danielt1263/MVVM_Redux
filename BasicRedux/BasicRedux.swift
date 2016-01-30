//
//  ReduxBase.swift
//  MVVM Redux
//
//  Created by Daniel Tartaglia on 1/16/16.
//  Copyright © 2016 Daniel Tartaglia. All rights reserved.
//

import Swift


public protocol StateObserver: class {

	func updateWithState(state: State)

	typealias State

}


public class Store<State, Action> {
	
	public typealias Reducer = (state: State, action: Action) -> State
	public typealias Unsubscriber = () -> Void
	public typealias Dispatcher = (action: Action) -> Void
	public typealias Middleware = (next: Dispatcher, state: () -> State) -> Dispatcher
	
	public init(state: State, reducer: Reducer, middleware: [Middleware] = []) {
		self.state = state
		self.reducer = reducer
		dispatcher = middleware.reverse().reduce(self._dispatch) { dispatcher, middleware in
			middleware(next: dispatcher, state: { self.state })
		}
	}
	
	public func dispatch(action: Action) {
		dispatcher(action: action)
	}
	
	public func subscribe<SO: StateObserver where SO.State == State>(observer: SO) -> Unsubscriber {
		let id = uniqueId
		subscribers[id] = AnyStateObserver(observer: observer)
		let dispose = { [weak self] () -> Void in
			self?.subscribers.removeValueForKey(id)
		}
		observer.updateWithState(state)
		uniqueId += 1
		return dispose
	}
	
	private func _dispatch(action: Action) {
		guard !isDispatching else { fatalError("Cannot dispatch in the middle of a dispatch.") }
		isDispatching = true
		state = reducer(state: state, action: action)
		update()
		isDispatching = false
	}
	
	private func update() {
		for (_, subscriber) in subscribers {
			subscriber.updateWithState(state)
		}
	}

	private var state: State
	private var reducer: Reducer
	private var isDispatching = false
	private var uniqueId: Int = 0
	private var subscribers: [Int: AnyStateObserver<State>] = [:]
	private var dispatcher: Dispatcher = { _ in }
}

public func combineReducers<State, Action>(reducers: [Store<State, Action>.Reducer]) -> Store<State, Action>.Reducer {
	return { state, action in
		return reducers.reduce(state) { state, reducer in reducer(state: state, action: action) }
	}
}

public class AnyStateObserver<T>: StateObserver {
	
	public init<SO: StateObserver where SO.State == T>(observer: SO) {
		self.observer = observer.updateWithState
	}
	
	public func updateWithState(state: T) {
		observer(state: state)
	}
	
	private let observer: (state: T) -> Void
}
