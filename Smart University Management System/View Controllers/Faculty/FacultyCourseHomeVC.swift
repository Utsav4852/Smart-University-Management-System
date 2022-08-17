//
//  FacultyCourseHomeVC.swift
//  Smart University Management System
//
//  Created by Kamal Trapasiya on 2022-06-08.
//

import UIKit

class FacultyCourseHomeVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var courseTitle: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var courseName = String()
    var courseDict = [String:Any]()
    var sectionArr = ["Attendance", "Assessment"]
    var dict = ["Attendance" : ["Attendance"], "Assessment": ["Exam"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        courseName = courseDict["course_name"] as! String
        courseTitle.text = courseName
    }
    
    //MARK: Collectionview delegates
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sectionArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.view.frame.width - 48)/2  
        return CGSize.init(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dict["\(sectionArr[section])"]!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! CollectionReusableView
        headerView.titleLbl.text = sectionArr[indexPath.section]
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        let section = sectionArr[indexPath.section]
        let parti = dict[section] as! [String]
        cell.categoryName.text = parti[indexPath.row]
        cell.categoryImgView.image = UIImage.init(named: parti[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                //Attedance
                self.performSegue(withIdentifier: "facultyAttendanceSegue", sender: nil)
            }
        }
        else if indexPath.section == 1 {
            if indexPath.row == 0 {
                //Exam
                self.performSegue(withIdentifier: "examSegue", sender: nil)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "facultyAttendanceSegue" {
            let vc = segue.destination as! FacultyAttendanceVC
            vc.courseName = courseName
        }
        else if segue.identifier == "examSegue" {
            let vc = segue.destination as! FacultyExamVC
            vc.courseName = courseName
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
