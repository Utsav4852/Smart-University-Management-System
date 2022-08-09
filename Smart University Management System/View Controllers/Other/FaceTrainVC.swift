//
//  FaceTrainVC.swift
//  Smart University Management System
//
//  Created by Kamal Trapasiya on 2022-03-11.
//

import UIKit
import CameraManager
import AVKit
import AZSClient
import Alamofire
import CoreLocation

class FaceTrainVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CLLocationManagerDelegate {
    
    let cameraManager = CameraManager()
    
    var imgArr:[UIImage] = []
    
    var isTrain = true
    var courseName = String()
    var facultyId = String()
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var captureBtn: UIButton!
    @IBOutlet weak var instructionLbl: UILabel!
    
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var cameraView: UIView!
    
    let locationManager = CLLocationManager()
    
    var profLati = CLLocationDegrees()
    var profLongi = CLLocationDegrees()
    var lati = CLLocationDegrees()
    var longi = CLLocationDegrees()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !isTrain {
            collectionView.isHidden = true
            captureBtn.setTitle("Attendance", for: .normal)
            instructionLbl.text = "Please fill your attendance for \(courseName) course"
            backBtn.isHidden = false
        }
        else {
            collectionView.isHidden = false
            captureBtn.setTitle("Capture", for: .normal)
            instructionLbl.text = "Please capture 50 selfies with different angle of your face"
            backBtn.isHidden = true
        }
        
        cameraView.layer.cornerRadius = (self.view.frame.width - 100)/2
        cameraManager.cameraDevice = .front
        cameraManager.cameraOutputMode = .stillImage
        cameraManager.focusMode = .continuousAutoFocus
        cameraManager.addPreviewLayerToView(self.cameraView)
        
