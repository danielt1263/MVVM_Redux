//
//  Redux.swift
//
//  Created by Daniel Tartaglia on 01/16/15.
//  Copyright © 2017. MIT License.
//


public protocol Observer: class {
	associatedtype State
	func handle(state: State)
}

public final class Store<State, Action> {
	public typealias Reducer = (State, Action) -> State
	public typealias Dispatcher = (Action) -> Void
	public typealias Middleware = (@escaping Dispatcher, @escaping () -> State) -> Dispatcher
	
	public init(initial state: State, reducer: @escaping Reducer, middleware: [Middleware] = []) {
		self.state = state
		reduce = reducer
		dispatcher = middleware.reversed().reduce(self._dispatch) { dispatcher, middleware in
			middleware(dispatcher, { self.state })
		}
	}
	
	public func dispatch(action: Action) {
		guard !isDispatching else { fatalError("Cannot dispatch in the middle of a dispatch") }
		isDispatching = true
		self.dispatcher(action)
		isDispatching = false
	}
	
	public func subscribe<O: Observer>(observer: O) where O.State == State {
		subscribers.append(AnyObserver(observer))
		observer.handle(state: state)
	}
	
	public func unsubscribe<O: Observer>(observer: O) where O.State == State {
		while let index = subscribers.index(where: { $0 === observer }) {
			subscribers.remove(at: index)
		}
	}
	
	private func _dispatch(action: Action) {
		state = reduce(state, action)
		for subscriber in subscribers {
			subscriber.handle(state: state)
		}
	}
	
	private let reduce: Reducer
	private var state: State
	private var isDispatching = false
	private var subscribers: [AnyObserver<State>] = []
	private var dispatcher: Dispatcher = { _ in fatalError() }
}

private class AnyObserver<T>: Observer {
	typealias State = T
	init<O: Observer>(_ observer: O) where O.State == State {
		_handle = observer.handle
	}
	
	func handle(state: T) {
		_handle(state)
	}
	
	private let _handle: (State) -> Void
}
