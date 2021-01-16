//
//  PixelBufferUtil.swift
//  testMediapipe
//
//  Created by alexcai on 2021/1/14.
//

import Foundation
import AVFoundation

class PixelBufferUtil:NSObject{
    
    @objc
    static public func  changeSampleBuffer(pixelBuffer: CVPixelBuffer!) -> CMSampleBuffer{
        var newSampleBuffer: CMSampleBuffer? = nil
        var timimgInfo: CMSampleTimingInfo = CMSampleTimingInfo.invalid
        var videoInfo: CMVideoFormatDescription? = nil
        
        CMVideoFormatDescriptionCreateForImageBuffer(allocator: nil, imageBuffer: pixelBuffer, formatDescriptionOut: &videoInfo)
        CMSampleBufferCreateForImageBuffer(allocator: kCFAllocatorDefault, imageBuffer: pixelBuffer, dataReady: true, makeDataReadyCallback: nil, refcon: nil, formatDescription: videoInfo!, sampleTiming: &timimgInfo, sampleBufferOut: &newSampleBuffer)
        
        setSampleBufferAttachments(newSampleBuffer!)
        
        return newSampleBuffer!;
    }
    
    static func setSampleBufferAttachments(_ sampleBuffer: CMSampleBuffer) {
        
        let attachments: CFArray! = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, createIfNecessary: true)
        let dictionary = unsafeBitCast(CFArrayGetValueAtIndex(attachments, 0),
                                       to: CFMutableDictionary.self)
        let key = Unmanaged.passUnretained(kCMSampleAttachmentKey_DisplayImmediately).toOpaque()
        let value = Unmanaged.passUnretained(kCFBooleanTrue).toOpaque()
        CFDictionarySetValue(dictionary, key, value)
        
    }
}