        getProfLocation()
        
    }
    
    func getProfLocation() {
        //let id = login["id"] as! String
        let url = "https://apidockerpython.azurewebsites.net/api/select/location"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let dateStr = dateFormatter.string(from: Date())
        
        let param : [String:Any] = [
            "id" : facultyId
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: param)
        
        var request = URLRequest.init(url: URL.init(string: url)!)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.headers = HTTPHeaders.init([HTTPHeader.init(name: "Content-Type", value: "application/json")])
        
        AF.request(request).responseJSON { [self] result in
            
            if let value = result.value as? [String:Any] {
                profLati = Double(value["lati"] as! String)!
                profLongi = Double(value["longi"] as! String)!
                setupLocationManager()
            }
        }
    }
    
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setupLocationManager(){
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        lati = locValue.latitude
        longi = locValue.longitude
        validateLocation()
    }
    
    func validateLocation() -> Bool {
        let studentLoc = CLLocation(latitude:
                                        lati, longitude: longi)
        let profLoc = CLLocation(latitude: profLati, longitude: profLongi)
        
        let distanceInMeters = studentLoc.distance(from: profLoc)
        
        if distanceInMeters <= 100 {
            return true
        }
        else {
            return false
        }
    }
    
    @IBAction func captureAction(_ sender: UIButton) {
        
        if !isTrain {
            //Face Recognition
            
            if validateLocation() {
                cameraManager.capturePictureWithCompletion { result in
                    switch result {
                    case .failure: break
                        // error handling
                    case .success(let content):
                        
                        self.showLoader()
                        
                        let img = content.asImage!
                        if let login = UserDefaults.standard.dictionary(forKey: "login") as? [String:Any] {
                            
                            let id = login["id"] as! String
                            
                            do {
                                let account = try AZSCloudStorageAccount.init(fromConnectionString: "DefaultEndpointsProtocol=https;AccountName=facedatafiles;AccountKey=tN1Or/KuNMygxUwj4lD5EtGLxc1Larnq2uRQZ2s9fvAq5bCcoQIcUSTkEXiPsX5I31YIz164aQ3gpXirkxB0vQ==;EndpointSuffix=core.windows.net")
                                
                                let client = account.getBlobClient()
                                
                                let blobContainer = client.containerReference(fromName: "attendance")
                                blobContainer.createContainerIfNotExists(with: AZSContainerPublicAccessType.container, requestOptions: nil, operationContext: nil) { error, succ in
                                    if error == nil {
                                        
                                        DispatchQueue.global(qos: .background).async {
                                            let blob = blobContainer.blockBlobReference(fromName: "\(id).png")
                                            let img = resizedImageWith(image: img, targetSize: CGSize.init(width: 256, height: 256))
                                            blob.upload(from: img.pngData()!) { error in
                                                if error == nil {
                                                    DispatchQueue.main.async {
                                                        print("Success")
                                                        self.fillAttendance()
                                                        print(blob.storageUri.primaryUri)
                                                    }
                                                }
                                                else {
                                                    DispatchQueue.main.async {
                                                        self.view.makeToast("Something went wrong!")
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            catch {
                                print("error")
                            }
                        }
                    }
                }
            }
            else {
                //Not in range
                self.view.makeToast("Please make sure you are in a classroom")
            }
        }
        else {
            if imgArr.count < 50 {
                cameraManager.capturePictureWithCompletion { result in
                    switch result {
                    case .failure: break
                        // error handling
                    case .success(let content):
                        self.imgArr.append(content.asImage!)
                        self.collectionView.reloadData()
                        
                        if self.imgArr.count >= 50 {
                            //Upload
                            sender.isEnabled = false
                            
                            if let login = UserDefaults.standard.dictionary(forKey: "login") as? [String:Any] {
                                
                                let id = login["id"] as! String
                                
                                do {
                                    let account = try AZSCloudStorageAccount.init(fromConnectionString: "DefaultEndpointsProtocol=https;AccountName=facedatafiles;AccountKey=tN1Or/KuNMygxUwj4lD5EtGLxc1Larnq2uRQZ2s9fvAq5bCcoQIcUSTkEXiPsX5I31YIz164aQ3gpXirkxB0vQ==;EndpointSuffix=core.windows.net")
                                    
                                    let client = account.getBlobClient()
                                    
                                    let blobContainer = client.containerReference(fromName: id)
                                    blobContainer.createContainerIfNotExists(with: AZSContainerPublicAccessType.container, requestOptions: nil, operationContext: nil) { error, succ in
                                        if error == nil {
                                            
                                            DispatchQueue.global(qos: .background).async {
                                                for k in 0..<self.imgArr.count {
                                                    let blob = blobContainer.blockBlobReference(fromName: "\(k + 1).png")
                                                    let img = resizedImageWith(image: self.imgArr[k], targetSize: CGSize.init(width: 256, height: 256))
                                                    blob.upload(from: img.pngData()!) { error in
                                                        if error == nil {
                                                            DispatchQueue.main.async {
                                                                print("Success")
                                                                print(blob.storageUri.primaryUri)
                                                                self.dismiss(animated: true, completion: nil)
                                                            }
                                                        }
                                                        else {
                                                            DispatchQueue.main.async {
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
                                    print("error")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func fillAttendance() {
        if let login = UserDefaults.standard.dictionary(forKey: "login") as? [String:Any] {
            
            let id = login["id"] as! String
            let url = "https://apidockerpython.azurewebsites.net/api/face/recognize"
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let dateStr = dateFormatter.string(from: Date())
            
            let param : [String:Any] = [
                "student_id" : id,
                "registered_course" : courseName,
                "current_date" : dateStr
            ]
            
            let jsonData = try! JSONSerialization.data(withJSONObject: param)
            
            var request = URLRequest.init(url: URL.init(string: url)!)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            request.headers = HTTPHeaders.init([HTTPHeader.init(name: "Content-Type", value: "application/json")])
            
            AF.request(request).responseJSON { [self] result in
                self.dismissLoader()
                if let value = result.value as? [String:Any] {
                    if let status = value["status_code"] as? Int {
                        if status == 1 {
                            //Attendance recorded successfully
                            self.view.makeToast("Yayy! Attendance recorded successfully for \(courseName)!")
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                        else if status == 2 {
                            //Already recorded
                            self.view.makeToast("Your attendance already recorded for \(courseName)")
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                        else {
                            self.view.makeToast("Something went wrong!")
                        }
                    }
                    else {
                        self.view.makeToast("Something went wrong!")
                    }
                }
                else {
                    self.view.makeToast("Please make sure your face is visible")
                }
            }
        }
    }
    
    //MARK: Collectionview delegates
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imgArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 90, height: 90)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "trainCell", for: indexPath) as! CollectionViewCell
        
        cell.faceTrainImgView.image = imgArr[indexPath.row]
        
        return cell
    }
    
}
