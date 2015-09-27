//
//  Client.swift
//  icestream
//
//  Created by Dev Chakraborty on 2015-09-19.
//  Copyright © 2015 IceStream. All rights reserved.
//

import Foundation
import AFNetworking
import Security

let API_ROOT = "http://icestream.co/api"

class Client {
    var manager:AFURLSessionManager!
    var vpnTask:NSTask?
    
    init() {
        manager = AFURLSessionManager(sessionConfiguration: NSURLSessionConfiguration.defaultSessionConfiguration())
    }
    
    static let sharedClient = Client()
    
    func post(route:String, params:[String:AnyObject], callback:(err:NSError?, result:[String:AnyObject]?) -> Void) {
        let url = NSURL(string: "\(API_ROOT)\(route)")!
        
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        let body = params.stringFromHttpParameters()
        request.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
        
        print("BODY", body)
        
        let task = manager.dataTaskWithRequest(request) { (_, obj, error) in
            if error != nil {
                callback(err: error, result: nil)
                return
            }
            callback(err: nil, result: obj as! [String:AnyObject])
        }
        
        task.resume()
    }
    
    func login(email:String, password:String, callback:(err:NSError?, ip:String?, password:String?) -> Void) {
        post("/login", params: ["Email":email, "Password":password]) { (error, result) in
            if error != nil {
                print(error)
                return
            }
            callback(err: nil, ip: result!["Ip"] as? String, password: "mantas4president!")
        }
    }
    
    func connect(ip:String, password:String, callback:(err:NSError?) -> Void) {
        
//        var authRef:AuthorizationRef = nil
        
//        PreauthorizePrivilegedProcess(&authRef)
//        
//        LaunchPreauthorizedProcess(&authRef, NSBundle.mainBundle().resourcePath!.stringByAppendingString("/openvpn-start.sh"))
        
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            
            let certPath = NSBundle.mainBundle().resourcePath!.stringByAppendingString("/ca.crt")
            
            let source = "do shell script \"/bin/bash -c \\\"/usr/local/sbin/openvpn --config <(echo $'client\\ndev tap1\\nproto udp\\nresolv-retry infinite\\nnobind\\npersist-key\\npersist-tun\\nca \(certPath)\\nverb 3\\nauth-user-pass\\n') --remote \(ip) --auth-user-pass <(echo $'Administrator\\n\(password)')\\\"\" with administrator privileges"
            
            print(source)
            
            let run = NSAppleScript(source: source)
            
            dispatch_async(dispatch_get_main_queue()) {
                callback(err: nil)
            }
            
            run!.executeAndReturnError(nil)
        }
        
//        dispatch_async(dispatch_get_global_queue(priority, 0)) {
//            
//            let certPath = NSBundle.mainBundle().resourcePath!.stringByAppendingString("/ca.crt")
//            
//            let source = "repeat\nif not exists (processes where name is icestream) "
//            
//            print(source)
//            
//            let run = NSAppleScript(source: source)
//            
//            dispatch_async(dispatch_get_main_queue()) {
//                callback(err: nil)
//            }
//            
//            run!.executeAndReturnError(nil)
//        }
        
//        vpnTask = NSTask()
//        let outputPipe = NSPipe.init()
//        let path =
//        print("PATH", path)
//        vpnTask!.launchPath = "/bin/bash"
//        vpnTask!.arguments = [path, ip, password]
//        vpnTask!.standardOutput = outputPipe
//        vpnTask!.standardError = outputPipe
//        outputPipe.fileHandleForReading.readabilityHandler = { (file:NSFileHandle) in
//            print("READ")
//            print(NSString(data:file.availableData, encoding:NSUTF8StringEncoding))
//        }
//        vpnTask!.terminationHandler = { (task:NSTask) in
//            print("TERMINATED")
//            outputPipe.fileHandleForReading.readabilityHandler = nil
//            self.vpnTask = nil
//        }
//        vpnTask!.launch()
//        callback(err: nil)
    }
    
    func cleanup() {
        print("CLEANUP...", vpnTask)
        vpnTask?.terminate()
    }
}

extension String {
    
    func stringByAddingPercentEncodingForURLQueryValue() -> String? {
        let characterSet = NSMutableCharacterSet.alphanumericCharacterSet()
        characterSet.addCharactersInString("-._~")
        
        return self.stringByAddingPercentEncodingWithAllowedCharacters(characterSet)
    }
    
}


extension Dictionary {
    
    func stringFromHttpParameters() -> String {
        let parameterArray = self.map { (key, value) -> String in
            let percentEscapedKey = (key as! String).stringByAddingPercentEncodingForURLQueryValue()!
            let percentEscapedValue = (value as! String).stringByAddingPercentEncodingForURLQueryValue()!
            return "\(percentEscapedKey)=\(percentEscapedValue)"
        }
        
        return parameterArray.joinWithSeparator("&")
    }
    
}