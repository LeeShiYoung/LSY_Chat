//
//  FTChatMessageTableViewController.swift
//  ChatMessageDemoProject
//
//  Created by liufengting on 16/2/28.
//  Copyright © 2016年 liufengting. All rights reserved.
//

import UIKit


public class FTChatMessageTableViewController: UIViewController, UITableViewDelegate,UITableViewDataSource,FTChatMessageInputViewDelegate,FTChatMessageAccessoryViewDataSource,FTChatMessageAccessoryViewDelegate{
    
    var messageInputMode : FTChatMessageInputMode = FTChatMessageInputMode.None
    
    var messageArray = [FTChatMessageModel]()
    
    var shouldShowSendTime : Bool = true
    var shouldShowSenderName : Bool = true

    
    let sender1 = FTChatMessageSenderModel.init(id: "1", name: "SomeOne", icon_url: "http://ww3.sinaimg.cn/mw600/6cca1403jw1f3lrknzxczj20gj0g0t96.jpg", extra_data: nil, isSelf: false)
    let sender2 = FTChatMessageSenderModel.init(id: "2", name: "Liufengting", icon_url: "http://ww3.sinaimg.cn/mw600/9d319f9agw1f3k8e4pixfj20u00u0ac6.jpg", extra_data: nil, isSelf: true)

    
    override public func viewDidLoad() {
        super.viewDidLoad()
       
        configurationUI()
        
        messageTableView.registerClass(FTChatMessageCell.self, forCellReuseIdentifier: FTChatMessageCellReuseIndentifier)
  
        dispatch_after( dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
            
            if self.messageArray.count != 0 {
                self.messageTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: self.messageArray.count-1), atScrollPosition: UITableViewScrollPosition.Top, animated: false)
            }
        }
    }
    
    private func configurationUI() {
        self.navigationItem.setRightBarButtonItem(UIBarButtonItem.init(title: "A", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.addNewIncomingMessage)), animated: true)
        self.view.addSubview(messageTableView)
        self.view.addSubview(messageInputView)
        self.view.addSubview(messageRecordView)
        self.view.addSubview(messageAccessoryView)
    }

    func setupMessageModel() -> [FTChatMessageModel] {
        return [FTChatMessageModel]()
    }
    
    private lazy var messageTableView: UITableView  = {
        
        let table = UITableView(frame: CGRectMake(0, 0, FTScreenWidth, FTScreenHeight), style: .Plain)
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .None
        table.allowsSelection = false
        table.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag
        table.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, FTDefaultInputViewHeight, 0)
        let header = UIView(frame: CGRectMake( 0, 0, FTScreenWidth, FTDefaultMargin*2))
        table.tableHeaderView = header
        let footer = UIView(frame: CGRectMake( 0, 0, FTScreenWidth, FTDefaultInputViewHeight))
        table.tableFooterView = footer
        return table
    }()

    private lazy var messageInputView: FTChatMessageInputView = {
        
        let input = FTChatMessageInputView(frame: CGRectMake(0, FTScreenHeight-FTDefaultInputViewHeight, FTScreenWidth, FTDefaultInputViewHeight))
        input.inputDelegate = self
        return input
        
    }()
    
    private lazy var messageRecordView: FTChatMessageRecordView = {
       let recordView = FTChatMessageRecordView(frame: CGRectMake(0, FTScreenHeight, FTScreenWidth, FTDefaultRecordViewHeight))
        return recordView
    }()
    
    private lazy var  messageAccessoryView: FTChatMessageAccessoryView = {
        let accessoryView = FTChatMessageAccessoryView.init(frame: CGRectMake(0, FTScreenHeight, FTScreenWidth, FTDefaultRecordViewHeight), accessoryViewDataSource: self, accessoryViewDelegate: self)
        return accessoryView
    }()
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboradWillChangeFrame(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)

    }
    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillChangeFrameNotification, object: nil)
    
    }

    //MARK: - keyborad notification functions -

    func keyboradWillChangeFrame(notification : NSNotification) {
        
        if messageInputMode == FTChatMessageInputMode.Keyboard {
            if let userInfo = notification.userInfo {
                let duration = userInfo["UIKeyboardAnimationDurationUserInfoKey"]!.doubleValue
                let keyFrame = userInfo["UIKeyboardFrameEndUserInfoKey"]!.CGRectValue()
                let keyboradOriginY = min(keyFrame.origin.y, FTScreenHeight)
                let inputBarHeight = messageInputView.frame.height
                
                
                UIView.animateWithDuration(duration, animations: {
                    self.messageTableView.frame = CGRectMake(0 , 0 , FTScreenWidth, keyboradOriginY)
                    self.messageInputView.frame = CGRectMake(0, keyboradOriginY - inputBarHeight, FTScreenWidth, inputBarHeight)
                    self.scrollToBottom()
                    }, completion: { (finished) in
                        if finished {
                            if self.messageInputView.inputTextView.isFirstResponder() {
                                self.dismissInputRecordView()
                                self.dismissInputAccessoryView()
                            }
                        }
                })
            }
        }

    }

    //MARK: - FTChatMessageInputViewDelegate -

    func ftChatMessageInputViewShouldBeginEditing() {
        let originMode = messageInputMode
        messageInputMode = FTChatMessageInputMode.Keyboard;
        switch originMode {
        case .Keyboard: break
        case .Accessory:
            self.dismissInputAccessoryView()
        case .Record:
            self.dismissInputRecordView()
        case .None: break
        }
    }
    func ftChatMessageInputViewShouldEndEditing() {
        messageInputMode = FTChatMessageInputMode.None;
    }
    
    func ftChatMessageInputViewShouldUpdateHeight(desiredHeight: CGFloat) {
        var origin = messageInputView.frame;
        origin.origin.y = origin.origin.y + origin.size.height - desiredHeight;
        origin.size.height = desiredHeight;
        
        messageTableView.frame = CGRectMake(0, 0, FTScreenWidth, origin.origin.y + FTDefaultInputViewHeight)
        messageInputView.frame = origin
        self.scrollToBottom()
        messageInputView.updateSubViewFrame()
    }
    func ftChatMessageInputViewShouldDoneWithText(textString: String) {
        
        self.addNewMessage(textString)
        
    }
    func ftChatMessageInputViewShouldShowRecordView(){
        let originMode = messageInputMode
        let inputViewFrameHeight = self.messageInputView.frame.size.height
        if originMode == FTChatMessageInputMode.Record {
            messageInputMode = FTChatMessageInputMode.None
            
            UIView.animateWithDuration(FTDefaultMessageDefaultAnimationDuration, animations: {
                
                self.messageTableView.frame = CGRectMake(0, 0, FTScreenWidth, FTScreenHeight - inputViewFrameHeight + FTDefaultInputViewHeight )
                self.messageInputView.frame = CGRectMake(0, FTScreenHeight - inputViewFrameHeight, FTScreenWidth, inputViewFrameHeight)
                self.messageRecordView.frame = CGRectMake(0, FTScreenHeight, FTScreenWidth, FTDefaultRecordViewHeight)
                self.scrollToBottom()
                }, completion: { (finished) in
            })
        }else{
            switch originMode {
            case .Keyboard:
                self.messageInputView.inputTextView.resignFirstResponder()
            case .Accessory:
                self.dismissInputAccessoryView()
            case .None: break
            case .Record: break
            }
            messageInputMode = FTChatMessageInputMode.Record

            UIView.animateWithDuration(FTDefaultMessageDefaultAnimationDuration, animations: {
                self.messageTableView.frame = CGRectMake(0, 0, FTScreenWidth, FTScreenHeight - inputViewFrameHeight - FTDefaultRecordViewHeight + FTDefaultInputViewHeight )
                self.messageInputView.frame = CGRectMake(0, FTScreenHeight - inputViewFrameHeight - FTDefaultRecordViewHeight, FTScreenWidth, inputViewFrameHeight)
                self.messageRecordView.frame = CGRectMake(0, FTScreenHeight - FTDefaultRecordViewHeight, FTScreenWidth, FTDefaultRecordViewHeight)
                self.scrollToBottom()
                }, completion: { (finished) in

            })

        }
    }
    
    func ftChatMessageInputViewShouldShowAccessoryView(){
        let originMode = messageInputMode

        let inputViewFrameHeight = self.messageInputView.frame.size.height
        
        if originMode == FTChatMessageInputMode.Accessory {
            messageInputMode = FTChatMessageInputMode.None
            UIView.animateWithDuration(FTDefaultMessageDefaultAnimationDuration, animations: {
                
                self.messageTableView.frame = CGRectMake(0, 0, FTScreenWidth, FTScreenHeight - inputViewFrameHeight + FTDefaultInputViewHeight )
                self.messageInputView.frame = CGRectMake(0, FTScreenHeight - inputViewFrameHeight, FTScreenWidth, inputViewFrameHeight)
                self.messageAccessoryView.frame = CGRectMake(0, FTScreenHeight, FTScreenWidth, FTDefaultRecordViewHeight)
                self.scrollToBottom()
                }, completion: { (finished) in

            })
        }else{
            switch originMode {
            case .Keyboard:
                self.messageInputView.inputTextView.resignFirstResponder()
            case .Record:
                self.dismissInputRecordView()
            case .None: break
            case .Accessory: break
            }
            messageInputMode = FTChatMessageInputMode.Accessory

            UIView.animateWithDuration(FTDefaultMessageDefaultAnimationDuration, animations: {
                
                self.messageTableView.frame = CGRectMake(0, 0, FTScreenWidth, FTScreenHeight - inputViewFrameHeight - FTDefaultRecordViewHeight + FTDefaultInputViewHeight )
                
                self.messageInputView.frame = CGRectMake(0, FTScreenHeight - inputViewFrameHeight - FTDefaultRecordViewHeight, FTScreenWidth, inputViewFrameHeight)
                self.messageAccessoryView.frame = CGRectMake(0, FTScreenHeight - FTDefaultRecordViewHeight, FTScreenWidth, FTDefaultRecordViewHeight)
                self.scrollToBottom()
                }, completion: { (finished) in

            })
        }
    }

    //MARK: - dismissInputRecordView -

    func dismissInputRecordView(){
        UIView.animateWithDuration(FTDefaultMessageDefaultAnimationDuration, animations: {
            self.messageRecordView.frame = CGRectMake(0, FTScreenHeight, FTScreenWidth, FTDefaultRecordViewHeight)
            })
    }

    
    //MARK: - dismissInputAccessoryView -

    func dismissInputAccessoryView(){
        UIView.animateWithDuration(FTDefaultMessageDefaultAnimationDuration, animations: {
            self.messageAccessoryView.frame = CGRectMake(0, FTScreenHeight, FTScreenWidth, FTDefaultRecordViewHeight)
        })
    }
    
    
 
    
    //MARK: - addNewIncomingMessage -

    func addNewIncomingMessage(message: FTChatMessageModel) {
        
        messageArray.append(message)
        
        messageTableView.insertSections(NSIndexSet.init(indexesInRange: NSMakeRange(messageArray.count-1, 1)), withRowAnimation: UITableViewRowAnimation.Bottom)
        
        self.scrollToBottom()
        
    }
    
    
    func addNewMessage(text:String) {
        
        let message8 = FTChatMessageModel(data: text, time: "4.12 22:43", from: sender2, type: .Text)
        message8.messageDeliverStatus = FTChatMessageDeliverStatus.Sending
        messageArray.append(message8)
        
        messageTableView.insertSections(NSIndexSet.init(indexesInRange: NSMakeRange(messageArray.count-1, 1)), withRowAnimation: UITableViewRowAnimation.Bottom)
        
        self.scrollToBottom()
        

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {

            
            message8.messageDeliverStatus = FTChatMessageDeliverStatus.Succeeded
            
            self.messageTableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: (self.messageArray.indexOf(message8))!)], withRowAnimation: UITableViewRowAnimation.None)
            
            
        })

        
    }
    
    //MARK: - scrollToBottom -

    func scrollToBottom() {
        if messageArray.count != 0 {
            
             self.messageTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: messageArray.count-1), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        }
       
    }

    //MARK: - UITableViewDelegate,UITableViewDataSource -
    
    public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        switch self.messageInputMode {
        case .Accessory:
            self.ftChatMessageInputViewShouldShowAccessoryView()
        case .Record:
            self.ftChatMessageInputViewShouldShowRecordView()
        default:
            break;
        }
    }

    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return messageArray.count ?? 0;
    }
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1;
    }
    public func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let message = messageArray[section]
        let header = FTChatMessageHeader.init(frame: CGRectMake(0,0,FTScreenWidth,40), senderModel: message.messageSender)
        return header
    }
    
    public func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    public func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
     public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let message = messageArray[indexPath.section] 

        return FTChatMessageCell.getCellHeightWithMessage(message, shouldShowSendTime: shouldShowSendTime, shouldShowSenderName: shouldShowSenderName)
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let message = messageArray[indexPath.section]
        
