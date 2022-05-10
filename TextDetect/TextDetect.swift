//
//  TextDetect.swift
//  TextDetect
//
//  Created by hao yin on 2022/5/6.
//

import Foundation
import Vision


public class TextDetect{
    public init() {}
    public func detect(image:CGImage,callback:@escaping ([String])->Void) throws{
        var texts:[String] = []
        let textRecognitionRequest = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                print("The observations are of an unexpected type.")
                return
            }
            // 把识别的文字全部连成一个string
            let maximumCandidates = 1
            for observation in observations {
                guard let candidate = observation.topCandidates(maximumCandidates).first else { continue }
                texts.append(candidate.string)
            }
            callback(texts)
        }
        textRecognitionRequest.recognitionLevel = .accurate
        textRecognitionRequest.recognitionLanguages = ["zh-cn","en-US"]
        textRecognitionRequest.revision = VNRecognizeTextRequestRevision2
        textRecognitionRequest.usesLanguageCorrection = true
        try VNImageRequestHandler(cgImage: image).perform([textRecognitionRequest])
    }
    public func detectQR(image:CGImage,callback:@escaping ([String])->Void) throws{
        let barReq = VNDetectBarcodesRequest { rq, e in
            let a = (rq.results as! [VNBarcodeObservation]).compactMap({$0.payloadStringValue})
            callback(a)
        }
        barReq.symbologies = [.qr]
        try VNImageRequestHandler(cgImage: image).perform([barReq])
    }
}
