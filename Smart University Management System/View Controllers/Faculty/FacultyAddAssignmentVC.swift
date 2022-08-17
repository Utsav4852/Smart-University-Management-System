//
//  FacultyAddAssignmentVC.swift
//  Smart University Management System
//
//  Created by Kamal Trapasiya on 2022-07-06.
//

import UIKit
import UITextView_Placeholder
import SkyFloatingLabelTextField
import MobileCoreServices
import PDFKit
import WebKit

class FacultyAddAssignmentVC: UIViewController, UITextFieldDelegate, UIDocumentPickerDelegate {

    @IBOutlet weak var answerTxtView: UITextView!
    @IBOutlet weak var questionTxtField: SkyFloatingLabelTextField!
    @IBOutlet weak var markTxtField: UITextField!
    @IBOutlet weak var webPreview: WKWebView!
    @IBOutlet weak var webViewHeightConstant: NSLayoutConstraint!
    
    let MAX_LENGTH_PHONENUMBER = 3
    let ACCEPTABLE_NUMBERS     = "0123456789"
    var selectedFile = URL.init(string: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webViewHeightConstant.constant = 0
        self.view.layoutIfNeeded()
    }
    
    @IBAction func addAction(_ sender: Any) {
        if selectedFile == nil {
            questionTxtField.errorMessage = "Question"
        }
        else if markTxtField.text!.count == 0 || markTxtField.text!.trimmingCharacters(in: .whitespaces).isEmpty {
            self.view.makeToast("Please enter total marks for this question")
        }
        else {
            self.dismiss(animated: true)
        }
    }
    
    @IBAction func selectFileBtn(_ sender: Any) {
        let documentPicker = UIDocumentPickerViewController(documentTypes: [String(kUTTypePDF)], in: .import)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        self.present(documentPicker, animated: true)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let url = urls.first {
            selectedFile = url
            webPreview.loadFileURL(url, allowingReadAccessTo: url)
            let request = URLRequest(url: url)
            webPreview.load(request)
            webViewHeightConstant.constant = 350
            self.view.layoutIfNeeded()
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
