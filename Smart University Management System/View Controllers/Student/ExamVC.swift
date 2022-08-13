//
//  ExamVC.swift
//  Smart University Management System
//
//  Created by Kamal Trapasiya on 2022-04-30.
//

import UIKit
import Alamofire

class ExamVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var courseLbl: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var courseName = String()
    var examArr = [[String:Any]]()
    var partiExam = [String:Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        courseLbl.text = courseName
        getExams()
        NotificationCenter.default.addObserver(self, selector: #selector(examCompleted), name: NSNotification.Name.init("examComplete"), object: nil)
    }
    
    @objc func examCompleted() {
        //Refresh data
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
        headerView.refreshExamBtn.addTarget(self, action: #selector(refreshExams), for: .touchUpInside)
        return headerView
    }
    
    @objc func refreshExams() {
        examArr.removeAll()
        collectionView.reloadData()
        getExams()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "examCell", for: indexPath) as! CollectionViewCell
        
        let parti = examArr[indexPath.row]
        cell.examName.text = parti["exam_name"] as! String
        
        let startDate = parti["start_date"] as! String
        let endDate = parti["end_date"] as! String
        cell.examDate.text = "\(startDate) - \(endDate)"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        let start = dateFormatter.date(from: startDate)!
        let end = dateFormatter.date(from: endDate)!
        let current = Date()
        if current > start && current < end {
            cell.examDisableView.isHidden = true
        }
        else {
            cell.examDisableView.isHidden = false
        }
        
        let totalMarkDict = convertToDictionary(text: parti["total_marks"] as! String)!
        let profID = parti["professor_id"] as! String
        let arr = totalMarkDict[profID] as! [[String:Any]]
        let dict = arr[0]
        cell.examTotalMark.text = dict["total_marks"] as! String
        
        cell.examDuration.text = "\(parti["duration"] as! String) Minutes"
        
        if let login = UserDefaults.standard.dictionary(forKey: "login") as? [String:Any] {
            
            let id = login["id"] as! String
            if let mark = totalMarkDict[id] as? [[String:Any]] {
                //Exam completed
                cell.examResultView.isHidden = false
                cell.examYourScoreLbl.isHidden = false
                cell.examResultScore.text = mark[0]["total_marks"] as! String
                cell.examDisableView.isHidden = true
            }
            else {
                cell.examResultView.isHidden = true
                cell.examYourScoreLbl.isHidden = true
            }
        }
        else {
            cell.examResultView.isHidden = true
            cell.examYourScoreLbl.isHidden = true
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let parti = examArr[indexPath.row]
        if let login = UserDefaults.standard.dictionary(forKey: "login") as? [String:Any] {
            let id = login["id"] as! String
            let totalMarkDict = convertToDictionary(text: parti["total_marks"] as! String)!
            if let mark = totalMarkDict[id] as? [[String:Any]] {
                //Exam completed
                //Do nothing
            }
            else {
                //Exam pending
                partiExam = parti
                let startDate = parti["start_date"] as! String
                let endDate = parti["end_date"] as! String
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
                let start = dateFormatter.date(from: startDate)!
                let end = dateFormatter.date(from: endDate)!
                let current = Date()
                if current > start && current < end {
                    self.performSegue(withIdentifier: "examSegue", sender: nil)
                }
            }
        }
        else {
            //Exam pending
            partiExam = parti
            let startDate = parti["start_date"] as! String
            let endDate = parti["end_date"] as! String
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
            let start = dateFormatter.date(from: startDate)!
            let end = dateFormatter.date(from: endDate)!
            let current = Date()
            if current > start && current < end {
                self.performSegue(withIdentifier: "examSegue", sender: nil)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "examSegue" {
            let vc = segue.destination as! LiveExamVC
            vc.partiExam = partiExam
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
