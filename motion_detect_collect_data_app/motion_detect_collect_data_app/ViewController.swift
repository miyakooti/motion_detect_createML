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
        motionManager.startAccelerometerUpdates(to: .main) { (accelerometerData, error) in
            if let data = accelerometerData {
                // Process accelerometer data
                if let writer = self.writer {
                    writer.write(data)

                    // You can add logic here to stop recording after a certain duration
                    print(accelerometerData)
                }
            }
            if let error = error {
                print("Error reading accelerometer data: \(error)")
            }
        }
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

//         Create a directory in the app's document directory
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        let dirName = "AccelerometerData"
        let dirName = "motion"
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
