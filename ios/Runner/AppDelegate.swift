import UIKit
import Flutter
    


@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    private var result0: FlutterResult?
    
    
    
    
    

        
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    
   
   
    
   
        
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(name: "org.vali.src/projectad",
                                                  binaryMessenger: controller.binaryMessenger)
    channel.setMethodCallHandler({
      [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
        
      // Note: this method is invoked on the UI thread.
      
        print(result);
        
      guard call.method == "getInstagramFollowersSwift" else {
        
        //ad handler
       
        if call.method == "loadAdAndShow" {
            
            
            
        }
        
        
        return;
        
      }
        
        print("arrive")
        guard let args = call.arguments else {
                return
              }
        print("arrive")
        if let myArgs = args as? [String: Any] {
            _ = myArgs["ab1"] as? String;
            guard let username = myArgs["username"] as? String,
                  let password = myArgs["password"] as? String,
                  !username.isEmpty, !password.isEmpty else {
                result("-1")
                return
            }
            let credentials = Credentials(username: username, password: password, verifyBy: .text)
            let handler = APIHandler()
            handler.authenticate(with: .user(credentials)) {
                switch $0 {
                case .success((let response, _)):
                    print("Login successful.")
                    // persist cache safely in the keychain for logging in again in the future.
                    guard let key = response.persist() else { return print("`Authentication.Response` could not be persisted.") }
                    // store the `key` wherever you want, so you can access the `Authentication.Response` later.
                    // `UserDefaults` is just an example.
                    UserDefaults.standard.set(key, forKey: "current.account")
                    UserDefaults.standard.synchronize()
                    
                    handler.users.following(user: .me, with: .init(maxPagesToLoad:.max), updateHandler: nil, completionHandler:  {var1,_ in
                        do{
                        let v : [User] = try var1.get();
                        print(v);
                            var usernames : String = "";
                            for user in v {
                                print(user);
                                usernames = usernames + user.username + ",";
                            }
                            result(usernames)
                            return;
                        }catch {
                            result("-1")
                            return;
                        }
                       
                        
                       
                        
                    })
                    
                case .failure(let error):
                    if error.requiresInstagramCode {
                        /* update interface to ask for code */
                        print("checkData");
                        
                    } else {
                        /* notify the user */   
                        print(error.localizedDescription);
                        print("errorData");
                        }
                }
            }
        }
        
           
    })
        
        
    
    GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    }
