//
//  PhraseTTSAppDelegate.h
//  PhraseTTS
//
//  Created by Chris Laan on 8/3/10.
//  Copyright Laan Labs 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LoadingView.h"
#import "LLHUDStatusView.h"

@class PhraseTTSViewController;

@interface PhraseTTSAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    
	PhraseTTSViewController *viewController;
	
	UITabBarController * tabController;
	
	LoadingView * loadingView;
	NSTimer * updateTimer;
	
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet PhraseTTSViewController *viewController;
@property (nonatomic, retain) IBOutlet UITabBarController *tabController;

@end

