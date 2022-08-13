//
//  FacultyHomeVC.swift
//  Smart University Management System
//
//  Created by Kamal Trapasiya on 2022-02-07.
//

import UIKit

class FacultyHomeVC: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var categoryArr = ["Classroom"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLbl.printTitle()
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
            self.performSegue(withIdentifier: "classroomSegue", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "classroomSegue" {
            let vc = segue.destination as! ClassroomVC
            vc.isFaculty = true
        }
    }
    
    @IBAction func profileAction(_ sender: Any) {
        self.performSegue(withIdentifier: "profileSegue", sender: nil)
    }
}
