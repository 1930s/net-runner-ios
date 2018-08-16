//
//  ModelOutput.h
//  Net Runner
//
//  Created by Philip Dow on 7/28/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * A wrapper around a model's output.
 *
 * This is a utility protocol that is application specific so that we can handle multiple kinds of
 * descriptions for multiple kinds of models.
 */

@protocol ModelOutput <NSObject>

/**
 * The underlying output of the model. May be in any format appropriate to your use case.
 */

@property (readonly) id value;

/**
 * A property list representation of the underlying output. The representation should be JSON serializable.
 */

@property (readonly) id propertyList;

/**
 * A debug string that describes the contents of the receiver.
 */

@property(readonly, copy) NSString *description;

/**
 * A human readable representation of the underlying output.
 */

@property (readonly) NSString *localizedDescription;

/**
 * `YES` if the two outputs are equal, `NO` otherwise
 */

- (BOOL)isEqual:(id)anObject;

/**
 * A decayed combination of the model's previous and current outputs.
 * If you don't want to return a decayed value, simply return `self`.
 *
 * @param previousOutput the previous output of the model. The previous output may be `nil`,
 * in which case you should return `self`.
 *
 * @return a decayed combination of the previous and current outputs
 */

- (id<ModelOutput>)decayedOutput:(nullable id<ModelOutput>)previousOutput;

@end

NS_ASSUME_NONNULL_END
