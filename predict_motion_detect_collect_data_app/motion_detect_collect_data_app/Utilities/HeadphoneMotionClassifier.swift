//
//  jho.swift
//  motion_detect_collect_data_app
//
//  Created by arai kousuke on 2023/09/08.
//



import Foundation
import CoreML
import CoreMotion

protocol HeadphoneMotionClassifierDelegate: class {
    func motionDidDetect(results: [(String, Double)])
}

class HeadphoneMotionClassifier {

    weak var delegate: HeadphoneMotionClassifierDelegate?

    static let configuration = MLModelConfiguration()
    let model = try! MotionClassifier_Iteration_10(configuration: configuration)

    static let predictionWindowSize = 100
    let acceleration_x = try! MLMultiArray(
        shape: [predictionWindowSize] as [NSNumber],
        dataType: MLMultiArrayDataType.double)
    let acceleration_y = try! MLMultiArray(
        shape: [predictionWindowSize] as [NSNumber],
        dataType: MLMultiArrayDataType.double)
    let acceleration_z = try! MLMultiArray(
        shape: [predictionWindowSize] as [NSNumber],
        dataType: MLMultiArrayDataType.double)


    private var predictionWindowIndex = 0

    func process(deviceMotion: CMAccelerometerData) {

        if predictionWindowIndex == HeadphoneMotionClassifier.predictionWindowSize {
            return
        }

        acceleration_x[[predictionWindowIndex] as [NSNumber]] = deviceMotion.acceleration.x as NSNumber
        acceleration_y[[predictionWindowIndex] as [NSNumber]] = deviceMotion.acceleration.y as NSNumber
        acceleration_z[[predictionWindowIndex] as [NSNumber]] = deviceMotion.acceleration.z as NSNumber

        predictionWindowIndex += 1

        if predictionWindowIndex == HeadphoneMotionClassifier.predictionWindowSize {
            DispatchQueue.global().async {
                self.predict()
                DispatchQueue.main.async {
                    self.predictionWindowIndex = 0
                }
            }
        }
    }

    var stateOut: MLMultiArray? = nil

    private func predict() {

        let input = MotionClassifier_Iteration_10Input(
            acceleration_x: acceleration_x,
            acceleration_y: acceleration_y,
            acceleration_z: acceleration_z, stateIn: self.stateOut!)


//            stateIn: self.stateOut

        guard let result = try? model.prediction(input: input) else { return }

        let sorted = result.labelProbability.sorted {
            return $0.value > $1.value
        }
        delegate?.motionDidDetect(results: sorted)
    }
}