//        let cell = FTChatMessageCell(style: UITableViewCellStyle.Default, reuseIdentifier: FTChatMessageCellReuseIndentifier, theMessage: message, shouldShowSendTime: shouldShowSendTime , shouldShowSenderName: shouldShowSenderName );
        let cell = tableView.dequeueReusableCellWithIdentifier(FTChatMessageCellReuseIndentifier, forIndexPath: indexPath) as! FTChatMessageCell
        cell.message = message
        return cell
    }
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    //MARK: - FTChatMessageAccessoryViewDataSource -

    public func ftChatMessageAccessoryViewItemCount() -> NSInteger {
        return 7
    }
    func ftChatMessageAccessoryViewItemCountEachRow() -> NSInteger {
        return 4
    }
    func ftChatMessageAccessoryViewItemSize() -> CGFloat {
        return 60
    }
    func ftChatMessageAccessoryViewImageForItemAtIndex(index: NSInteger) -> UIImage {
        return UIImage(named: "FT_Record")!
    }
    func ftChatMessageAccessoryViewBackgroundColorForItemAtIndex(index: NSInteger) -> UIColor {
        return UIColor(red: 255/255, green: 38/255, blue: 172/255, alpha: 1)
    }

    
    //MARK: - FTChatMessageAccessoryViewDelegate -

    func ftChatMessageAccessoryViewDidTappedOnItemAtIndex(index: NSInteger) {
        print("tapped : \(index)")
    }
    
    
    
    //MARK: - preferredInterfaceOrientationForPresentation -

    override public func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.Portrait
    }

}
