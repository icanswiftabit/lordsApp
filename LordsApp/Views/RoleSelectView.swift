//
//  RoleSelectView.swift
//  LordsApp
//
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import PureLayout

final class RoleSelectView: UIView {
    
    let connectedDevicesLabel = UILabel()
    let displayNameLabel = UILabel()
    let pmRoleButton = UIButton(type: .system)
    let devRoleButton = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        layout()
        decorate()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension RoleSelectView {
    func decorate() {
        backgroundColor = .white
        
        [displayNameLabel, connectedDevicesLabel].forEach {
            $0.textAlignment = .center
            $0.numberOfLines = 0
            $0.lineBreakMode = .byWordWrapping
        }
        pmRoleButton.setTitle("PM", for: .normal)
        devRoleButton.setTitle("DEV", for: .normal)
        
    }
    
    func layout() {
        
        addSubview(connectedDevicesLabel)
        addSubview(displayNameLabel)
        addSubview(pmRoleButton)
        addSubview(devRoleButton)

        connectedDevicesLabel.autoPinEdge(.top, to: .bottom, of: displayNameLabel)
        connectedDevicesLabel.autoPinEdge(toSuperviewEdge: .leading)
        connectedDevicesLabel.autoPinEdge(toSuperviewEdge: .trailing)
        connectedDevicesLabel.autoSetDimension(.height, toSize: 40)

        displayNameLabel.autoAlignAxis(.vertical, toSameAxisOf: self)
        displayNameLabel.autoPinEdge(toSuperviewEdge: .top, withInset: 66)
        
        [pmRoleButton, devRoleButton].forEach {
            $0.autoSetDimensions(to: CGSize(width: 60, height: 60))
            $0.autoAlignAxis(.horizontal, toSameAxisOf: self)
        }
        
        pmRoleButton.autoAlignAxis(.vertical, toSameAxisOf: self, withOffset: 80)
        devRoleButton.autoAlignAxis(.vertical, toSameAxisOf: self, withOffset: -80)
    }
}
