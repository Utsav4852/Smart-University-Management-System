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
    let MAX_LENGTH_PHONENUMBER = 3
    let ACCEPTABLE_NUMBERS     = "0123456789"
    @IBOutlet weak var markTxtField: UITextField!
    
    var selectedFile = URL.init(string: "")
    
    @IBOutlet weak var webPreview: WKWebView!
    @IBOutlet weak var webViewHeightConstant: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webViewHeightConstant.constant = 0
        self.view.layoutIfNeeded()
    }
    
    @IBAction func addAction(_ sender: Any) {
        
//        if let pdf = PDFDocument(url: selectedFile!) {
//            let pageCount = pdf.pageCount
//            var documentContent = String()
//
//            for i in 0 ..< pageCount {
//                guard let page = pdf.page(at: i) else { continue }
//                guard let pageContent = page.string else { continue }
//                documentContent.append(pageContent)
//            }
//
//            print(documentContent)
//        }
        
        if selectedFile == nil {
            questionTxtField.errorMessage = "Question"
        }
        else if markTxtField.text!.count == 0 || markTxtField.text!.trimmingCharacters(in: .whitespaces).isEmpty {
            self.view.makeToast("Please enter total marks for this question")
        }
        else {
//            let dict = ["question": questionTxtField.text!, "answer": answerTxtView.text!, "mark": markTxtField.text!]
//            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "question"), object: nil, userInfo: dict)
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
