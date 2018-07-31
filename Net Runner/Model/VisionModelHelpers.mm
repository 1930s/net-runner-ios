//
//  VisionModelHelpers.mm
//  Net Runner
//
//  Created by Philip Dow on 7/12/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#include "VisionModelHelpers.h"

const PixelNormalization kNoNormalization = {
    .scale = 1,
    .redBias = 0,
    .greenBias = 0,
    .blueBias = 0
};

const ImageVolume kNoImageVolume = {
    .width = 0,
    .height = 0,
    .channels = 0
};

const OSType PixelFormatTypeNone = 'NULL';

// Core Pixel Normalizers

PixelNormalizer PixelNormalizerNone() {
    return nil;
}

PixelNormalizer PixelNormalizerSingleBias(const PixelNormalization& normalization) {
    float scale = normalization.scale;
    float bias = normalization.redBias;
    
    return ^float_t (const uint8_t &value, const uint8_t &channel) {
        return ((float_t)value * scale) + bias;
    };
}

PixelNormalizer PixelNormalizerPerChannelBias(const PixelNormalization& normalization) {
    float scale = normalization.scale;
    float redBias = normalization.redBias;
    float greenBias = normalization.greenBias;
    float blueBias = normalization.blueBias;
    
    return ^float_t (const uint8_t &value, const uint8_t &channel) {
        switch (channel) {
        case 0:
            return ((float_t)value * scale) + redBias;
        case 1:
            return ((float_t)value * scale) + greenBias;
        case 2:
            return ((float_t)value * scale) + blueBias;
        default:
            NSLog(@"Unexpected channel in scaling block: %hhu", channel);
            assert(false);
        }
    };
}

// Helpers for Constructing Standard Pixel Normalizers

PixelNormalizer PixelNormalizerZeroToOne() {
    float scale = 1.0/255.0;
    
    return ^float_t (const uint8_t &value, const uint8_t &channel) {
        return ((float_t)value * scale);
    };
}

PixelNormalizer PixelNormalizerNegativeOneToOne() {
    float scale = 2.0/255.0;
    float bias = -1;
    
    return ^float_t (const uint8_t &value, const uint8_t &channel) {
        return ((float_t)value * scale) + bias;
    };
}

// Initialization Helpers

ImageVolume ImageVolumeForShape(NSArray<NSNumber*> *shape) {
    
    if ( shape == nil ) {
        NSLog(@"Expected input.shape array field in model.json, none found");
        return kNoImageVolume;
    }

    if ( shape.count != 3 ) {
        NSLog(@"Expected shape with three elements, actual count is %lu", (unsigned long)shape.count);
        return kNoImageVolume;
    }

    return {
        .width = (int)shape[0].integerValue,
        .height = (int)shape[1].integerValue,
        .channels = (int)shape[2].integerValue
    };
}

OSType PixelFormatForString(NSString* string) {
    
    if ( string == nil ) {
        NSLog(@"Expected input.format string in model.json, none found");
        return PixelFormatTypeNone;
    }
    else if ( [string isEqualToString:@"RGB"] ) {
        return kCVPixelFormatType_32ARGB;
    }
    else if ([string isEqualToString:@"BGR"] ) {
        return kCVPixelFormatType_32BGRA;
    }
    else {
        NSLog(@"expected input.format string to be 'RGB' or 'BGR', actual value is %@", string);
        return PixelFormatTypeNone;
    }
}

// The presence of a normalizer overrides scale and bias preferences
// Would like to return a tuple here

PixelNormalization PixelNormalizationForInput(NSDictionary *input) {
    NSString *normalizerString = input[@"normalize"];
    NSNumber *scaleNumber = input[@"scale"];
    NSDictionary *biases = input[@"bias"];
    
    if ( normalizerString != nil ) {
        if ( [normalizerString isEqualToString:@"[0,1]"] ) {
            return {
                .scale = 1.0/255.0,
                .redBias = 0,
                .greenBias = 0,
                .blueBias = 0
            };
        }
        else if ( [normalizerString isEqualToString:@"[-1,1]"] ) {
            return {
                .scale = 2.0/255.0,
                .redBias = -1,
                .greenBias = -1,
                .blueBias = -1
            };
        }
        else {
            NSLog(@"Expected input.normalizer string to be '[0,1]' or '[-1,1]', actual value is %@", normalizerString);
            return kNoNormalization;
        }
    }
    else if ( scaleNumber == nil && biases == nil ) {
        return kNoNormalization;
    }
    else {
        float_t scale = scaleNumber != nil
            ? [scaleNumber floatValue]
            : 1.0;
        float_t redBias = biases != nil
            ? [biases[@"r"] floatValue]
            : 0.0;
        float_t greenBias = biases != nil
            ? [biases[@"g"] floatValue]
            : 0.0;
        float_t blueBias = biases != nil
            ? [biases[@"b"] floatValue]
            : 0.0;
        
        return {
            .scale = scale,
            .redBias = redBias,
            .greenBias = greenBias,
            .blueBias = blueBias
        };
    }
}

PixelNormalizer PixelNormalizerForInput(NSDictionary *input) {
    NSString *normalizerString = input[@"normalize"];
    NSNumber *scaleNumber = input[@"scale"];
    NSDictionary *biases = input[@"bias"];
    
    if ( normalizerString != nil ) {
        if ( [normalizerString isEqualToString:@"[0,1]"] ) {
            return PixelNormalizerZeroToOne();
        }
        else if ( [normalizerString isEqualToString:@"[-1,1]"] ) {
            return PixelNormalizerNegativeOneToOne();
        }
        else {
            NSLog(@"Expected input.normalizer string to be '[0,1]' or '[-1,1]', actual value is %@", normalizerString);
            return nil;
        }
    }
    else if ( scaleNumber == nil && biases == nil ) {
        return PixelNormalizerNone();
    }
    else {
        float_t scale = scaleNumber != nil
            ? [scaleNumber floatValue]
            : 1.0;
        float_t redBias = biases != nil
            ? [biases[@"r"] floatValue]
            : 0.0;
        float_t greenBias = biases != nil
            ? [biases[@"g"] floatValue]
            : 0.0;
        float_t blueBias = biases != nil
            ? [biases[@"b"] floatValue]
            : 0.0;
        
        PixelNormalization normalization = {
            .scale = scale,
            .redBias = redBias,
            .greenBias = greenBias,
            .blueBias = blueBias
        };
        
        if ( (redBias == greenBias) && (redBias == blueBias) ) {
            return PixelNormalizerSingleBias(normalization);
        } else {
            return PixelNormalizerPerChannelBias(normalization);
        }
    }
}

// Utilities

BOOL ImageVolumesEqual(const ImageVolume& a, const ImageVolume& b) {
    return a.width == b.width && a.height == b.height && a.channels == b.channels;
}
