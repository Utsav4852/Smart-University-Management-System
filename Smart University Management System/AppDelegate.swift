//
//  AppDelegate.swift
//  Smart University Management System
//
//  Created by Kamal Trapasiya on 2022-02-04.
//

import UIKit
import IQKeyboardManagerSwift
import Alamofire
import CoreLocation

@main
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    
    let locationManager = CLLocationManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        IQKeyboardManager.shared.enable = true
        
        setupLocationManager()
        
        return true
    }
    
    func setupLocationManager(){
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        getLocation(lati: locValue.latitude.description, longi: locValue.longitude.description)
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
    func getLocation(lati: String, longi: String) {
        if let login = UserDefaults.standard.dictionary(forKey: "login") as? [String:Any] {
            
            let id = login["id"] as! String
            
            let url = "https://apidockerpython.azurewebsites.net/api/location"
            
            let param : [String:Any] = [
                "id" : id,
                "lati": lati,
                "longi": longi
            ]
            
            let jsonData = try! JSONSerialization.data(withJSONObject: param)
            
            var request = URLRequest.init(url: URL.init(string: url)!)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            request.headers = HTTPHeaders.init([HTTPHeader.init(name: "Content-Type", value: "application/json")])
            
            AF.request(request).responseJSON { [self] result in
                if let value = result.value as? [String:Any] {
                    if let status = value["status_code"] as? Int {
                        if status == 1 {
                            //success
                        }
                    }
                }
            }
        }
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

