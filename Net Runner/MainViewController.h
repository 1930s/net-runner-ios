//
//  MainViewController.h
//  Net Runner
//
//  Created by Philip Dow on 7/26/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "SettingsTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class ImageInputPreviewView;
@class ResultInfoView;

@interface MainViewController : UIViewController <UIGestureRecognizerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, SettingsTableViewControllerDelegate>

@property IBOutlet UIImageView *photoImageView;
@property IBOutlet UIView* previewView;
@property IBOutlet ImageInputPreviewView *imageInputPreviewView;
@property IBOutlet ResultInfoView *infoView;

- (IBAction)selectInputSource:(id)sender;

@end

NS_ASSUME_NONNULL_END
