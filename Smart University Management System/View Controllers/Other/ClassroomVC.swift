//
//  ClassroomVC.swift
//  Smart University Management System
//
//  Created by Kamal Trapasiya on 2022-03-23.
//

import UIKit
import Alamofire

class ClassroomVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var backAction: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    var currentCourseArr = [[String:Any]]()
    
    var courseDict = [String:Any]()
    
    var isFaculty = false

    override func viewDidLoad() {
        super.viewDidLoad()
        getCurrentCourses()
    }
    
    func getCurrentCourses() {
        if let login = UserDefaults.standard.dictionary(forKey: "login") as? [String:Any] {
            
            let id = login["id"] as! String
            
            var url = String()
            var param = [String:Any]()
            if isFaculty {
                //Faculty
                url = "https://coursepred.azurewebsites.net/api/prof/select"
                param = [
                    "professor_id" : id,
                    "term": getSeason()
                ]
            }
            else {
                //Student
                url = "https://apidockerpython.azurewebsites.net//api/student-course/select"
                param = [
                    "student_id" : id,
                    "term": getSeason()
                ]
            }
            
            let jsonData = try! JSONSerialization.data(withJSONObject: param)
            
            var request = URLRequest.init(url: URL.init(string: url)!)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            request.headers = HTTPHeaders.init([HTTPHeader.init(name: "Content-Type", value: "application/json")])
            
            AF.request(request).responseJSON { [self] result in
                
                if let value = result.value as? [String:Any] {
                    let arr = value["data"] as! [[String:Any]]
                    currentCourseArr = arr
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    //MARK: Collectionview delegates
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return currentCourseArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: self.view.frame.width - 32, height: 72)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "classCell", for: indexPath) as! CollectionViewCell
        
        let parti = currentCourseArr[indexPath.row]
        cell.courseName.text = parti["course_name"] as! String
        cell.courseProfessorName.text = parti["faculty"] as! String
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        courseDict = currentCourseArr[indexPath.row]
        
        if isFaculty {
            //Faculty
            self.performSegue(withIdentifier: "facultyCourseSegue", sender: nil)
        }
        else {
            self.performSegue(withIdentifier: "courseHomeVC", sender: nil)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if isFaculty {
            //Faculty
            if segue.identifier == "facultyCourseSegue" {
                let vc = segue.destination as! FacultyCourseHomeVC
                vc.courseDict = courseDict
            }
        }
        else {
            //students
            if segue.identifier == "courseHomeVC" {
                let vc = segue.destination as! CourseHomeVC
                vc.courseDict = courseDict
            }
        }
        
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    

}
