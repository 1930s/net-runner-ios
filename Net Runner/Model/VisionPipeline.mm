//
//  VisionPipeline.m
//  tflite_camera_example
//
//  Created by Philip Dow on 7/11/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import "VisionPipeline.h"

#import "Model.h"
#import "VisionModel.h"
#import "CVPixelBufferHelpers.h"
#import "ObjcDefer.h"

@interface VisionPipeline()

@property id<VisionModel> model;

@end

@implementation VisionPipeline

- (instancetype)initWithVisionModel:(id<VisionModel>)model {
    if (self = [super init]) {
        _model = model;
    }
    
    return self;
}

- (nullable CVPixelBufferRef)transform:(CVPixelBufferRef)pixelBuffer orientation:(CGImagePropertyOrientation)orientation {
    CVPixelBufferRef resizedPixelBuffer = NULL;
    CVPixelBufferRef rotatedPixelBuffer = NULL;
    CVPixelBufferRef formattedPixelBuffer = NULL;
    
    // Resize pixel buffer
    // :: pixelBuffer -> resizedPixelBuffer
    
    const size_t srcWidth = CVPixelBufferGetWidth(pixelBuffer);
    const size_t srcHeight = CVPixelBufferGetHeight(pixelBuffer);
    const size_t dstWidth = self.model.imageVolume.width;
    const size_t dstHeight = self.model.imageVolume.height;
    
    if (srcWidth != dstWidth || srcHeight != dstHeight) {
        resizedPixelBuffer = CVPixelBufferResizeToSquare(pixelBuffer, CGSizeMake(dstWidth, dstHeight));
    } else {
        resizedPixelBuffer = pixelBuffer;
        CVPixelBufferRetain(resizedPixelBuffer);
    }
    
    // Error handling and cleanup
    
    if (resizedPixelBuffer == NULL) {
        NSLog(@"Unable to resize pixel buffer");
        return NULL;
    }
    
defer_block {
    CVPixelBufferRelease(resizedPixelBuffer);
};
    
    // Rotate pixel buffer
    // :: resizedPixelBuffer -> rotatedPixelBuffer
    
    switch (orientation) {
    case kCGImagePropertyOrientationUp:
        rotatedPixelBuffer = resizedPixelBuffer;
        CVPixelBufferRetain(rotatedPixelBuffer);
        break;
    case kCGImagePropertyOrientationRight:
        rotatedPixelBuffer = CVPixelBufferRotate(resizedPixelBuffer, Rotate270Degrees);
        break;
    case kCGImagePropertyOrientationDown:
        rotatedPixelBuffer = CVPixelBufferRotate(resizedPixelBuffer, Rotate180Degrees);
        break;
    case kCGImagePropertyOrientationLeft:
        rotatedPixelBuffer = CVPixelBufferRotate(resizedPixelBuffer, Rotate90Degrees);
        break;
    default:
        NSLog(@"Unknown orientation, assuming kCGImagePropertyOrientationUp, reported: %d", orientation);
        rotatedPixelBuffer = resizedPixelBuffer;
        CVPixelBufferRetain(rotatedPixelBuffer);
        break;
    }
    
    // Error handling and cleanup
    
    if (rotatedPixelBuffer == NULL) {
        NSLog(@"Unable to rotate pixel buffer");
        return NULL;
    }
    
defer_block {
    CVPixelBufferRelease(rotatedPixelBuffer);
};
    
    // Convert pixel buffer to ARGB
    // :: rotatedPixelBuffer ->formattedPixelBuffer
    
    const OSType srcFormat = CVPixelBufferGetPixelFormatType(rotatedPixelBuffer);
    const OSType dstFormat = self.model.pixelFormat;
    
    assert(srcFormat == kCVPixelFormatType_32BGRA || srcFormat == kCVPixelFormatType_32ARGB);
    
    if (srcFormat == kCVPixelFormatType_32BGRA && dstFormat == kCVPixelFormatType_32ARGB ) {
        formattedPixelBuffer = CVPixelBufferCreateARGBFromBGRA(rotatedPixelBuffer);
    } else if (srcFormat == kCVPixelFormatType_32ARGB && dstFormat == kCVPixelFormatType_32BGRA) {
        formattedPixelBuffer = CVPixelBufferCreateBGRAFromARGB(rotatedPixelBuffer);
    } else {
        formattedPixelBuffer = rotatedPixelBuffer;
        CVPixelBufferRetain(formattedPixelBuffer);
    }
    
    // Error handling and cleanup
    
    if (formattedPixelBuffer == NULL) {
        NSLog(@"Unable to convert pixel buffer format");
        return NULL;
    }
    
defer_block {
    CFAutorelease(formattedPixelBuffer);
};
    
    // Return the formatted pixel buffer
    
    return formattedPixelBuffer;
}

@end