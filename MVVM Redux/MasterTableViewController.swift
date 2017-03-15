//
//  MasterTableViewController.swift
//  MVVM Redux
//
//  Created by Daniel Tartaglia on 1/15/16.
//  Copyright © 2016 Daniel Tartaglia. All rights reserved.
//

import UIKit
import BasicRedux


class MasterTableViewController: UITableViewController {
	
	@IBOutlet weak var addBarButtonItem: UIBarButtonItem!

	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.rightBarButtonItem = editButtonItem
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		unsubscriber = mainStore.subscribe(observer: { [weak self] in self?.handle(newItems: $0.paybackCollection.paybacks) })
	}
	
	// MARK: - Table view data source
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return items.count
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

		let item = items[indexPath.row]
		cell.textLabel?.text = item.firstName + " " + String(item.lastName.characters.first!) + "."
		cell.detailTextLabel?.text = "$" + String(item.amount)

		return cell
	}

	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			mainStore.dispatch(action: .deletePayback(index: indexPath.row))
		}
	}

	@IBAction func addAction(_ sender: AnyObject) {
		mainStore.dispatch(action: .presentAddPaybackScreen)
	}
	
	func handle(newItems: [Payback]) {
		var arrayCompare = ArrayCompare<Payback>()
		arrayCompare.old = items
		arrayCompare.new = newItems
		arrayCompare.insertBlock = { _, at in
			self.tableView.insertRows(at: [IndexPath(row: at, section: 0)], with: .bottom)
		}
		arrayCompare.removeBlock = { _, from in
			self.tableView.deleteRows(at: [IndexPath(row: from, section: 0)], with: .automatic)
		}
		arrayCompare.moveBlock = { _, from, to in
			self.tableView.moveRow(at: IndexPath(row: from, section: 0), to: IndexPath(row: to, section: 0))
		}
		tableView.beginUpdates()
		arrayCompare.run()
		items = newItems
		tableView.endUpdates()
	}

	private var unsubscriber: Unsubscriber?
	private var items: [Payback] = []

}

//Snagged from http://www.swift-studies.com/blog/2015/5/15/swift-coding-challenge-incremental-updates-to-views

struct ArrayCompare<T: Hashable> {

	var old: [T] = []
	var new: [T] = []

	var insertBlock: (_ insert: T, _ at: Int) -> Void = { _, _ in }
	var removeBlock: (_ remove: T, _ from: Int) -> Void = { _, _ in }
	var moveBlock: (_ move: T, _ from: Int, _ to: Int) -> Void = { _, _, _ in }

	func run() {
		var newPositions: [T: Int] = [:]
		for (index, obj) in new.enumerated() {
			newPositions[obj] = index
		}

		for (index, obj) in old.enumerated() {
			if let newPosition = newPositions[obj] {
				if index != newPosition {
					moveBlock(obj, index, newPosition)
				}
				newPositions.removeValue(forKey: obj)
			}
			else {
				removeBlock(obj, index)
			}
		}

		for (obj, position) in newPositions {
			insertBlock(obj, position)
		}
	}
}
