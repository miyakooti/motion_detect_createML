//
//  jho.swift
//  motion_detect_collect_data_app
//
//  Created by arai kousuke on 2023/09/08.
//



import Foundation
import CoreML
import CoreMotion

protocol MotionClassifierDelegate: class {
    func motionDidDetect(results: [(String, Double)])
}

class MotionClassifier {

    weak var delegate: MotionClassifierDelegate?

    static let configuration = MLModelConfiguration()
    let model = try! circle_0911_1(configuration: configuration)

    static let predictionWindowSize = 20
//    let acceleration_x = try! MLMultiArray(
//        shape: [predictionWindowSize] as [NSNumber],
//        dataType: MLMultiArrayDataType.double)
//    let acceleration_y = try! MLMultiArray(
//        shape: [predictionWindowSize] as [NSNumber],
//        dataType: MLMultiArrayDataType.double)
//    let acceleration_z = try! MLMultiArray(
//        shape: [predictionWindowSize] as [NSNumber],
//        dataType: MLMultiArrayDataType.double)
    let gyro_x = try! MLMultiArray(
        shape: [predictionWindowSize] as [NSNumber],
        dataType: MLMultiArrayDataType.double)
    let gyro_y = try! MLMultiArray(
        shape: [predictionWindowSize] as [NSNumber],
        dataType: MLMultiArrayDataType.double)
    let gyro_z = try! MLMultiArray(
        shape: [predictionWindowSize] as [NSNumber],
        dataType: MLMultiArrayDataType.double)


    private var predictionWindowIndex = 0

//    func process(deviceMotion: CMAccelerometerData) {
    func process(deviceMotion: CMGyroData) {

        if predictionWindowIndex == MotionClassifier.predictionWindowSize {
            return
        }

//        acceleration_x[[predictionWindowIndex] as [NSNumber]] = deviceMotion.acceleration.x as NSNumber
//        acceleration_y[[predictionWindowIndex] as [NSNumber]] = deviceMotion.acceleration.y as NSNumber
//        acceleration_z[[predictionWindowIndex] as [NSNumber]] = deviceMotion.acceleration.z as NSNumber
        gyro_x[[predictionWindowIndex] as [NSNumber]] = deviceMotion.rotationRate.x as NSNumber
        gyro_y[[predictionWindowIndex] as [NSNumber]] = deviceMotion.rotationRate.y as NSNumber
        gyro_z[[predictionWindowIndex] as [NSNumber]] = deviceMotion.rotationRate.z as NSNumber

        predictionWindowIndex += 1

        if predictionWindowIndex == MotionClassifier.predictionWindowSize {
            DispatchQueue.global().async {
              HapticFeedbackManager.shared.play(.impact(.heavy))
                self.predict()
                DispatchQueue.main.async {
                    self.predictionWindowIndex = 0
                }
            }
        }
    }
    
    

    var stateOut: MLMultiArray? = nil

    private func predict() {

        let input = circle_0911_1Input(
            gyro_x: gyro_x,
            gyro_y: gyro_y,
            gyro_z: gyro_z)
      
      print(gyro_x)
      print(gyro_x)
      print(gyro_x)


//            stateIn: self.stateOut

        guard let result = try? model.prediction(input: input) else { return }

        let sorted = result.labelProbability.sorted {
            return $0.value > $1.value
        }
        delegate?.motionDidDetect(results: sorted)
    }
}
