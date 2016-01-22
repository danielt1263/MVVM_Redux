//
//  Payback.swift
//  MVVM Redux
//
//  Created by Daniel Tartaglia on 1/15/16.
//  Copyright © 2016 Daniel Tartaglia. All rights reserved.
//

import Foundation


struct Payback: Hashable {

	let id: Int
	let firstName: String
	let lastName: String
	let amount: Double

	init(firstName: String, lastName: String, amount: Double) {
		id = uniqueId++
		self.firstName = firstName
		self.lastName = lastName
		self.amount = amount
	}

	var hashValue: Int {
		return id.hashValue
	}
}

func ==(lhs: Payback, rhs: Payback) -> Bool {
	return lhs.id == rhs.id
}

private var uniqueId = 0