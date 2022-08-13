//
//  LibraryVC.swift
//  Smart University Management System
//
//  Created by Kamal Trapasiya on 2022-05-26.
//

import UIKit
import Alamofire

class LibraryVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var booksArr = [[String:Any]]()
    var searchBookArr = [[String:Any]]()
    var courseDict = [String:Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        designInit()
        getBooks()
    }
    
    func designInit() {
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.backgroundColor = .clear
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            booksArr = searchBookArr
            collectionView.reloadData()
        }
        else {
            booksArr = booksArr.filter({ dict in
                let bookName = (dict["title"] as! String).lowercased()
                if bookName.contains(searchText.lowercased()) {
                    return true
                }
                return false
            })
            self.collectionView.reloadData()
        }
    }
    
    func getBooks() {
        self.showLoader()
        if let login = UserDefaults.standard.dictionary(forKey: "login") as? [String:Any] {
            print(login)
            let url = "https://apidockerpython.azurewebsites.net/api/library/prediction"
            let param : [String:Any] = [
                "course_name" : courseDict["course_name"] as! String,
                "description": courseDict["description"] as! String,
                "any_suggestion": true
            ]
            let jsonData = try! JSONSerialization.data(withJSONObject: param)
            var request = URLRequest.init(url: URL.init(string: url)!)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            request.headers = HTTPHeaders.init([HTTPHeader.init(name: "Content-Type", value: "application/json")])
            AF.request(request).responseJSON { [self] result in
                self.dismissLoader()
                if let value = result.value as? [String:Any] {
                    booksArr = value["data"] as! [[String:Any]]
                    searchBookArr = booksArr
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    //MARK: Collectionviow delegates
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return booksArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.view.frame.width - 48) / 2
        return CGSize.init(width: width, height: width * 1.85)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bookCell", for: indexPath) as! CollectionViewCell
        let parti = booksArr[indexPath.row]
        cell.bookName.text = parti["title"] as! String
        if let desc = parti["description"] as? String {
            cell.bookDesc.text = desc
        }
        else {
            cell.bookDesc.text = parti["title"] as! String
        }
        if let thumb = parti["thumbnail"] as? String {
            cell.bookImgView.sd_setImage(with: URL.init(string: thumb), placeholderImage: UIImage.init(named: "book_place.png"), options: []) { img, error, cache, url in
                print(error)
            }
        }
        return cell
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
