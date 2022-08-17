//
//  ProfileVC.swift
//  Smart University Management System
//
//  Created by Kamal Trapasiya on 2022-02-21.
//

import UIKit
import YPImagePicker
import Alamofire
import XCTest
import AZSClient
import SDWebImage

class ProfileVC: UIViewController {
    
    @IBOutlet weak var fnameLbl: UILabel!
    @IBOutlet weak var lnameLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var contactLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var profileImgView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        NotificationCenter.default.addObserver(self, selector: #selector(updateAction), name: NSNotification.Name.init(rawValue: "update"), object: nil)
    }
    
    @objc func updateAction() {
        self.view.makeToast("Updated Successfully!")
        getData()
    }
    
    func getData() {
        if let login = UserDefaults.standard.dictionary(forKey: "login") as? [String:Any] {
            let firstName = login["firstname"] as! String
            let lastName = login["lastname"] as! String
            let email = login["email"] as! String
            let country_code = login["country_code"] as! String
            let contact = login["contact_no"] as! String
            let address = login["address"] as! String
            let city = login["city"] as! String
            let province = login["province"] as! String
            let country = login["country"] as! String
            let postal = login["postalcode"] as! String
            let profile_pic = login["profile_pic"] as! String
            self.profileImgView.sd_setImage(with: URL.init(string: profile_pic)) { img, error, cache, url in
            }
            fnameLbl.text = firstName
            lnameLbl.text = lastName
            emailLbl.text = email
            contactLbl.text = "\(country_code) \(contact)"
            addressLbl.text = "\(address), \(city), \(province), \(country), \(postal)"
        }
    }
    
    @IBAction func editProfileAction(_ sender: Any) {
        if let login = UserDefaults.standard.dictionary(forKey: "login") as? [String:Any] {
            var config = YPImagePickerConfiguration()
            config.usesFrontCamera = true
            let newCapturePhotoImage = UIImage.init(named: "camera")
            ?? config.icons.capturePhotoImage
            config.icons.capturePhotoImage = newCapturePhotoImage
            let picker = YPImagePicker(configuration: config)
            picker.didFinishPicking { [unowned picker] items, _ in
                if let photo = items.singlePhoto {
                    print(photo.fromCamera) // Image source (camera or library)
                    let profile_picture = photo.image
                    let id = login["id"] as! String
                    do {
                        let account = try AZSCloudStorageAccount.init(fromConnectionString: "DefaultEndpointsProtocol=https;AccountName=facedatafiles;AccountKey=tN1Or/KuNMygxUwj4lD5EtGLxc1Larnq2uRQZ2s9fvAq5bCcoQIcUSTkEXiPsX5I31YIz164aQ3gpXirkxB0vQ==;EndpointSuffix=core.windows.net")
                        let client = account.getBlobClient()
                        let blobContainer = client.containerReference(fromName: "profile")
                        blobContainer.createContainerIfNotExists(with: AZSContainerPublicAccessType.container, requestOptions: nil, operationContext: nil) { error, succ in
                            if error == nil {
                                let blob = blobContainer.blockBlobReference(fromName: "\(id).png")
                                let img = resizedImageWith(image: profile_picture, targetSize: CGSize.init(width: 512, height: 512))
                                blob.upload(from: img.pngData()!) { error in
                                    if error == nil {
                                        print("Success")
                                        print(blob.storageUri.primaryUri)
                                        let url = "https://apidockerpython.azurewebsites.net//api/update"
                                        var loginDict = login
                                        loginDict["profile_pic"] = blob.storageUri.primaryUri.absoluteString
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
                                                    getData()
                                                }
                                                else {
                                                    self.view.makeToast("Something went wrong!")
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    catch {
                        print(error)
                    }
                }
                picker.dismiss(animated: true, completion: nil)
            }
            present(picker, animated: true, completion: nil)
        }
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "login")
        UserDefaults.standard.synchronize()
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func editAddressAction(_ sender: Any) {
        self.performSegue(withIdentifier: "addressSegue", sender: nil)
    }
    
    @IBAction func editContactAction(_ sender: Any) {
        self.performSegue(withIdentifier: "contactSegue", sender: nil)
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
