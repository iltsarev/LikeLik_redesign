//
//  AppDelegate.h
//  LikeLik
//
//  Created by Vladimir Malov on 08.05.13.
//  Copyright (c) 2013 LikeLik. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "GAI.h"
#import "GAIFields.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"

#define log(string) [AppDelegate LLLog:string];

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;
@property (nonatomic, retain) IBOutlet UILabel  *alertLabel;
@property (nonatomic, assign) UIViewController *currentController;
@property(nonatomic, strong) id<GAITracker> tracker;

+(UIFont *)OpenSansRegular:(CGFloat)size;
+(UIFont *)OpenSansSemiBold:(CGFloat)size;
+(UIFont *)OpenSansBoldwithSize:(CGFloat)size;
+(void)LLLog:(NSString *)string;


+(void)segmentControlMapList;
+(BOOL)isiPhone5;
+(void)lang;

@end