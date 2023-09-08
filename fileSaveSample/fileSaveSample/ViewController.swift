//
//  ViewController.swift
//  fileSaveSample
//
//  Created by arai kousuke on 2023/09/08.
//


import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let button = UIButton()
        button.frame = CGRect(x: 0, y:0, width: 100 , height: 100)
        button.backgroundColor = .orange
        button.center = self.view.center
        button.addTarget(self, action: #selector(createFile), for: .touchUpInside)
        self.view.addSubview(button)
    }
    
    @objc  func createFile() {
        
        let csvData = "Name,Email\nJohn Doe,johndoe@example.com\nJane Smith,janesmith@example.com"
        
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentDirectory.appendingPathComponent("data.csv")
            
            do {
                try csvData.write(to: fileURL, atomically: true, encoding: .utf8)
                print("CSVファイルが保存されました：\(fileURL)")
            } catch {
                print("ファイルの保存中にエラーが発生しました：\(error)")
            }
        }



//        let fileManager = FileManager.default
//        let docPath =  NSHomeDirectory() + "/Documents"
//        let filePath = docPath + "/sample.txt"
//
//        if !fileManager.fileExists(atPath: filePath) {
//            fileManager.createFile(atPath:filePath, contents: nil, attributes: [:])
//        }else{
//            print("既に存在します。")
//        }
    }
}
