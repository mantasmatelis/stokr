//
//  ViewController.swift
//  icestream
//
//  Created by Dev Chakraborty on 2015-09-19.
//  Copyright © 2015 IceStream. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var loginButton: NSButton!
    @IBOutlet weak var isEmail: NSTextField!
    @IBOutlet weak var isPassword: NSTextField!
    @IBOutlet weak var isConnected: NSTextField!
    
    required init?(coder: NSCoder) {
        super.init(coder:coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
//        isEmail.stringValue = "me@mantasmatelis.com"
//        isPassword.stringValue = "password"
        
    }
    
    override func viewDidAppear() {
        self.view.window!.styleMask = NSClosableWindowMask | NSTitledWindowMask | NSMiniaturizableWindowMask  // | NSResizableWindowMask
        
    }
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @IBAction func doLogin(sender:AnyObject) {
        Client.sharedClient.login(isEmail.stringValue, password: isPassword.stringValue) { (err, ip, password) in
            if err != nil {
                print(err)
                return
            }
            Client.sharedClient.connect(ip!, password: password!) { (err) in
                if err != nil {
                    print(err)
                    return
                }
                self.loginButton.hidden = true
                self.isEmail.hidden = true
                self.isPassword.hidden = true
                self.isConnected.hidden = false
            }
        }
    }
}

