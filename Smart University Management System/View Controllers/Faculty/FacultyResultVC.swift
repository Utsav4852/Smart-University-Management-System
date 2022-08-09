//
//  FacultyResultVC.swift
//  Smart University Management System
//
//  Created by Kamal Trapasiya on 2022-07-04.
//

import UIKit

class FacultyResultVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var examNameLbl: UILabel!
    var examName = String()
    
    @IBOutlet weak var tableView: UITableView!
    
    var resultDict = [String:Any]()
    var totalMark = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        examNameLbl.text = examName
        
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 50
        tableView.separatorInset = UIEdgeInsets.init(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultDict.keys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath) as! TableViewCell
        
        let parti = Array(resultDict.keys)[indexPath.row]
        let arr = resultDict[parti] as! [[String:Any]]
        let dict = arr[0]
        cell.resultStudentId.text = dict["id"] as! String
        cell.resultStudentName.text = dict["name"] as! String
        
        let mark = Int(dict["total_marks"] as! String)!
        
        let score = (mark * 100) / totalMark
        if score > 59 {
            cell.resultStudentMark.textColor = .systemGreen
        }
        else if score > 49 && score < 60 {
            cell.resultStudentMark.textColor = .systemOrange
        }
        else {
            cell.resultStudentMark.textColor = .systemRed
        }
        
        cell.resultStudentMark.text = String(mark)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "logSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "logSegue" {
            let vc = segue.destination as! FacultyResultLogVC
            let str = Array(resultDict.keys)[0]
            let av = resultDict[str] as! [[String:Any]]
            let dict = av[0]
            vc.resultDict = dict
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
