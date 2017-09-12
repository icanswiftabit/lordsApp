//
//  RoleSelectViewModel.swift
//  LordsApp
//
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import RxSwift

struct RoleSelectViewModel {
    var peerNames = Variable<[String]>([String]())
    var displayName = Variable<String>("")
}
