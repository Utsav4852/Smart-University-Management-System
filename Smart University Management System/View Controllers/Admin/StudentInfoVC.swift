//
//  StudentInfoVC.swift
//  Smart University Management System
//
//  Created by Kamal Trapasiya on 2022-03-10.
//

import UIKit

class StudentInfoVC: UIViewController {
    
    @IBOutlet weak var titleLbl: UILabel!
    var studentDict = [String:Any]()
    
    @IBOutlet weak var studentIDLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var contactLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var courseLbl: UILabel!
    @IBOutlet weak var admissionTermLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        printInfo()
    }
    
    func printInfo() {
        let firstName = studentDict["firstname"] as! String
        let lastName = studentDict["lastname"] as! String
        let email = studentDict["email"] as! String
        let country_code = studentDict["country_code"] as! String
        let contact = studentDict["contact_no"] as! String
        let address = studentDict["address"] as! String
        let city = studentDict["city"] as! String
        let province = studentDict["province"] as! String
        let country = studentDict["country"] as! String
        let postal = studentDict["postalcode"] as! String
        let profile_pic = studentDict["profile_pic"] as! String
        let profile = studentDict["profile_pic"] as! String
        let course = studentDict["course"] as! String
        let admission_term = studentDict["admission_term"] as! String
        profileImgView.sd_setImage(with: URL.init(string: profile), placeholderImage: UIImage.init(named: "user_big"), options: .refreshCached, completed: nil)
        
        let name = "\(firstName) \(lastName)"
        nameLbl.text = name
        titleLbl.text = name
        emailLbl.text = email
        contactLbl.text = "\(country_code) \(contact)"
        addressLbl.text = "\(address), \(city), \(province), \(country), \(postal)"
        courseLbl.text = course
        admissionTermLbl.text = admission_term
    }
    
    @IBAction func closeAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    

}
