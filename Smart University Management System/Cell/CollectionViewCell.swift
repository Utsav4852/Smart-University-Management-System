//
//  CollectionViewCell.swift
//  Smart University Management System
//
//  Created by Kamal Trapasiya on 2022-03-10.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var studentName: UILabel!
    @IBOutlet weak var studentID: UILabel!
    @IBOutlet weak var studentEmail: UILabel!
    @IBOutlet weak var studentProfile: UIImageView!
    
    @IBOutlet weak var faceTrainImgView: UIImageView!
    
    @IBOutlet weak var adminHomeCategoryImgView: UIImageView!
    @IBOutlet weak var adminHomeCategoryName: UILabel!
    
    @IBOutlet weak var categoryImgView: UIImageView!
    @IBOutlet weak var categoryName: UILabel!
    
    @IBOutlet weak var courseProfessorName: UILabel!
    @IBOutlet weak var courseName: UILabel!
    @IBOutlet weak var courseEnrollBtn: UIButton!
    @IBOutlet weak var courseTerm: UILabel!
    
    @IBOutlet weak var bookImgView: UIImageView!
    @IBOutlet weak var bookName: UILabel!
    @IBOutlet weak var bookDesc: UILabel!
    
    @IBOutlet weak var examName: UILabel!
    @IBOutlet weak var examDate: UILabel!
    @IBOutlet weak var examTotalMark: UILabel!
    @IBOutlet weak var examDisableView: UIView!
    @IBOutlet weak var examDuration: UILabel!
    @IBOutlet weak var examResultView: UIView!
    @IBOutlet weak var examResultScore: UILabel!
    @IBOutlet weak var examYourScoreLbl: UILabel!
    @IBOutlet weak var examViewBtn: UIButton!
    
    
    
}
