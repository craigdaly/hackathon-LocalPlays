//
//  ViewController.h
//  Local Plays for Rdio®
//
//  Created by Fosco Marotto on 3/30/13.
//  Copyright (c) 2013 Parse. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <RdioDelegate>

- (IBAction)didTapLogin:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) Rdio *rdio;

@end
