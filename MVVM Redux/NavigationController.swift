//
//  NavigationController.swift
//  MVVM Redux
//
//  Created by Daniel Tartaglia on 1/21/16.
//  Copyright © 2016 Daniel Tartaglia. All rights reserved.
//

import UIKit
import BasicRedux


class NavigationController: UINavigationController {
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		unsubscribe = mainStore.subscribe(self)
	}
	
	private func displayErrorAlert(message: String) {
		let alert = UIAlertController(title: "Error", message: message, preferredStyle: .Alert)
		alert.addAction(UIAlertAction(title: "OK", style: .Cancel) { _ in
			mainStore.dispatch(NavigationAction.AlertDismissed)
			})
		presentViewController(alert, animated: true, completion: nil)
	}
	
	private var unsubscribe: () -> Void = { }
}

extension NavigationController: StateObserver {
	
	func updateWithState(state: State) {
		let navState = state.navigationState
		let currentStackCount = childViewControllers.count
		if currentStackCount > navState.viewControllerStack.count {
			for _ in 0..<(currentStackCount - navState.viewControllerStack.count) {
				popViewControllerAnimated(true)
			}
		}
		else if currentStackCount < navState.viewControllerStack.count {
			for vc in navState.viewControllerStack[currentStackCount ..< navState.viewControllerStack.count] {
				let controller = storyboard!.instantiateViewControllerWithIdentifier(vc.rawValue)
				pushViewController(controller, animated: true)
			}
		}
		else if navState.viewControllerStack.last?.rawValue != childViewControllers.last?.restorationIdentifier {
			fatalError("NOT HANDLED: Attempted to go back and forward down different path")
		}
		
		if let alert = state.navigationState.shouldDisplayAlert {
			if let presentedAlert = presentedViewController as? UIAlertController {
				if alert.message != presentedAlert.message {
					fatalError("NOT HANDLED: Attempted to present alert on an alert")
				}
			}
			else {
				displayErrorAlert(alert.message)
			}
		}
		else {
			if presentedViewController is UIAlertController {
				dismissViewControllerAnimated(true, completion: nil)
			}
		}
	}
	
}