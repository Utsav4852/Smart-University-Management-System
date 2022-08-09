//
//  AdminHomeVC.swift
//  Smart University Management System
//
//  Created by Kamal Trapasiya on 2022-02-07.
//

import UIKit

class AdminHomeVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var profileImgView: UIImageView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var categoryArr = ["Courses"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLbl.printTitle()
        
        if let login = UserDefaults.standard.dictionary(forKey: "login") as? [String:Any] {
            let profile_pic = login["profile_pic"] as! String
            
            DispatchQueue.global().async { [weak self] in
                if let data = try? Data(contentsOf: URL.init(string: profile_pic)!) {
                    if let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self!.profileImgView.image = image
                        }
                    }
                    else {
                        self?.profileImgView.image = UIImage.init(named: "user")
                    }
                }
                else {
                    self?.profileImgView.image = UIImage.init(named: "user")
                }
            }
        }
    }
    
    //MARK: Collectionview delegates
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: (self.view.frame.width - 48)/2, height: 70)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath) as! CollectionViewCell
        
        cell.adminHomeCategoryName.text = categoryArr[indexPath.row]
        cell.adminHomeCategoryImgView.image = UIImage.init(named: categoryArr[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            //Course
            self.performSegue(withIdentifier: "courseSegue", sender: nil)
        }
    }

    
    @IBAction func profileAction(_ sender: Any) {
        self.performSegue(withIdentifier: "profileSegue", sender: nil)
    }
    
    @IBAction func facultyAction(_ sender: Any) {
        self.performSegue(withIdentifier: "facultySegue", sender: nil)
    }
    
    @IBAction func studentAction(_ sender: Any) {
        self.performSegue(withIdentifier: "studentSegue", sender: nil)
    }
   
}
