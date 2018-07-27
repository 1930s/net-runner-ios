//
//  SettingsTableViewController.h
//  tflite_camera_example
//
//  Created by Philip Dow on 7/10/18.
//  Copyright © 2018 doc.ai. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ModelsTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class SettingsTableViewController;
@class ModelBundle;
@protocol Model;

@protocol SettingsTableViewControllerDelegate

- (void)settingsTableViewControllerWillDisappear:(SettingsTableViewController*)viewController;

@end

// MARK: -

@interface SettingsTableViewController : UITableViewController <ModelsTableViewControllerDelegate>

@property (weak) IBOutlet UISwitch *showInputBuffersSwitch;
@property (weak) IBOutlet UISwitch *showInputBuffersAlphaSwitch;
@property (weak) IBOutlet UILabel *selectedModelNameLabel;
@property (weak) IBOutlet UILabel *evaluateModelsLabel;

@property (weak) id<SettingsTableViewControllerDelegate> delegate;
@property (nonatomic) ModelBundle *selectedBundle;

- (IBAction)toggleShowInputBuffers;
- (IBAction)toggleShowInputBuffersAlpha:(id)sender;

@end

NS_ASSUME_NONNULL_END