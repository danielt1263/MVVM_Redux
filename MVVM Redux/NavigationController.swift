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

	override func loadView() {
		super.loadView()
		let undoButton = UIBarButtonItem(title: "Undo", style: .plain, target: self, action: #selector(undo))
		setToolbarItems([undoButton], animated: false)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		unsubscriber = mainStore.subscribe(observer: { [weak self] in self?.handle(state: $0.navigationState) })
	}
	
	func undo() {
		
	}
	
	func handle(state: NavigationState) {
		let currentStackCount = childViewControllers.count
		if currentStackCount > state.viewControllerStack.count {
			for _ in 0..<(currentStackCount - state.viewControllerStack.count) {
				popViewController(animated: true)
			}
		}
		else if currentStackCount < state.viewControllerStack.count {
			for vc in state.viewControllerStack[currentStackCount ..< state.viewControllerStack.count] {
				let controller = storyboard!.instantiateViewController(withIdentifier: vc.rawValue)
				pushViewController(controller, animated: true)
			}
		}
		else if state.viewControllerStack.last?.rawValue != childViewControllers.last?.restorationIdentifier {
			fatalError("NOT HANDLED: Attempted to go back and forward down different path")
		}
		
		if let alert = state.shouldDisplayAlert {
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
				dismiss(animated: true, completion: nil)
			}
		}
	}

	private var unsubscriber: Unsubscriber?

	private func displayErrorAlert(_ message: String) {
		let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .cancel) { _ in
			mainStore.dispatch(action: .exitedErrorAlert)
		})
		present(alert, animated: true, completion: nil)
	}
	
}


extension NavigationController: UIToolbarDelegate {
	
}
