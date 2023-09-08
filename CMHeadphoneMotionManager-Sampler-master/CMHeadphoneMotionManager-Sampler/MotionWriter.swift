//
//  MotionWriter.swift
//  CMHeadphoneMotionManager-Sampler
//
//  Created by yorifuji on 2020/10/03.
//
import Foundation
import CoreMotion

class MotionWriter {

    var file: FileHandle?
    var sample: Int = 0

    func open(_ filePath: URL) {
        do {
            
            
            
            
            FileManager.default.createFile(atPath: filePath.path, contents: nil, attributes: nil)
            let file = try FileHandle(forWritingTo: filePath)
            var header = ""
            header += "acceleration_x,"
            header += "acceleration_y,"
            header += "acceleration_z,"
            header += "timestamp"
            header += "\n"
            file.write(header.data(using: .utf8)!)
            self.file = file
        } catch let error {
            print(error)
        }
    }

    func write(_ accelerationData: CMAccelerometerData) {
        guard let file = self.file else { return }
        var text = ""
        text += "\(accelerationData.acceleration.x),"
        text += "\(accelerationData.acceleration.y),"
        text += "\(accelerationData.acceleration.z),"
        text += "\(accelerationData.timestamp)"
        text += "\n"
        file.write(text.data(using: .utf8)!)
        print("書き込みしました")
        sample += 1
    }

    func close() {
        guard let file = self.file else { return }
        file.closeFile()
        print("\(sample) sample")
        self.file = nil
    }
}
