//
//  FacultyAttendanceVC.swift
//  Smart University Management System
//
//  Created by Kamal Trapasiya on 2022-06-08.
//

import UIKit
import ScrollableDatepicker
import Alamofire

class FacultyAttendanceVC: UIViewController, ScrollableDatepickerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var courseName = String()
    var attendanceArr = [[String:Any]]()
    var attendancePerArr = [[String:Any]]()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var noAttendanceLbl: UILabel!
    
    func datepicker(_ datepicker: ScrollableDatepicker, didSelectDate date: Date) {
        attendanceArr = attendancePerArr.filter({ dict in
            if let datesStr = dict["attendance"] as? String {
                let arr = datesStr.split(separator: ",")
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/yyyy"
                let str = dateFormatter.string(from: date)
                
                if arr.contains(Substring(str)) {
                    return true
                }
            }
            return false
        })
        
        if attendanceArr.count > 0 {
            self.collectionView.isHidden = false
            self.noAttendanceLbl.isHidden = true
        }
        else {
            self.collectionView.isHidden = true
            self.noAttendanceLbl.isHidden = false
        }
        self.collectionView.reloadData()
    }
    
    @IBOutlet weak var datePicker: ScrollableDatepicker! {
        didSet {
            
            var startDate = getSeasonStartDate()
            var dates = [Date]()
            let endDate = Date()
            
            while startDate.compare(endDate) != .orderedDescending {
                dates.append(startDate)
                startDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
            }
            
            datePicker.dates = dates
            datePicker.selectedDate = Date()
            datePicker.delegate = self
            
            var configuration = Configuration()
            
            // weekend customization
            configuration.weekendDayStyle.dateTextColor = UIColor.init(named: "Color")
            configuration.weekendDayStyle.dateTextFont = UIFont.boldSystemFont(ofSize: 20)
            configuration.weekendDayStyle.weekDayTextColor = UIColor.init(named: "Color")
            
            // selected date customization
            configuration.selectedDayStyle.backgroundColor = UIColor(white: 0.9, alpha: 1)
            configuration.selectedDayStyle.selectorColor = UIColor.init(named: "Color")
            configuration.daySizeCalculation = .numberOfVisibleItems(5)
            
            datePicker.configuration = configuration
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.isHidden = true
        noAttendanceLbl.isHidden = true
        getAttendance()
        
    }
    
    //MARK: Collectionview delegates
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return attendanceArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! CollectionReusableView

        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "attendanceCell", for: indexPath) as! CollectionViewCell
        
        let parti = attendanceArr[indexPath.row]
        
        cell.studentID.text = parti["student_id"] as! String
        cell.studentName.text = parti["student_name"] as! String
        
        return cell
    }
    
    func getAttendance() {
        let url = "https://coursepred.azurewebsites.net/api/prof/get_attendence_list"
        
        let param : [String:Any] = [
            "registered_course" : courseName
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: param)

        var request = URLRequest.init(url: URL.init(string: url)!)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.headers = HTTPHeaders.init([HTTPHeader.init(name: "Content-Type", value: "application/json")])
        
        AF.request(request).responseJSON { [self] result in
            
            if let value = result.value as? [String:Any] {
                if let data = value["data"] as? [[String:Any]] {
                    attendanceArr = data
                    attendancePerArr = attendanceArr
                    
                    attendanceArr = attendancePerArr.filter({ dict in
                        if let datesStr = dict["attendance"] as? String {
                            let arr = datesStr.split(separator: ",")
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "dd/MM/yyyy"
                            let str = dateFormatter.string(from: Date())
                            
                            if arr.contains(Substring(str)) {
                                return true
                            }
                        }
                        return false
                    })
                    
                    if attendanceArr.count > 0 {
                        self.collectionView.isHidden = false
                        self.noAttendanceLbl.isHidden = true
                    }
                    else {
                        self.collectionView.isHidden = true
                        self.noAttendanceLbl.isHidden = false
                    }
                    
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
