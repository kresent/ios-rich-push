//
//  NotificationService.swift
//  kosmos-pix
//
//  Created by dmitriy on 05/09/2019.
//  Copyright © 2019 Facebook. All rights reserved.
//

import UserNotifications
import MobileCoreServices

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
          if let attachmentString = bestAttemptContent.userInfo["attachment-url"] as? String,
            let attachmentUrl = URL(string: attachmentString) {
              let session = URLSession(configuration: URLSessionConfiguration.default)
              let downloadTask = session.downloadTask(with: attachmentUrl, completionHandler: {(url, _, error) in if let error = error {
                print ("Error handling push content: \(error.localizedDescription)")
              } else if let url = url {
                let attachment = try! UNNotificationAttachment(identifier: attachmentString, url: url, options: [UNNotificationAttachmentOptionsTypeHintKey: kUTTypePNG])
                
                bestAttemptContent.attachments = [attachment]
                }
                contentHandler(bestAttemptContent)
              })
              downloadTask.resume()
          }
          
          
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
