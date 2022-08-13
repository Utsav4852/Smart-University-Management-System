//
//  AddressVC.swift
//  Smart University Management System
//
//  Created by Kamal Trapasiya on 2022-02-21.
//

import UIKit
import CoreLocation
import SkyFloatingLabelTextField
import Alamofire

class AddressVC: UIViewController {
    
    var locManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    @IBOutlet weak var addressTxtField: SkyFloatingLabelTextField!
    @IBOutlet weak var cityTxtField: SkyFloatingLabelTextField!
    @IBOutlet weak var provinceTxtField: SkyFloatingLabelTextField!
    @IBOutlet weak var countryTxtField: SkyFloatingLabelTextField!
    @IBOutlet weak var postalTxtField: SkyFloatingLabelTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let login = UserDefaults.standard.dictionary(forKey: "login") as? [String:Any] {
            let address = login["address"] as! String
            let city = login["city"] as! String
            let province = login["province"] as! String
            let country = login["country"] as! String
            let postal = login["postalcode"] as! String
            addressTxtField.text = address
            cityTxtField.text = city
            provinceTxtField.text = province
            countryTxtField.text = country
            postalTxtField.text = postal
        }
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveAction(_ sender: Any) {
        if let login = UserDefaults.standard.dictionary(forKey: "login") as? [String:Any] {
            var loginDict = login
            let url = "https://apidockerpython.azurewebsites.net//api/update"
            loginDict["address"] = addressTxtField.text
            loginDict["city"] = cityTxtField.text
            loginDict["province"] = provinceTxtField.text
            loginDict["country"] = countryTxtField.text
            loginDict["postalcode"] = postalTxtField.text
            let jsonData = try! JSONSerialization.data(withJSONObject: loginDict)
            var request = URLRequest.init(url: URL.init(string: url)!)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            request.headers = HTTPHeaders.init([HTTPHeader.init(name: "Content-Type", value: "application/json")])
            AF.request(request).responseJSON { [self] result in
                if let value = result.value as? [String:Any] {
                    let status_code = value["status_code"] as! Int
                    if status_code == 1 {
                        //Successful
                        let data = value["data"] as! [[String:Any]]
                        let dict = data[0]
                        UserDefaults.standard.set(dict, forKey: "login")
                        UserDefaults.standard.synchronize()
                        self.dismiss(animated: true) {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "update"), object: nil)
                        }
                    }
                    else {
                        self.view.makeToast("Something went wrong!")
                    }
                }
            }
        }
    }
    
    @IBAction func autoDetectAddress(_ sender: Any) {
        locManager.requestWhenInUseAuthorization()
        if
            CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
                CLLocationManager.authorizationStatus() ==  .authorizedAlways
        {
            currentLocation = locManager.location
            let longi = "\(currentLocation.coordinate.longitude)"
            let lati = "\(currentLocation.coordinate.latitude)"
            getAddressFromLatLon(pdblLatitude: lati, withLongitude: longi)
        }
    }
    
    
    func getAddressFromLatLon(pdblLatitude: String, withLongitude pdblLongitude: String) {
        var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        let lat: Double = Double("\(pdblLatitude)")!
        let lon: Double = Double("\(pdblLongitude)")!
        let ceo: CLGeocoder = CLGeocoder()
        center.latitude = lat
        center.longitude = lon
        let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
        ceo.reverseGeocodeLocation(loc, completionHandler:
                                    { [self](placemarks, error) in
            if (error != nil)
            {
                print("reverse geodcode fail: \(error!.localizedDescription)")
            }
            let pm = placemarks! as [CLPlacemark]
            if pm.count > 0 {
                let pm = placemarks![0]
                addressTxtField.text = pm.name
                cityTxtField.text = pm.locality
                provinceTxtField.text = pm.administrativeArea
                countryTxtField.text = pm.country
                postalTxtField.text = pm.postalCode
            }
        })
    }
}
