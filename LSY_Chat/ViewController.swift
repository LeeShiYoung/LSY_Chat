//
//  ViewController.swift
//  LSY_Chat
//
//  Created by 李世洋 on 16/8/12.
//  Copyright © 2016年 李世洋. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }

    @IBAction func pushAction(sender: AnyObject) {
        navigationController?.pushViewController(LSYChatDemoViewController(), animated: true)
    }
}

