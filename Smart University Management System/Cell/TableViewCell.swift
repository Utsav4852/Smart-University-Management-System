//
//  TableViewCell.swift
//  Smart University Management System
//
//  Created by Kamal Trapasiya on 2022-03-23.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var courseName: UILabel!
    @IBOutlet weak var courseTerm: UILabel!
    
    @IBOutlet weak var questionLbl: UILabel!
    @IBOutlet weak var answerLbl: UILabel!
    @IBOutlet weak var markLbl: UILabel!
    
    @IBOutlet weak var resultStudentId: UILabel!
    @IBOutlet weak var resultStudentName: UILabel!
    @IBOutlet weak var resultStudentMark: UILabel!
    
    @IBOutlet weak var answerTxtView: UITextView!
    
    @IBOutlet weak var logTimeLbl: UILabel!
    @IBOutlet weak var logStatusLbl: UILabel!
    @IBOutlet weak var logViewBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
