//
//  RefreshAltStoreViewController.swift
//  AltStore
//
//  Created by Riley Testut on 10/26/19.
//  Copyright © 2019 Riley Testut. All rights reserved.
//

import UIKit

import AltStoreCore
import AltSign
import Roxas

class RefreshAltStoreViewController: UIViewController
{
    var context: AuthenticatedOperationContext!
    
    var completionHandler: ((Result<Void, Error>) -> Void)?
    
    @IBOutlet private var placeholderView: RSTPlaceholderView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.placeholderView.textLabel.isHidden = true
        
        self.placeholderView.detailTextLabel.textAlignment = .left
        self.placeholderView.detailTextLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        self.placeholderView.detailTextLabel.text = NSLocalizedString("AltStore无法使用现有的签名证书，因此必须创建一个新的证书。这将导致任何使用现有证书安装的应用程序过期，包括AltStore。\n\n为防止AltStore提前过期，请立即刷新应用程序。刷新完成后，AltStore将退出。", comment: "")
    }
}

private extension RefreshAltStoreViewController
{
    @IBAction func refreshAltStore(_ sender: PillButton)
    {
        guard let altStore = InstalledApp.fetchAltStore(in: DatabaseManager.shared.viewContext) else { return }
                
        func refresh()
        {
            sender.isIndicatingActivity = true
            
            if let progress = AppManager.shared.installationProgress(for: altStore)
            {
                // Cancel pending AltStore installation so we can start a new one.
                progress.cancel()
            }
                        
            // Install, _not_ refresh, to ensure we are installing with a non-revoked certificate.
            let group = AppManager.shared.install(altStore, presentingViewController: self, context: self.context) { (result) in
                switch result
                {
                case .success: self.completionHandler?(.success(()))
                case .failure(let error as NSError):
                    DispatchQueue.main.async {
                        sender.progress = nil
                        sender.isIndicatingActivity = false
                        
                        let alertController = UIAlertController(title: NSLocalizedString("无法刷新 AltStore", comment: ""), message: error.localizedFailureReason ?? error.localizedDescription, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: NSLocalizedString("重试", comment: ""), style: .default, handler: { (action) in
                            refresh()
                        }))
                        alertController.addAction(UIAlertAction(title: NSLocalizedString("稍后刷新", comment: ""), style: .cancel, handler: { (action) in
                            self.completionHandler?(.failure(error))
                        }))
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
            
            sender.progress = group.progress
        }
        
        refresh()
    }
    
    @IBAction func cancel(_ sender: UIButton)
    {
        self.completionHandler?(.failure(OperationError.cancelled))
    }
}
