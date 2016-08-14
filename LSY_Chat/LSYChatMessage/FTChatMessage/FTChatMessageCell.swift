//
//  FTChatMessageCell.swift
//  ChatMessageDemoProject
//
//  Created by liufengting on 16/2/28.
//  Copyright © 2016年 liufengting. All rights reserved.
//

import UIKit

class FTChatMessageCell: UITableViewCell {

    var message : FTChatMessageModel? {
        didSet{
            
            var timeLabelRect = CGRect.zero
            var nameLabelRect = CGRect.zero
            timeLabelRect = CGRectMake(0, -FTDefaultSectionHeight ,FTScreenWidth, FTDefaultTimeLabelHeight)
            nameLabelRect = CGRectMake(0, FTDefaultTimeLabelHeight - FTDefaultSectionHeight, FTScreenWidth, 0)
            var bubbleRect = CGRectZero
            
            messageTimeLabel.frame = timeLabelRect
            messageTimeLabel.text = "\(message!.messageTimeStamp)"
            
            var nameLabelTextAlignment : NSTextAlignment = .Left
            if message!.isUserSelf {
                nameLabelRect = CGRectMake( 0, (FTDefaultSectionHeight - FTDefaultNameLabelHeight)/2  - FTDefaultSectionHeight  , FTScreenWidth - (FTDefaultMargin + FTDefaultIconSize + FTDefaultAngleWidth), FTDefaultNameLabelHeight)
                nameLabelTextAlignment =  .Right
            }else{
                nameLabelRect = CGRectMake(FTDefaultMargin + FTDefaultIconSize + FTDefaultAngleWidth, (FTDefaultSectionHeight - FTDefaultNameLabelHeight)/2  - FTDefaultSectionHeight ,FTScreenWidth, FTDefaultNameLabelHeight)
                nameLabelTextAlignment = .Left
            }
            messageSenderLabel.frame = nameLabelRect
            messageSenderLabel.text = "\(message!.messageSender.senderName)"
            messageSenderLabel.textAlignment = nameLabelTextAlignment
            
            var bubbleWidth : CGFloat = 0
            var bubbleHeight : CGFloat = 0
            let y : CGFloat = nameLabelRect.origin.y + nameLabelRect.height + FTDefaultMargin
            switch message!.messageType {
            case .Text:
                
                let att = NSString(string: (message?.messageObject as? String)!)
                let rect = att.boundingRectWithSize(CGSizeMake(FTDefaultTextInViewMaxWidth,CGFloat(MAXFLOAT)), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName:FTDefaultFontSize,NSParagraphStyleAttributeName: FTChatMessagePublicMethods.getFTDefaultMessageParagraphStyle()], context: nil)
                bubbleWidth = rect.width + FTDefaultTextMargin*2 + FTDefaultAngleWidth
                bubbleHeight = rect.height + FTDefaultTextMargin*2
            case .Image:
                bubbleWidth = (message?.messageObject as! UIImage).size.width
                bubbleHeight = (message?.messageObject as! UIImage).size.height
            case .Audio:
                bubbleWidth = FTDefaultMessageBubbleWidth
                bubbleHeight = FTDefaultMessageBubbleAudioHeight
            case .Location:
                bubbleWidth = FTDefaultMapMessageBubbleWidth
                bubbleHeight = FTDefaultMapMessageBubbleHeight
            case .Video:
                bubbleWidth = FTDefaultMessageBubbleWidth
                bubbleHeight = FTDefaultMessageBubbleHeight
            }
            
            let x = message!.isUserSelf ? FTScreenWidth - (FTDefaultIconSize + FTDefaultMargin + FTDefaultIconToMessageMargin) - bubbleWidth : FTDefaultIconSize + FTDefaultMargin + FTDefaultIconToMessageMargin
            
            bubbleRect = CGRectMake(x, y, bubbleWidth, bubbleHeight)
            //        self.cellDesiredHeight = bubbleRect.origin.y + bubbleHeight + FTDefaultMargin*2
            
            
            self.setupCellBubbleItem(bubbleRect)
        }
    }
    
    var messageBubbleItem: FTChatMessageBubbleItem!
    var messageDeliverStatusView : FTChatMessageDeliverStatusView?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(messageTimeLabel)
        contentView.addSubview(messageSenderLabel)
        contentView.addSubview(messageLabel)
    }
    
    private lazy var messageTimeLabel: UILabel = {
       
        let tiLabel = UILabel()
        tiLabel.textAlignment = .Center
        tiLabel.textColor = UIColor.lightGrayColor()
        tiLabel.font = FTDefaultTimeLabelFont
        return tiLabel
    }()
    
    private lazy var messageSenderLabel: UILabel = {
    
        let seLabel = UILabel()
        seLabel.textColor = UIColor.lightGrayColor()
        seLabel.font = FTDefaultTimeLabelFont
        return seLabel
    }()
    
    private lazy var messageLabel: UILabel = {
        let meLabel = UILabel()
        meLabel.textColor = UIColor.lightGrayColor()
        meLabel.font = FTDefaultFontSize
        return meLabel
    }()
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupCellBubbleItem(bubbleFrame: CGRect) {
    
        switch message!.messageType {
        case .Text:
            messageBubbleItem = FTChatMessageBubbleTextItem(frame: bubbleFrame, aMessage: message!, messageLabel: messageLabel)
        
        case .Image:
            messageBubbleItem = FTChatMessageBubbleImageItem(frame: bubbleFrame, aMessage: message!)
        
        case .Audio:

            messageBubbleItem = FTChatMessageBubbleAudioItem(frame: bubbleFrame, aMessage: message!)

        case .Location:

            messageBubbleItem = FTChatMessageBubbleLocationItem(frame: bubbleFrame, aMessage: message!)

        case .Video:
        
            messageBubbleItem = FTChatMessageBubbleVideoItem(frame: bubbleFrame, aMessage: message!)

        }        
        
        if message!.isUserSelf  && message!.messageDeliverStatus != FTChatMessageDeliverStatus.Succeeded{
            if messageDeliverStatusView == nil {
                messageDeliverStatusView = FTChatMessageDeliverStatusView(frame: CGRectZero)
            }
            let statusViewRect = CGRectMake(bubbleFrame.origin.x - 20 - FTDefaultMargin, (bubbleFrame.origin.y + bubbleFrame.size.height - 20)/2, 20, 20)
            messageDeliverStatusView?.frame = statusViewRect
            messageDeliverStatusView?.setupWithDeliverStatus(message!.messageDeliverStatus)
            self.addSubview(messageDeliverStatusView!)
        }
        
        
        

        self.addSubview(messageBubbleItem)

    }
    

    class func getCellHeightWithMessage(theMessage : FTChatMessageModel, shouldShowSendTime : Bool , shouldShowSenderName : Bool) -> CGFloat{
        var cellDesiredHeight : CGFloat = 0;
        if shouldShowSendTime {
            cellDesiredHeight = FTDefaultTimeLabelHeight
        }
        if shouldShowSenderName {
            cellDesiredHeight = (FTDefaultSectionHeight - FTDefaultNameLabelHeight)/2 + FTDefaultNameLabelHeight
        }
        cellDesiredHeight += FTDefaultMargin
        switch theMessage.messageType {
        case .Text:
            let att = NSString(string: (theMessage.messageObject as? String)!)
            let textRect = att.boundingRectWithSize(CGSizeMake(FTDefaultTextInViewMaxWidth,CGFloat(MAXFLOAT)), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName:FTDefaultFontSize,NSParagraphStyleAttributeName: FTChatMessagePublicMethods.getFTDefaultMessageParagraphStyle()], context: nil)
            cellDesiredHeight += textRect.height + FTDefaultTextMargin*2
        case .Image:
            cellDesiredHeight += FTDefaultMessageBubbleHeight
        case .Audio:
            cellDesiredHeight += FTDefaultMessageBubbleAudioHeight
        case .Location:
            cellDesiredHeight += FTDefaultMapMessageBubbleHeight
        case .Video:
            cellDesiredHeight += FTDefaultMessageBubbleHeight
        }
        cellDesiredHeight += FTDefaultMargin*2 - FTDefaultSectionHeight

        return cellDesiredHeight
    }
    
    
    
    
}
class FTChatMessageDeliverStatusView: UIView {
    
    var activityIndicator : UIActivityIndicatorView?
    var failedImageView : UIImageView?
    
    func setupWithDeliverStatus(status : FTChatMessageDeliverStatus) {
        
        self.backgroundColor = UIColor.clearColor()
        
        switch status {
        case .Sending:
            activityIndicator = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
            activityIndicator?.frame = self.bounds
            activityIndicator?.startAnimating()
            self.addSubview(activityIndicator!)
            failedImageView?.hidden = true
        case .Succeeded:
            activityIndicator?.stopAnimating()
            activityIndicator?.hidden = true
            failedImageView?.hidden = true
        case .failed:
            activityIndicator?.stopAnimating()
            activityIndicator?.hidden = true
            failedImageView = UIImageView.init(frame: CGRectMake(0, 0, 20, 20))
            failedImageView?.backgroundColor = UIColor.clearColor();
            failedImageView?.image = UIImage(named: "FT_Add")
            failedImageView?.hidden = false
            self.addSubview(failedImageView!)
        }
        
    }
    
    
}



