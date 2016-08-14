//
//  FTChatMessageBubbleImageItem.swift
//  ChatMessageDemoProject
//
//  Created by liufengting on 16/5/7.
//  Copyright © 2016年 liufengting. All rights reserved.
//

import UIKit

class FTChatMessageBubbleImageItem: FTChatMessageBubbleItem {
    
    convenience init(frame: CGRect, aMessage : FTChatMessageModel ) {
        self.init(frame:frame)
        self.backgroundColor = UIColor.clearColor()
        message = aMessage
        messageBubblePath = self.getBubbleShapePathWithSize(frame.size, isUserSelf: aMessage.isUserSelf)
        
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = messageBubblePath.CGPath
        maskLayer.frame = self.bounds
        maskLayer.contentsScale = UIScreen.mainScreen().scale;
        
        let layer = CAShapeLayer()
        layer.mask = maskLayer
        layer.frame = self.bounds
        self.layer.addSublayer(layer)
        
        let image = aMessage.messageObject as! UIImage
        layer.contents = image.CGImage
    
    }
    
    
    
}
