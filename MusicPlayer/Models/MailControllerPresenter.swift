//
//  MailControllerPresenter.swift
//  MusicPlayer
//
//  Created by Vladyslav Yakovlev on 25.07.2018.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import MessageUI

final class MailControllerPresenter: NSObject {
    
    func present(from сontroller: UIViewController) {
        let device = UIDevice.current.modelName
        let systemVersion = UIDevice.current.systemVersion
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")!
        let appName = AppInfo.appName
        
        let info = "\n\n---\nPlease don't remove the following technical info:\nApp version - \(appVersion)\nDevice - \(device)\niOS version - \(systemVersion)"
        
        if MFMailComposeViewController.canSendMail() {
            let mailController = MFMailComposeViewController()
            mailController.mailComposeDelegate = self
            mailController.setSubject(appName)
            mailController.setMessageBody(info, isHTML: false)
            mailController.setToRecipients(["yakovlevvl@icloud.com"])
            сontroller.present(mailController, animated: true)
        } else {
            let alertVC = UIAlertController(title: "Error", message: "Sorry, you need to setup mail first!", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .cancel))
            сontroller.present(alertVC, animated: true)
        }
    }
}

extension MailControllerPresenter: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
