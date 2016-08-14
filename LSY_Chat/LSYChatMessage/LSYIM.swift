//
//  LSYIM.swift
//  LSY_Chat
//
//  Created by 李世洋 on 16/8/13.
//  Copyright © 2016年 李世洋. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

private enum IMError: ErrorType {

    case LoginError // 登录失败
}

private let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
//MARK: - 用户登录
public class LoginClient: NSObject {
    
    typealias logInErrorHandler = (error: EMError) -> Void
    
    var loginHandler: logInErrorHandler?
    
    override init () {
        super.init()
        
        EMClient.sharedClient().addDelegate(self, delegateQueue: queue)
    }
    
    /**
     自动登录
     
     - parameter userName:     用户名
     - parameter userPassword: 密码
     */
    public func autoLogin(userName: String, userPassword: String, loginSuccess: () -> ()) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
//            let isAutoLogin = EMClient.sharedClient().options.isAutoLogin
//            if !isAutoLogin {
//                
//                let error = EMClient.sharedClient().loginWithUsername(userName, password: userPassword)
//                dispatch_async(dispatch_get_main_queue(), {
//                    
//                    if error == nil {
//                        
//                        print("登录成功")
//                        EMClient.sharedClient().options.isAutoLogin = true
//                        loginSuccess()
//                    } else {
//                        
//                        print(error.errorDescription)
//                    }
//                })
//            } else {
//                
//                dispatch_async(dispatch_get_main_queue(), {
//                    loginSuccess()
//                })
//                
//            }
            
            let error = EMClient.sharedClient().loginWithUsername(userName, password: userPassword)
            dispatch_async(dispatch_get_main_queue(), {
                
                if error == nil {
                    
                    print("登录成功")
                    loginSuccess()
                } else {
                    
                    print(error.errorDescription)
                }
            })
        }
    }
}


extension LoginClient: EMClientDelegate
{
    @objc public func didAutoLoginWithError(aError: EMError!) {
        
        if aError != nil {
            print(aError.errorDescription)
        }
        print(NSThread.currentThread())
       
    }
    
    @objc public func didConnectionStateChanged(aConnectionState: EMConnectionState) {
        
        
    }
    
    @objc public func didRemovedFromServer() {
        
    }
    
    @objc public func didLoginFromOtherDevice() {
        
    }
}

//MARK: - 接受消息
protocol ReceiveMessageDelegate: NSObjectProtocol {
    
    func receiveMessage(messageModel: FTChatMessageModel)
    
}

public class ReceiveMessage: NSObject {
    
    weak var delegate: ReceiveMessageDelegate?
    var fromSender = FTChatMessageSenderModel.init(id: "1", name: "SomeOne", icon_url: "http://ww3.sinaimg.cn/mw600/6cca1403jw1f3lrknzxczj20gj0g0t96.jpg", extra_data: nil, isSelf: false)
    
    override init() {
        super.init()
        
        EMClient.sharedClient().chatManager.addDelegate(self, delegateQueue: queue)
        print("开启消息管理器")
    }
 
}

extension ReceiveMessage: EMChatManagerDelegate {
    
    public func didReceiveMessages(aMessages: [AnyObject]!) {
     
        for message in aMessages {
            
            let msgBody = (message as! EMMessage).body
      
            switch msgBody.type {
            case EMMessageBodyTypeText:

                let text = (msgBody as! EMTextMessageBody).text
                let messageModel = FTChatMessageModel(data: text, time: "", from: fromSender, type: .Text)
                dispatch_async(dispatch_get_main_queue(), { 
                    self.delegate?.receiveMessage(messageModel)
                })
            case EMMessageBodyTypeImage:
                let body = msgBody as! EMImageMessageBody
                print("大图remote路径 -- \(body.remotePath)")
                print("大图local路径 -- \(body.localPath)")
                print("大图的secret -- \(body.secretKey)")
                print("大图的size -- \(body.size)")
                print("大图的下载状态 -- \(body.downloadStatus)")
                print("小图remote路径 -- \(body.thumbnailRemotePath)")
                print("小图local路径 -- \(body.thumbnailLocalPath)")
                print("小图的secret -- \(body.thumbnailSecretKey)")
                print("小图的size -- \(body.thumbnailSize)")
                print("小图的下载状态 -- \(body.thumbnailDownloadStatus)")
                

//                NSFileManager *mgr = [NSFileManager defaultManager];
//                if ([mgr fileExistsAtPath:imgBody.thumbnailLocalPath]) {
//                    //本地路径使用fileURLWithPath
//                    [self.chatImageView sd_setImageWithURL:[NSURL fileURLWithPath:imgBody.thumbnailLocalPath] placeholderImage:nil];
//                }else{
//                    [self.chatImageView sd_setImageWithURL:[NSURL URLWithString:imgBody.thumbnailRemotePath] placeholderImage:nil];
//                }
                let url = NSURL(fileURLWithPath: body.thumbnailLocalPath)
                
                print(url.absoluteString)
                let mgr = NSFileManager.defaultManager()
                if mgr.fileExistsAtPath(body.thumbnailLocalPath) {
                    
                    let url = NSURL(fileURLWithPath: body.thumbnailLocalPath)
                    
                    print(url.absoluteString)
                    DownLoadImage.getNetworkImage(url.absoluteString, completion: { (image) in
                        
                        print(NSThread.currentThread)
                        print(image)
                    })
                } else {
                    
                    DownLoadImage.getNetworkImage(body.thumbnailRemotePath, completion: { (image) in
                        
                        self.delegate?.receiveMessage(FTChatMessageModel(data: image, time: "", from: self.fromSender, type: .Image))
                    })
                }
                
                
//                print(thumbnailImage)
                

                
                
            default:
                break
            }
        }
    }
}


class DownLoadImage {
    
    class func getNetworkImage(urlString: String, completion: (UIImage? -> Void)) -> (Request) {
        return Alamofire.request(.GET, urlString).responseImage { (response) -> Void in
            guard let image = response.result.value else { return }
            completion(image)
        }
    }
}

