//
//  ImageEvaluator.h
//  Net Runner
//
//  Created by Philip Dow on 7/18/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "Evaluator.h"
#import "VisionModel.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * Runs inference on a `UIImage`. Most `VisionModel` will delegate evaluation to this object, which then
 * delegates it to the `CVPixelBufferEvaluator`.
 */

@interface ImageEvaluator : NSObject <Evaluator>

/**
 * The `VisionModel` object on which inference is run. Noted in the results dictionary under the `kEvaluatorResultsKeyModel` key.
 */

@property (readonly) id<VisionModel> model;

/**
 * The results of running inference on the model. See EvaluatorConstants.h for a list of keys that may
 * appear in this dictionary.
 */

@property (readonly) NSDictionary *results;

/**
 * The image on which inference is being run.
 */

@property (readonly) UIImage *image;

/**
 * Designated initializer.
 *
 * @param model The `VisionModel` object on which inference is being run. Noded in the results dictionary under the `kEvaluatorResultsKeyModel` key.
 * @param image The `UIImage` on which inference is being run.
 */

- (instancetype)initWithModel:(id<VisionModel>)model image:(UIImage*)image NS_DESIGNATED_INITIALIZER;

/**
 * Use the designated initializer.
 */

- (instancetype)init NS_UNAVAILABLE;

/**
 * Acquires a `CVPixelBufferRef` from the contents of the image and delegates inference to an instance of `CVPixelBufferEvaluator`.
 * Stores the results of inference in the `results` property and passes that value to the completion handler.
 *
 * @param completionHandler the completion block called when evaluation is finished. May be called on
 * a separate thread.
 */

- (void)evaluateWithCompletionHandler:(nullable EvaluatorCompletionBlock)completionHandler;

@end

NS_ASSUME_NONNULL_END
