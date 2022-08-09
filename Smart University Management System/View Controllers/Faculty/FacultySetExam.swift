//
//  FacultySetExam.swift
//  Smart University Management System
//
//  Created by Kamal Trapasiya on 2022-06-09.
//

import UIKit
import SkyFloatingLabelTextField
import DateTimePicker
import Alamofire

class FacultySetExam: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var examName: SkyFloatingLabelTextField!
    
    @IBOutlet weak var startDateBtn: UIButton!
    @IBOutlet weak var endDateBtn: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var heightConstant: NSLayoutConstraint!
    @IBOutlet weak var tableMainView: UIView!
    @IBOutlet weak var tableViewHeightConstant: NSLayoutConstraint!
    
    var questionAnswerArr = [[String:Any]]()
    
    @IBOutlet weak var totalMarksLbl: UILabel!
    
    var startDate: Date? = nil
    var endDate: Date? = nil
    
    var tableViewHeight: CGFloat {
        tableView.layoutIfNeeded()
        return tableView.contentSize.height
    }
    
    var courseName = String()
    var totalMark = 0
    
    @IBOutlet weak var durationTxtField: UITextField!
    
    let MAX_LENGTH_PHONENUMBER = 3
    let ACCEPTABLE_NUMBERS = "0123456789"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewHeightConstant.constant = 0
        self.view.layoutIfNeeded()
        
        tableView.separatorInset = UIEdgeInsets.init(top: 0, left: 16, bottom: 0, right: 16)
        tableView.tableFooterView = UIView()
        tableView.reloadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(getQuestion(noti:)), name: NSNotification.Name.init(rawValue: "question"), object: nil)
    }
    
    @objc func getQuestion(noti: Notification) {
        let dict = noti.userInfo as! [String:Any]
        questionAnswerArr.append(dict)
        tableView.reloadData()
        self.tableView.performBatchUpdates(nil) { complete in
            self.tableViewHeightConstant.constant = self.tableViewHeight
            self.view.layoutIfNeeded()
            
            let arr = self.questionAnswerArr.map { Int($0["mark"]! as! String)! }
            self.totalMark = arr.reduce(0, +)
            self.totalMarksLbl.text = "\(self.totalMark)"
        }
    }
    
    @IBAction func addQuestionAction(_ sender: Any) {
        self.performSegue(withIdentifier: "addSegue", sender: nil)
    }
    
    //MARK: Tableview delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questionAnswerArr.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        
        let parti = questionAnswerArr[indexPath.row]
        
        cell.questionLbl.text = "\(indexPath.row + 1). \(parti["question"] as! String)"
        cell.answerLbl.text = parti["answer"] as! String
        cell.markLbl.text = parti["mark"] as! String
        
        return cell
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newLength: Int = textField.text!.count + string.count - range.length
        let numberOnly = NSCharacterSet.init(charactersIn: ACCEPTABLE_NUMBERS).inverted
        let strValid = string.rangeOfCharacter(from: numberOnly) == nil
        return (strValid && (newLength <= MAX_LENGTH_PHONENUMBER))
    }
    
    @IBAction func startDateAction(_ sender: Any) {
        let min = Date()
        let max = Date().addingTimeInterval(60 * 60 * 24 * 120)
        let picker = DateTimePicker.create(minimumDate: min, maximumDate: max)
        picker.highlightColor = UIColor(named: "Color")!
        picker.doneBackgroundColor = UIColor(named: "Color")
        
        picker.completionHandler = { date in
            
            self.startDate = date
            
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy hh:mm a"
            self.startDateBtn.setTitle(formatter.string(from: date), for: .normal)
        }
        picker.show()
    }
    
    @IBAction func endDateAction(_ sender: Any) {
        let min = Date()
        let max = Date().addingTimeInterval(60 * 60 * 24 * 120)
        let picker = DateTimePicker.create(minimumDate: min, maximumDate: max)
        picker.highlightColor = UIColor(named: "Color")!
        picker.doneBackgroundColor = UIColor(named: "Color")
        
        picker.completionHandler = { date in
            
            self.endDate = date
            
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy hh:mm a"
            self.endDateBtn.setTitle(formatter.string(from: date), for: .normal)
        }
        picker.show()
    }
    
    @IBAction func submitAction(_ sender: Any) {
        if !examName.isValidate() {
            examName.errorMessage = "Exam Name"
        }
        else if startDate == nil {
            self.view.makeToast("Please select start date")
        }
        else if endDate == nil {
            self.view.makeToast("Please select end date")
        }
        else if startDate! > endDate! {
            self.view.makeToast("End date should not be less than start date")
        }
        else if !durationTxtField.isValidate() {
            self.view.makeToast("Enter the exam duration")
        }
        else if questionAnswerArr.count == 0 {
            self.view.makeToast("Please add questions")
        }
        else {
            
            if let login = UserDefaults.standard.dictionary(forKey: "login") as? [String:Any] {
                
                let id = login["id"] as! String
                let firstName = login["firstname"] as! String
                let lastName = login["lastname"] as! String
                let name = "\(firstName) \(lastName)"
                
                let url = "https://coursepred.azurewebsites.net/api/exam/insert"
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
                let start = dateFormatter.string(from: startDate!)
                let end = dateFormatter.string(from: endDate!)
                
                let questionDict = ["\(id)": questionAnswerArr]
                
                let data = try! JSONSerialization.data(withJSONObject: questionDict, options: .withoutEscapingSlashes)
                let questionStr = String(data: data, encoding: String.Encoding.utf8)
                
                let totalMarkDict = [id: "\(totalMark)"]
                let totalMarkData = try! JSONSerialization.data(withJSONObject: totalMarkDict, options: .withoutEscapingSlashes)
                let totalMarkStr = String(data: totalMarkData, encoding: String.Encoding.utf8)
                
                let param : [String:Any] = [
                    "exam_id" : UUID().uuidString,
                    "exam_name"  : examName.text!,
                    "professor_id" : id,
                    "professor_name"  : name,
                    "que_ans" : questionStr!,
                    "start_date" : start,
                    "end_date" : end,
                    "course_name" : courseName,
                    "total_marks" : totalMarkStr,
                    "duration": durationTxtField.text!
                ]
                
                let jsonData = try! JSONSerialization.data(withJSONObject: param)
                
                var request = URLRequest.init(url: URL.init(string: url)!)
                request.httpMethod = "POST"
                request.httpBody = jsonData
                request.headers = HTTPHeaders.init([HTTPHeader.init(name: "Content-Type", value: "application/json")])
                
                AF.request(request).responseJSON { [self] result in
                    if let value = result.value as? [String:Any] {
                        if let status = value["status"] as? Int {
                            if status == 1 {
                                //Success
                                self.dismiss(animated: true) {
                                    NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "submit"), object: nil)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
}
