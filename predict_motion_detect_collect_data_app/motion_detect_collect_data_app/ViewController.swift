//
//  ViewController.swift
//  motion_detect_collect_data_app
//
//  Created by arai kousuke on 2023/09/08.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {

    let motionManager = CMMotionManager()
    var writer: MotionWriter?
    var begin: Date?
    let classifier = HeadphoneMotionClassifier()
    @IBOutlet weak var dirTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        // Check if the device supports motion data
        if !motionManager.isAccelerometerAvailable {
            print("Accelerometer is not available on this device.")
        }

        // Configure the motion update interval
        motionManager.accelerometerUpdateInterval = AppParameters.samplingRate

        // Start accelerometer updates
        let queue = OperationQueue()

        motionManager.startAccelerometerUpdates(to: queue) { (accelerometerData, error) in
            if let data = accelerometerData {
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

    @IBAction func tapButton(_ sender: Any) {
        if self.writer == nil {
            startRecording()
        } else {
            stopRecording()
        }
    }

    func startRecording() {
        HapticFeedbackManager.shared.play(.impact(.heavy))
        
        guard let dirName = dirTextField.text else {return}

//         Create a directory in the app's document directory
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        let dirName = "AccelerometerData"
        let dirURL = documentDirectory.appendingPathComponent(dirName, isDirectory: true)

        do {
            try FileManager.default.createDirectory(at: dirURL, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            print("Error creating directory: \(error)")
            return
        }

        // Generate a unique filename based on date and time
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        let filename = formatter.string(from: Date()) + ".csv"
        let fileURL = dirURL.appendingPathComponent(filename)
        
        // Initialize the writer
        writer = MotionWriter()
        writer?.open(fileURL)
        begin = Date()
    }

    func stopRecording() {
        if let writer = self.writer {
            writer.close()
            print("記録完了")
            HapticFeedbackManager.shared.play(.impact(.heavy))
            HapticFeedbackManager.shared.play(.impact(.heavy))
            self.writer = nil
        }
    }
}


extension ViewController: HeadphoneMotionClassifierDelegate {
    func motionDidDetect(results: [(String, Double)]) {
        print(results)
//        if results[0].1 < 0.80 {
//            print("pass")
//            return
//        }
        DispatchQueue.main.async {
            if results[0].0 == "circle" {
                print("サークル")
            }
            else  {
                print("そうじゃない")
            }
//            self.label.text = "\(results[0].0)\n\(results[0].1)"
//            self.label2.text = results.description
        }
    }
}
