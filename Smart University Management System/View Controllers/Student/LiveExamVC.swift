//
//  LiveExamVC.swift
//  Smart University Management System
//
//  Created by Kamal Trapasiya on 2022-06-10.
//

import UIKit
import MagicTimer
import Alamofire
import Photos
import CameraManager

class LiveExamVC: UIViewController, MagicTimerViewDelegate, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var magicTimer: MagicTimerView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstant: NSLayoutConstraint!
    @IBOutlet weak var titleLbl: UILabel!
    
    var partiExam = [String:Any]()
    var questionArr = [[String:Any]]()
    var tableViewHeight: CGFloat {
        tableView.layoutIfNeeded()
        return tableView.contentSize.height
    }
    var timer = Timer()
    var cheatingTimer = Timer()
    let cameraManager = CameraManager()
    var cameraView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableViewHeightConstant.constant = 0
        self.view.layoutIfNeeded()
        let duration = Int(partiExam["duration"] as! String)
        magicTimer.isActiveInBackground = false
        magicTimer.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        magicTimer.textColor = UIColor.init(named: "Color")
        magicTimer.mode = .countDown(fromSeconds: TimeInterval.init(duration! * 60))
        magicTimer.delegate = self
        magicTimer.startCounting()
        titleLbl.text = partiExam["exam_name"] as! String
        tableView.separatorInset = UIEdgeInsets.init(top: 0, left: 16, bottom: 0, right: 16)
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableView.automaticDimension
        let queStr = partiExam["que_ans"] as! String
        let prof_id = partiExam["professor_id"] as! String
        let dict = convertToDictionary(text: queStr)!
        questionArr = dict[prof_id] as! [[String:Any]]
        tableView.reloadData()
        setupCameraView()
        cheatingTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { time in
            if(arc4random() % 10 == 1)
            {
                self.catchCheating()
            }
        }
    }
    
    func setupCameraView() {
        cameraView.layer.cornerRadius = (self.view.frame.width - 100)/2
        cameraManager.cameraDevice = .front
        cameraManager.cameraOutputMode = .stillImage
        cameraManager.focusMode = .continuousAutoFocus
        cameraManager.addPreviewLayerToView(self.cameraView)
    }
    
    func catchCheating() {
        if let login = UserDefaults.standard.dictionary(forKey: "login") as? [String:Any] {
            let id = login["id"] as! String
            timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { (time) in
                AudioServicesDisposeSystemSoundID(1108)
            })
            cameraManager.capturePictureWithCompletion { result in
                self.timer.invalidate()
                switch result {
                case .failure: break
                    // error handling
                    print("Error")
                case .success(let content):
                    let img = content.asImage!
                    let resize = resizeImage(image: img, targetSize: CGSize.init(width: 512, height: 512))
                    let url = "https://apidockerpython.azurewebsites.net/api/examine/student"
                    let date = Date()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd-MM-yyyy hh:mm:ss a"
                    let dateStr = dateFormatter.string(from: date)
                    let param = [
                        "student_id" : id,
                        "exam_id": self.partiExam["exam_id"] as! String,
                        "img": resize.jpegData(compressionQuality: 0.5)!.base64EncodedString(),
                        "time": dateStr,
                        "img_name": Date().timeIntervalSince1970.description
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
                                    //success
                                }
                            }
                        }
                    }
                }
            }
        }
    }
     
    override func viewDidLayoutSubviews() {
        self.tableView.performBatchUpdates(nil) { complete in
            self.tableViewHeightConstant.constant = self.tableViewHeight
            self.view.layoutIfNeeded()
        }
    }
    
    //MARK: Tableview delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questionArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "questionCell", for: indexPath) as! TableViewCell
        cell.answerTxtView.textContainerInset = UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10)
        let parti = questionArr[indexPath.row]
        let que = parti["question"] as! String
        let mark = parti["mark"] as! String
        cell.questionLbl.text = "\(indexPath.row + 1). \(que) (\(mark) Marks)"
        return cell
    }
        
    func timerElapsedTimeDidChange(timer: MagicTimerView, elapsedTime: TimeInterval) {
        if elapsedTime == 0.0 {
            //Submit
            submitExam()
        }
    }
    
    @IBAction func submitAction(_ sender: Any) {
        submitExam()
    }
    
    func submitExam() {
        cheatingTimer.invalidate()
        self.showLoader()
        magicTimer.stopCounting()
        if let login = UserDefaults.standard.dictionary(forKey: "login") as? [String:Any] {
            for i in 0..<questionArr.count {
                let cell = tableView.cellForRow(at: IndexPath.init(row: i, section: 0)) as! TableViewCell
                let ans = cell.answerTxtView.text!
                questionArr[i]["answer"] = ans
            }
            let data = try! JSONSerialization.data(withJSONObject: questionArr, options: .withoutEscapingSlashes)
            let questionStr = String(data: data, encoding: String.Encoding.utf8)
            let id = login["id"] as! String
            let url = "https://coursepred.azurewebsites.net/api/exam/student_exam_update"
            let param = [
                "student_id" : id,
                "exam_id": partiExam["exam_id"] as! String,
                "student_ans": questionStr,
                "professor_id": partiExam["professor_id"] as! String
            ]
            let jsonData = try! JSONSerialization.data(withJSONObject: param)
            var request = URLRequest.init(url: URL.init(string: url)!)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            request.headers = HTTPHeaders.init([HTTPHeader.init(name: "Content-Type", value: "application/json")])
            AF.request(request).responseJSON { [self] result in
                self.dismissLoader()
                if let value = result.value as? [String:Any] {
                    if let status = value["status"] as? Int {
                        if status == 1 {
                            //success
                            self.navigationController?.popViewController(animated: false)
                            NotificationCenter.default.post(name: NSNotification.Name.init("examComplete"), object: nil)
                        }
                    }
                }
                else {
                    self.view.makeToast("Something went wrong!")
                }
            }
        }
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}
