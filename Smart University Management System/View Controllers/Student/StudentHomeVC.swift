//
//  StudentHomeVC.swift
//  Smart University Management System
//
//  Created by Kamal Trapasiya on 2022-02-07.
//

import UIKit
import AZSClient

class StudentHomeVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var categoryArr = ["Courses", "Classroom"]

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLbl.printTitle()
        if let login = UserDefaults.standard.dictionary(forKey: "login") as? [String:Any] {
            let id = login["id"] as! String
            do {
                let account = try AZSCloudStorageAccount.init(fromConnectionString: "DefaultEndpointsProtocol=https;AccountName=facedatafiles;AccountKey=tN1Or/KuNMygxUwj4lD5EtGLxc1Larnq2uRQZ2s9fvAq5bCcoQIcUSTkEXiPsX5I31YIz164aQ3gpXirkxB0vQ==;EndpointSuffix=core.windows.net")
                let client = account.getBlobClient()
                let blobContainer = client.containerReference(fromName: id)
                blobContainer.exists { error, isExist in
                    if error == nil {
                        if !isExist {
                            DispatchQueue.main.async {
                                self.performSegue(withIdentifier: "faceTrainSegue", sender: nil)
                            }
                        }
                    }
                }
            }catch {
                print("error")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let login = UserDefaults.standard.dictionary(forKey: "login") as? [String:Any] {
            let profile_pic = login["profile_pic"] as! String
            self.profileImgView.sd_setImage(with: URL.init(string: profile_pic)) { img, error, cache, url in
                print(error)
            }
        }
    }
    
    //MARK: Collectionview delegatess
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: (self.view.frame.width - 48)/2, height: (self.view.frame.width - 48)/2)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as! CollectionViewCell
        cell.categoryName.text = categoryArr[indexPath.row]
        cell.categoryImgView.image = UIImage.init(named: categoryArr[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            self.performSegue(withIdentifier: "courseSegue", sender: nil)
        }
        else if indexPath.row == 1 {
            self.performSegue(withIdentifier: "classroomSegue", sender: nil)
        }
    }
    
    @IBAction func profileAction(_ sender: Any) {
        self.performSegue(withIdentifier: "profileSegue", sender: nil)
    }
}
