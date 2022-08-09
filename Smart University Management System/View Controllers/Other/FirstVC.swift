//
//  ViewController.swift
//  Smart University Management System
//
//  Created by Kamal Trapasiya on 2022-02-04.
//

import UIKit
import PDFKit
import CoreServices
import AZSClient
import ImageDetect

class FirstVC: UIViewController, UIDocumentPickerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { time in
            if let value = UserDefaults.standard.value(forKey: "login") as? [String:Any] {
                let identity = Int(value["identify"] as! String)
                if identity == 1 {
                    //admin
                    self.performSegue(withIdentifier: "adminSegue", sender: nil)
                }
                else if identity == 2 {
                    //faculty
                    self.performSegue(withIdentifier: "facultySegue", sender: nil)
                }
                else if identity == 3 {
                    self.performSegue(withIdentifier: "studentSegue", sender: nil)
                }
            }
            else {
                self.performSegue(withIdentifier: "signInSegue", sender: nil)
            }
        }
    }
    
    @IBAction func click(_ sender: Any) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
        
//        let documentPickerController = UIDocumentPickerViewController.init(documentTypes: [kUTTypePDF as! String], in: .import)
//
//        documentPickerController.delegate = self
//        self.present(documentPickerController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let img = info[.originalImage] as! UIImage
        
        img.detector.crop(type: .face) { result in
            switch result {
            case .success(let croppedImages):
                // When the `Vision` successfully find type of object you set and successfuly crops it.
                let img = croppedImages[0]
                print("Found")
            case .notFound:
                // When the image doesn't contain any type of object you did set, `result` will be `.notFound`.
                print("Not Found")
            case .failure(let error):
                // When the any error occured, `result` will be `failure`.
                print(error.localizedDescription)
            }
        }
        
        
//        do {
//            let account = try AZSCloudStorageAccount.init(fromConnectionString: "DefaultEndpointsProtocol=https;AccountName=facedatafiles;AccountKey=tN1Or/KuNMygxUwj4lD5EtGLxc1Larnq2uRQZ2s9fvAq5bCcoQIcUSTkEXiPsX5I31YIz164aQ3gpXirkxB0vQ==;EndpointSuffix=core.windows.net")
//
//            let client = account.getBlobClient()
//
//            let blobContainer = client.containerReference(fromName: "kamal")
//            blobContainer.createContainerIfNotExists(with: AZSContainerPublicAccessType.container, requestOptions: nil, operationContext: nil) { error, succ in
//                if error == nil {
//                    let blob = blobContainer.blockBlobReference(fromName: "samaple")
//
//                    let img = info[.originalImage] as! UIImage
//
//                    blob.upload(from: img.pngData()!) { error in
//                        if error == nil {
//                            print("Success")
//                        }
//                    }
//                }
//            }
//        }
//        catch {
//            print(error)
//        }
        
        
        
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let pdf = PDFDocument(url: urls.first!) {
            let pageCount = pdf.pageCount
            let documentContent = NSMutableAttributedString()
            
            for i in 0 ..< pageCount {
                let page = pdf.page(at: i)
                let pageContent = page?.attributedString
                documentContent.append(pageContent!)
            }
            print(documentContent.string)
        }
    }
    
    @IBAction func adminAction(_ sender: Any) {
        self.performSegue(withIdentifier: "signInSegue", sender: nil)
    }
    
    @IBAction func facultyAction(_ sender: Any) {
        self.performSegue(withIdentifier: "signInSegue", sender: nil)
    }
    
    @IBAction func studentAction(_ sender: Any) {
        self.performSegue(withIdentifier: "signInSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "signInSegue" {
            let vc = segue.destination as! SignVC
        }
    }
}

