//
//  ViewController.h
//  JumbleGame
//
//  Created by Gurminder Deep Singh on 3/15/14.
//  Copyright (c) 2014 Gurminder Deep Singh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *foundLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

-(IBAction)solveJumble:(id)sender;

@end
