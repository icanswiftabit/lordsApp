//
//  FibonacciServiceProviderDelegate.swift
//  LordsApp
//
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//

import UIKit

protocol FibonacciServiceProviderDelegate: class {
    func provider(_ provider: FibonacciServiceProvider, participantsHaveChanged participants: [Participant])
}
