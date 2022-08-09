//
//  AdminStudentVC.swift
//  Smart University Management System
//
//  Created by Kamal Trapasiya on 2022-03-10.
//

import UIKit
import Alamofire

class AdminStudentVC: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var colletionView: UICollectionView!
    
    var studentArr = [[String:Any]]()
    var searchStudentArr = [[String:Any]]()
    var studentDict = [String:Any]()

    override func viewDidLoad() {
        super.viewDidLoad()
        designInit()
        getStudents()
    }
    
    func getStudents() {
        let url = "https://apidockerpython.azurewebsites.net//api/identify"
        
        let param : [String:Any] = [
            "identify" : "3"
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: param)

        var request = URLRequest.init(url: URL.init(string: url)!)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.headers = HTTPHeaders.init([HTTPHeader.init(name: "Content-Type", value: "application/json")])
        
        AF.request(request).responseJSON { [self] result in
            if let value = result.value as? [[String:Any]] {
                studentArr = value
                searchStudentArr = value
                self.colletionView.reloadData()
            }
        }
    }
    
    func designInit() {
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.backgroundColor = .clear
    }
    
    //MARK: Searchbar delegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text!.count > 0 {
            studentArr = searchStudentArr
            studentArr = studentArr.filter({ dict in
                let firstname = dict["firstname"] as! String
                let lastname = dict["lastname"] as! String
                let studentId = dict["id"] as! String
                let email = (dict["email"] as! String).lowercased()
                let name = "\(firstname) \(lastname)".lowercased()
                if name.contains(searchText.lowercased()) || studentId.contains(searchText.lowercased()) || email.contains(searchText.lowercased()) {
                    return true
                }
                return false
            })
            self.colletionView.reloadData()
        }
        else {
            studentArr = searchStudentArr
            self.colletionView.reloadData()
        }
    }
    
    //MARK: Collectioview delegates
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return studentArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: self.view.frame.width - 32, height: 72)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "studentCell", for: indexPath) as! CollectionViewCell
        
        let parti = studentArr[indexPath.row]
        let firstname = parti["firstname"] as! String
        let lastname = parti["lastname"] as! String
        let profile = parti["profile_pic"] as! String
        cell.studentProfile.sd_setImage(with: URL.init(string: profile), placeholderImage: UIImage.init(named: "user"), options: .refreshCached, completed: nil)
        cell.studentID.text = parti["id"] as! String
        cell.studentName.text = "\(firstname) \(lastname)"
        cell.studentEmail.text = parti["email"] as! String
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        studentDict = studentArr[indexPath.row]
        self.performSegue(withIdentifier: "studentInfoSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "studentInfoSegue" {
            let vc = segue.destination as! StudentInfoVC
            vc.studentDict = studentDict
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

}
