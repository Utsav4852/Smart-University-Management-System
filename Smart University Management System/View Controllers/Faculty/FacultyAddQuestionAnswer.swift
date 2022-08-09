//
//  FacultyAddQuestionAnswer.swift
//  Smart University Management System
//
//  Created by Kamal Trapasiya on 2022-06-10.
//

import UIKit
import UITextView_Placeholder
import SkyFloatingLabelTextField

class FacultyAddQuestionAnswer: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var answerTxtView: UITextView!
    @IBOutlet weak var questionTxtField: SkyFloatingLabelTextField!
    let MAX_LENGTH_PHONENUMBER = 3
    let ACCEPTABLE_NUMBERS     = "0123456789"
    @IBOutlet weak var markTxtField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        answerTxtView.placeholder = "Enter Answer"
        answerTxtView.placeholderColor = UIColor.lightGray
        answerTxtView.textContainerInset = UIEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    @IBAction func addAction(_ sender: Any) {
        if !questionTxtField.isValidate() {
            questionTxtField.errorMessage = "Question"
        }
        else if answerTxtView.text.count == 0 || answerTxtView.text.trimmingCharacters(in: .whitespaces).isEmpty {
            self.view.makeToast("Please write an answer")
        }
        else if markTxtField.text!.count == 0 || markTxtField.text!.trimmingCharacters(in: .whitespaces).isEmpty {
            self.view.makeToast("Please enter total marks for this question")
        }
        else {
            let dict = ["question": questionTxtField.text!, "answer": answerTxtView.text!, "mark": markTxtField.text!]
            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "question"), object: nil, userInfo: dict)
            self.dismiss(animated: true)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newLength: Int = textField.text!.count + string.count - range.length
        let numberOnly = NSCharacterSet.init(charactersIn: ACCEPTABLE_NUMBERS).inverted
        let strValid = string.rangeOfCharacter(from: numberOnly) == nil
        return (strValid && (newLength <= MAX_LENGTH_PHONENUMBER))
    }
    
    
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
