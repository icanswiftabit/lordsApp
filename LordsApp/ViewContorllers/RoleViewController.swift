//
//  RoleViewController.swift
//  LordsApp
//
//  Copyright © 2017 Netguru Sp. z o.o. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import RxSwift
import RxCocoa

enum ParsingError: Error {
    case emptyArray
}


final class RoleViewController: UIViewController {

    var provider: FibonacciServiceProvider!
    let roleSelectView = RoleSelectView()
    let viewModel = RoleSelectViewModel()
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBindings()
    }

    override func loadView() {
        view = roleSelectView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupName()
    }

}

fileprivate extension RoleViewController {
    func setupBindings() {
        viewModel.peerNames.asObservable()
            .flatMap { peersNames -> Observable<String> in
                guard peersNames.count > 0 else {
                    return Observable.just("Searching...")
                }
                var textForLabel = "Connected with: "
                for name in peersNames {
                    textForLabel.append("\(name), ")
                }
                let range = textForLabel.index(textForLabel.endIndex, offsetBy: -2)..<textForLabel.endIndex
                textForLabel.removeSubrange(range)
                return Observable.just(textForLabel)
            }
            .bind(to: roleSelectView.connectedDevicesLabel.rx.text)
            .addDisposableTo(bag)
        
        viewModel.displayName.asObservable()
            .bind(to: roleSelectView.displayNameLabel.rx.text)
            .addDisposableTo(bag)
        
        viewModel.peerNames.asObservable()
            .flatMap { peersNames -> Observable<Bool> in
                return Observable.just(peersNames.count > 0)
            }
            .bind(onNext: { [weak self] enabled in
                self?.roleSelectView.pmRoleButton.isEnabled = enabled
                self?.roleSelectView.devRoleButton.isEnabled = enabled
            })
            .addDisposableTo(bag)
        
        roleSelectView.devRoleButton.rx.tap.debug("devButtonTap").bind(onNext: { [weak self] in
            self?.send(.dev)
        })
        .addDisposableTo(bag)
        
        roleSelectView.pmRoleButton.rx.tap.debug("pmButtonTap").bind(onNext: { [weak self] in
            self?.send(.pm)
        })
        .addDisposableTo(bag)
    }
    
    func setupName() {
        var inputTextField: UITextField?
        let alert = UIAlertController(title: "Display name", message: "What's your name?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { action in
            guard let displayName = inputTextField?.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines),
                  !displayName.isEmpty else {
                self.setupName()
                return
            }
            
            self.viewModel.displayName.value = displayName
            self.provider = FibonacciServiceProvider(with: self.viewModel.displayName.value)
            self.provider.delegate = self
        }))
        
        alert.addTextField(configurationHandler: { (textField) in
            inputTextField = textField
        })
        
        present(alert, animated: true)
    }
}

fileprivate extension RoleViewController {
    func send(_ role: Role) {
        do {
            try provider.send(role)
        } catch let error {
            switch error {
            case FibonacciServiceError.pmAlreadyInSession(let message):
                show(error, with: message)
            case FibonacciServiceError.noParticipants(let message):
                show(error, with: message)
            default:
                show(error)
            }
        }
    }
    
    func show(_ error: Error, with message: String? = nil) {
        let alert = UIAlertController(title: "Error", message: message ?? error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true)
    }
}

extension RoleViewController: FibonacciServiceProviderDelegate {
    func provider(_ provider: FibonacciServiceProvider, participantsHaveChanged participants: [Participant]) {
        DispatchQueue.main.async {
            self.viewModel.peerNames.value = participants.map { "\($0.peerID.displayName) [\($0.role != nil ? $0.role!.rawValue : "")]" }
        }
    }
}
