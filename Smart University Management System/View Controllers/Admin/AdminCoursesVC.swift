//
//  AdminCoursesVC.swift
//  Smart University Management System
//
//  Created by Kamal Trapasiya on 2022-03-23.
//

import UIKit
import Alamofire

class AdminCoursesVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var addCourse: UIButton!
    
    var courseArr = [[String:Any]]()
    var searchCourseArr = [[String:Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        designInit()
        getCourses()
    }
    
    func designInit() {
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.backgroundColor = .clear
    }
    
    func getCourses() {
        let url = "https://apidockerpython.azurewebsites.net//api/subject/select"
        let param : [String:Any] = [
            "program_id" : ""
        ]
        let jsonData = try! JSONSerialization.data(withJSONObject: param)
        var request = URLRequest.init(url: URL.init(string: url)!)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.headers = HTTPHeaders.init([HTTPHeader.init(name: "Content-Type", value: "application/json")])
        AF.request(request).responseJSON { [self] result in
            if let value = result.value as? [String:Any] {
                courseArr = value["data"] as! [[String:Any]]
                self.searchCourseArr = courseArr
                self.collectionView.reloadData()
            }
        }
    }
    
    //MARK: Searchbar delegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text!.count > 0 {
            courseArr = searchCourseArr
            courseArr = courseArr.filter({ dict in
                let subject = (dict["course_name"] as! String).lowercased()
                let category = (dict["program"] as! String).lowercased()
                let id = (dict["course_id"] as! String).lowercased()
                if subject.contains(searchText.lowercased()) || category.contains(searchText.lowercased()) || id.contains(searchText.lowercased()) {
                    return true
                }
                return false
            })
            self.collectionView.reloadData()
        }
        else {
            courseArr = searchCourseArr
            self.collectionView.reloadData()
        }
    }
    
    //MARK: Collectionview delegates
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return courseArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: self.view.frame.width - 32, height: 72)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "studentCell", for: indexPath) as! CollectionViewCell
        let parti = courseArr[indexPath.row]
        let subject = parti["course_name"] as! String
        let category = parti["program_name"] as! String
        let id = parti["course_id"] as! String
        cell.studentID.text = id
        cell.studentName.text = subject
        cell.studentEmail.text = category
        return cell
    }
  
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
