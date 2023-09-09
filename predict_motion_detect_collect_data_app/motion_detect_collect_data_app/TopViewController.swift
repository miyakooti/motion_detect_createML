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
        
        motionManager.startGyroUpdates(to: queue) { (gyroData, error) in
            if let data = gyroData {
                // Process accelerometer data
                self.classifier.process(deviceMotion: data)
            }
            if let error = error {
                print("Error reading accelerometer data: \(error)")
            }
        }
        
        classifier.delegate = self
        
        //        if !hmm.isDeviceMotionAvailable {
        //            print("current device does not supports the headphone motion manager.")
        //            return
        //        }
        //
        //        hmm.startDeviceMotionUpdates(to: queue) { (motion, error) in
        //            if let motion = motion {
        ////                print(motion)
        //                self.classifier.process(deviceMotion: motion)
        //                DispatchQueue.main.async {
        //                self.textView.text = """
        //                    加速度:
        //                        x: \(motion.userAcceleration.x)
        //                        y: \(motion.userAcceleration.y)
        //                        z: \(motion.userAcceleration.z)
        //                    """
        //                }
        //            }
        //            if let error = error {
        //                print(error)
        //            }
        //        }
    }
    

}


extension TopViewController: MotionClassifierDelegate {
    func motionDidDetect(results: [(String, Double)]) {
        print(results)

        DispatchQueue.main.async {
            guard let resultText = results.first?.0 else { return }
            print("⭐️" + resultText)
            self.resultText.text = resultText
//            if results[0].0 == "circle" {
//                print("サークル")
//            }
//            else  {
//                print("そうじゃない")
//            }
//            self.label.text = "\(results[0].0)\n\(results[0].1)"
//            self.label2.text = results.description
        }
    }
}
