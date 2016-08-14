//
//  LSYChatDemoViewController.swift
//  LSY_Chat
//
//  Created by 李世洋 on 16/8/12.
//  Copyright © 2016年 李世洋. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class LSYChatDemoViewController: FTChatMessageTableViewController {
   
   
    var messageManger: ReceiveMessage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /**
         *  登录
         */
        LoginClient().autoLogin("lsy545464", userPassword: "545464") {
        
            /**
             *  接收消息
             */
            self.messageManger = ReceiveMessage()
            self.messageManger?.delegate = self
            
        }
        
    }
 
    
    override func setupMessageModel() -> [FTChatMessageModel] {
        return [FTChatMessageModel]()
        
    }
    
    
    
}

// MARK: - ReceiveMessageDelegate
extension LSYChatDemoViewController: ReceiveMessageDelegate
{
    func receiveMessage(messageModel: FTChatMessageModel) {
        
        print(#function)
        addNewIncomingMessage(messageModel)
    }
}


