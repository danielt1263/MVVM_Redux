//
//  NavigationController.swift
//  MVVM Redux
//
//  Created by Daniel Tartaglia on 1/21/16.
//  Copyright © 2016 Daniel Tartaglia. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		unsubscribe = mainStore.subscribe { [unowned self] state in
			let navState = state.navigationState
			let currentStackCount = self.childViewControllers.count
			if currentStackCount > navState.viewControllerStack.count {
				for _ in 0..<(currentStackCount - navState.viewControllerStack.count) {
					self.popViewControllerAnimated(true)
				}
			}
			else if currentStackCount < navState.viewControllerStack.count {
				for vc in navState.viewControllerStack[currentStackCount ..< navState.viewControllerStack.count] {
					let controller = self.storyboard!.instantiateViewControllerWithIdentifier(vc.rawValue)
					self.pushViewController(controller, animated: true)
				}
			}
			else if navState.viewControllerStack.last?.rawValue != self.childViewControllers.last?.restorationIdentifier {
				fatalError("NOT HANDLED: Attempted to go back and forward down different path")
			}
			
			if let alert = state.navigationState.shouldDisplayAlert {
				if let presentedAlert = self.presentedViewController as? UIAlertController {
					if alert.message != presentedAlert.message {
						fatalError("NOT HANDLED: Attempted to present alert on an alert")
					}
				}
				else {
					self.displayErrorAlert(alert.message)
				}
			}
			else {
				if self.presentedViewController is UIAlertController {
					self.dismissViewControllerAnimated(true, completion: nil)
				}
			}
		}
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
