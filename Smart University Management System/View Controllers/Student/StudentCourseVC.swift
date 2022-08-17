//
//  StudentCourseVC.swift
//  Smart University Management System
//
//  Created by Kamal Trapasiya on 2022-03-23.
//

import UIKit
import DropDown
import Alamofire

class StudentCourseVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeightConstant: NSLayoutConstraint!
    @IBOutlet weak var tableViewHeightConstant: NSLayoutConstraint!
    @IBOutlet weak var termFilterBtn: UIButton!
    @IBOutlet weak var recommendBtn: UIButton!
    
    var courseArr = [[String:Any]]()
    var tempCourseArr = [[String:Any]]()
    var recommendedCourseArr = [[String:Any]]()
    var currentCourseArr = [[String:Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        designInit()
        getCurrentCourses()
        getCourses()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.getRecommendedCourses()
        }
    }
    
    func designInit() {
        termFilterBtn.semanticContentAttribute = UIApplication.shared
            .userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft
        recommendBtn.semanticContentAttribute = UIApplication.shared
            .userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft
        tableView.rowHeight = 50
        tableView.separatorInset = UIEdgeInsets.init(top: 0, left: 16, bottom: 0, right: 16)
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        }
        tableView.tableFooterView = UIView()
    }
    
    @IBAction func termFilterBtnAction(_ sender: UIButton) {
        DropDown.appearance().backgroundColor = .white
        DropDown.appearance().selectionBackgroundColor = .secondarySystemBackground
        
        let dropDown = DropDown()
        dropDown.anchorView = sender
        dropDown.dataSource = ["All", "Winter 2022", "SS 2022", "Fall 2022"]
        dropDown.show()
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            termFilterBtn.setTitle(item, for: .normal)
            
            if index == 0 {
                //All
                courseArr = tempCourseArr
                self.collectionView.reloadData()
            }
            else {
                //SS 2022
                courseArr = tempCourseArr
                courseArr = courseArr.filter({ dict in
                    let term = dict["term"] as! String
                    if item == term {
                        return true
                    }
                    return false
                })
                self.collectionView.reloadData()
            }
            collectionViewHeightConstant.constant = (CGFloat(courseArr.count * (72 + 16))) + 34.0
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func recommendedAction(_ sender: UIButton) {
        
        DropDown.appearance().backgroundColor = .white
        DropDown.appearance().selectionBackgroundColor = .secondarySystemBackground
        
        let dropDownRecommend = DropDown()
        dropDownRecommend.anchorView = sender
        dropDownRecommend.dataSource = ["Default", "Recommended"]
        dropDownRecommend.show()
        
        dropDownRecommend.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            recommendBtn.setTitle(item, for: .normal)
            
            if index == 0 {
                //Default
                getCourses()
            }
            else {
                //Recommended
                courseArr = recommendedCourseArr
                tempCourseArr = courseArr
                self.collectionView.reloadData()
                collectionViewHeightConstant.constant = (CGFloat(courseArr.count * (72 + 16))) + 34.0
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func getCurrentCourses() {
        if let login = UserDefaults.standard.dictionary(forKey: "login") as? [String:Any] {
            let id = login["id"] as! String
            let url = "https://apidockerpython.azurewebsites.net//api/student-course/select"
            let param : [String:Any] = [
                "student_id" : id,
                "term": ""
            ]
            let jsonData = try! JSONSerialization.data(withJSONObject: param)
            var request = URLRequest.init(url: URL.init(string: url)!)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            request.headers = HTTPHeaders.init([HTTPHeader.init(name: "Content-Type", value: "application/json")])
            AF.request(request).responseJSON { [self] result in
                if let value = result.value as? [String:Any] {
                    let arr = value["data"] as! [[String:Any]]
                        currentCourseArr = arr
                        tableView.reloadData()
                    if currentCourseArr.count > 0 {
                        tableViewHeightConstant.constant = CGFloat(currentCourseArr.count * 50) + 50.0
                    }
                    else {
                        tableViewHeightConstant.constant = 0
                    }
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    func getCourses() {
        if let login = UserDefaults.standard.dictionary(forKey: "login") as? [String:Any] {
            let program_id = login["program_id"] as! String
            let url = "https://apidockerpython.azurewebsites.net//api/subject/select"
            let param : [String:Any] = [
                "program_id" : program_id
            ]
            let jsonData = try! JSONSerialization.data(withJSONObject: param)
            var request = URLRequest.init(url: URL.init(string: url)!)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            request.headers = HTTPHeaders.init([HTTPHeader.init(name: "Content-Type", value: "application/json")])
            AF.request(request).responseJSON { [self] result in
                if let value = result.value as? [String:Any] {
                    courseArr = value["data"] as! [[String:Any]]
                    tempCourseArr = courseArr
                    self.collectionView.reloadData()
                    collectionViewHeightConstant.constant = (CGFloat(courseArr.count * (72 + 16))) + 34.0
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    func getRecommendedCourses() {
        DispatchQueue.global(qos: .background).async {
            if let login = UserDefaults.standard.dictionary(forKey: "login") as? [String:Any] {
                let program_id = login["program_id"] as! String
                let intent = login["intent"] as! String
                let url = "https://apidockerpython.azurewebsites.net/api/student-course/prediction"
                let param : [String:Any] = [
                    "intent" : intent,
                    "program_id" : program_id
                ]
                let jsonData = try! JSONSerialization.data(withJSONObject: param)
                var request = URLRequest.init(url: URL.init(string: url)!)
                request.httpMethod = "POST"
                request.httpBody = jsonData
                request.headers = HTTPHeaders.init([HTTPHeader.init(name: "Content-Type", value: "application/json")])
                AF.request(request).responseJSON { [self] result in
                    if let value = result.value as? [String:Any] {
                        if let rec = value["data"] as? [[String:Any]] {
                            recommendedCourseArr = rec
                        }
                    }
                }
            }
        }
    }
    
    //MARK: Tableview delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: 50))
        headerView.backgroundColor = .clear
        let label = UILabel()
        label.backgroundColor = .clear
        label.frame = CGRect.init(x: 16, y: 0, width: headerView.frame.width - 32, height: 50)
        label.text = "Current Registrations"
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .black
        headerView.addSubview(label)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentCourseArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "currentCourseCell", for: indexPath) as! TableViewCell
        let parti = currentCourseArr[indexPath.row]
        cell.courseName.text = parti["course_name"] as! String
        cell.courseTerm.text = parti["term"] as! String
        return cell
    }
    
    //MARK: Collectionview delegates
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let cell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "section", for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return courseArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: self.view.frame.width - 32, height: 72)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "courseCell", for: indexPath) as! CollectionViewCell
        let parti = courseArr[indexPath.row]
        cell.courseName.text = parti["course_name"] as! String
        cell.courseTerm.text = parti["term"] as! String
        cell.courseEnrollBtn.tag = indexPath.row
        cell.courseEnrollBtn.addTarget(self, action: #selector(enrollAction), for: .touchUpInside)
        return cell
    }
    
    @objc func enrollAction(sender:UIButton) {
        let alert = UIAlertController.init(title: "Are you sure?", message: "Confirm to register this course", preferredStyle: .alert)
        let ac = UIAlertAction.init(title: "Cancel", style: .cancel)
        ac.setValue(UIColor.darkGray, forKey: "titleTextColor")
        alert.addAction(ac)
        let av = UIAlertAction.init(title: "Confirm", style: .default) { confirmAction in
            let parti = self.courseArr[sender.tag]
            let term = parti["term"] as! String
            let registered_course = parti["course_name"] as! String
            let currentRegCourse = self.currentCourseArr.filter { dict in
                let cName = dict["course_name"] as! String
                let cTerm = dict["term"] as! String
                if cName == registered_course && cTerm == term {
                    return true
                }
                return false
            }
            if currentRegCourse.count > 0 {
                self.view.makeToast("You have already registered this course")
            }
            else {
                if let login = UserDefaults.standard.dictionary(forKey: "login") as? [String:Any] {
                    let id = login["id"] as! String
                    let firstname = login["firstname"] as! String
                    let lastname = login["lastname"] as! String
                    let name = "\(firstname) \(lastname)"
                    let url = "https://apidockerpython.azurewebsites.net//api/student-course/registration"
                    let param : [String:Any] = [
                        "student_id" : id,
                        "student_name": name,
                        "term" : term,
                        "registered_course":registered_course
                    ]
                    let jsonData = try! JSONSerialization.data(withJSONObject: param)
                    var request = URLRequest.init(url: URL.init(string: url)!)
                    request.httpMethod = "POST"
                    request.httpBody = jsonData
                    request.headers = HTTPHeaders.init([HTTPHeader.init(name: "Content-Type", value: "application/json")])
                    AF.request(request).responseJSON { [self] result in
                        if let value = result.value as? [String:Any] {
                            if let status_code = value["status"] as? Int {
                                if status_code == 1 {
                                    self.view.makeToast("\(registered_course) registered successfully!")
                                    getCurrentCourses()
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
                            self.view.makeToast("Something went wrong!")
                        }
                    }
                }
            }
        }
        av.setValue(UIColor.black, forKey: "titleTextColor")
        alert.addAction(av)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
