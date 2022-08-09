//
//  FacultyExamVC.swift
//  Smart University Management System
//
//  Created by Kamal Trapasiya on 2022-06-09.
//

import UIKit
import Alamofire

class FacultyExamVC: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    var courseName = String()
    @IBOutlet weak var courseLbl: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var examArr = [[String:Any]]()
    
    var examName = String()
    var resultDict = [String:Any]()
    var totalMark = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadExams), name: NSNotification.Name.init(rawValue: "submit"), object: nil)
        
        courseLbl.text = courseName
        getExams()
    }
    
    @objc func loadExams() {
        getExams()
    }
    
    func getExams() {
        
        let url = "https://coursepred.azurewebsites.net/api/exam/select"

        let param : [String:Any] = [
            "course_name" : courseName
        ]

        let jsonData = try! JSONSerialization.data(withJSONObject: param)

        var request = URLRequest.init(url: URL.init(string: url)!)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.headers = HTTPHeaders.init([HTTPHeader.init(name: "Content-Type", value: "application/json")])

        AF.request(request).responseJSON { [self] result in
            if let value = result.value as? [String:Any] {
                if let arr = value["data"] as? [[String:Any]] {
                    examArr = arr
                    collectionView.reloadData()
                }
            }
        }
        
    }
    
    //MARK: collectionview delegates
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return examArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerView", for: indexPath) as! CollectionReusableView
        
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "examCell", for: indexPath) as! CollectionViewCell
        
        let parti = examArr[indexPath.row]
        cell.examName.text = parti["exam_name"] as! String
        
        let startDate = parti["start_date"] as! String
        let endDate = parti["end_date"] as! String
        cell.examDate.text = "\(startDate) - \(endDate)"
        
        let totalMarkDict = convertToDictionary(text: parti["total_marks"] as! String)!
        let profID = parti["professor_id"] as! String
        let arr = totalMarkDict[profID] as! [[String:Any]]
        let dict = arr[0]
        cell.examTotalMark.text = dict["total_marks"] as! String
        
        cell.examDuration.text = "\(parti["duration"] as! String) Minutes"
        
        cell.examViewBtn.tag = indexPath.row
        cell.examViewBtn.addTarget(self, action: #selector(viewResultAction(_:)), for: .touchUpInside)
        return cell
    }
    
    @objc func viewResultAction(_ sender:UIButton) {
        let parti = examArr[sender.tag]
        examName = parti["exam_name"] as! String
        
        var totalMarkDict = convertToDictionary(text: parti["total_marks"] as! String)!
        let profID = parti["professor_id"] as! String
        let arr = totalMarkDict[profID] as! [[String:Any]]
        let dict = arr[0]
        totalMark = Int(dict["total_marks"] as! String)!
        
        totalMarkDict.removeValue(forKey: profID)
        resultDict = totalMarkDict
        
        if resultDict.isEmpty {
            self.view.makeToast("No data found!")
        }
        else {
            self.performSegue(withIdentifier: "resultSegue", sender: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "setExamSegue" {
            let vc = segue.destination as! FacultySetExam
            vc.courseName = courseName
        }
        else if segue.identifier == "resultSegue" {
            let vc = segue.destination as! FacultyResultVC
            vc.examName = examName
            vc.resultDict = resultDict
            vc.totalMark = totalMark
        }
    }
    
    @IBAction func addAction(_ sender: Any) {
        self.performSegue(withIdentifier: "setExamSegue", sender: nil)
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
