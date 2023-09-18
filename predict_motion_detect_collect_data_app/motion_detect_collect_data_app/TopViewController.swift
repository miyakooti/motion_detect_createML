//
//  ViewController.swift
//  motion_detect_collect_data_app
//
//  Created by arai kousuke on 2023/09/08.
//

import UIKit
import CoreMotion

final class TopViewController: UIViewController {

    let motionManager = CMMotionManager()
    var writer: MotionWriter?
    var begin: Date?
  let classifier = MotionClassifier()
//  let classifier2 = MotionClassifier()
//  let classifier3 = MotionClassifier()
//  let classifier4 = MotionClassifier()

    @IBOutlet weak var resultText: UILabel!
    
    
    override func viewDidLoad() {
        setUpSensor()
    }
    
    private func setUpSensor() {
        
        if !motionManager.isAccelerometerAvailable {
            print("Accelerometer is not available on this device.")
        }
        
        motionManager.gyroUpdateInterval = AppParameters.samplingRate
        
        let queue = OperationQueue()
      
       var count = 0
        
        motionManager.startGyroUpdates(to: queue) { (gyroData, error) in
            if let data = gyroData {
                // Process accelerometer data
              self.classifier.process(deviceMotion: data)
              count += 1
              
              // 兄は遅れて家を出発
//              if count >= 5 {
//                self.classifier2.process(deviceMotion: data)
//              }
//
//              if count >= 10 {
//                self.classifier3.process(deviceMotion: data)
//              }
//
//              if count >= 15 {
//                self.classifier4.process(deviceMotion: data)
//              }
            }
            if let error = error {
                print("Error reading accelerometer data: \(error)")
            }
        }
      classifier.delegate = self
//      classifier2.delegate = self
//      classifier3.delegate = self
//      classifier4.delegate = self

    }
    

}


extension TopViewController: MotionClassifierDelegate {
    func motionDidDetect(results: [(String, Double)]) {
        print(results)

        DispatchQueue.main.async {
            guard let resultText = results.first?.0 else { return }
            print("⭐️" + resultText)
//            if results[0].0 == "circle" {
//                print("サークル")
//            }
//            else  {
//                print("そうじゃない")
//            }
            self.resultText.text = "\(results[0].0)\n\(results[0].1)"
        }
    }
}
