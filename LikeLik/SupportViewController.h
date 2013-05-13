//
//  SupportViewController.h
//  TabBar
//
//  Created by Vladimir Malov on 12.04.13.
//  Copyright (c) 2013 LikeLik. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SupportViewController : UIViewController <UITextFieldDelegate,MBProgressHUDDelegate>
@property (weak, nonatomic) IBOutlet UITextField *Email;
@property (weak, nonatomic) IBOutlet UITextView *FeedBack;
@property (weak, nonatomic) IBOutlet UILabel *Contactinformation;
@property (nonatomic, retain) MBProgressHUD *HUD;
-(void)textviewBeginEditing:(NSNotification*)notification;
-(void)textviewEndEditing:(NSNotification*)notification;
@end