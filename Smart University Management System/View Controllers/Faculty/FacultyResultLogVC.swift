//
//  FacultyResultLog.swift
//  Smart University Management System
//
//  Created by Kamal Trapasiya on 2022-07-27.
//

import UIKit
import Optik
import Alamofire

class FacultyResultLogVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logLbl: UILabel!
    
    var resultDict = [String:Any]()
    var logArr = [[String:Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getLogs()
        designInit()
        
        let name = resultDict["name"] as! String
        logLbl.text = "Log (\(name))"
    }
    
    func designInit() {
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 40
        tableView.separatorInset = UIEdgeInsets.init(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    func getLogs() {
        if let logs = resultDict["log"] as? [[String:Any]] {
            logArr = logs
            self.tableView.reloadData()
        }
    }
    
    //MARK: Tableview delegatess
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "logCell", for: indexPath) as! TableViewCell
        
        let parti = logArr[indexPath.row]
        cell.logTimeLbl.text = parti["time"] as! String
        
        let status = parti["is_cheating"] as! String
        if status == "true" {
            //true
            cell.logStatusLbl.text = "Suspicious"
            cell.logStatusLbl.textColor = .systemRed
        }
        else {
            cell.logStatusLbl.text = "Match"
            cell.logStatusLbl.textColor = .systemGreen
        }
        
        cell.logViewBtn.tag = indexPath.row
        cell.logViewBtn.addTarget(self, action: #selector(viewImageAction(_:)), for: .touchUpInside)
        
        return cell
    }
    
    @objc func viewImageAction(_ sender: UIButton) {
        let parti = logArr[sender.tag]
        let url = parti["url"] as! String
        
        //let imgView = UIImageView()
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: URL.init(string: url)!) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        let imageViewer = Optik.imageViewer(
                            withImages: [
                                image
                            ]
                        )
                        self!.present(imageViewer, animated: true, completion: nil)
                    }
                }
            }
        }
//        imgView.sd_setImage(with: URL.init(string: url)) { img, error, cache, url in
//            self.dismissLoader()
//            if error == nil {
//                let imageViewer = Optik.imageViewer(
//                    withImages: [
//                        img!
//                    ]
//                )
//                self.present(imageViewer, animated: true, completion: nil)
//            }
//
//        }
        
        
        
    }
    
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
