//
//  PhraseTTSAppDelegate.h
//  PhraseTTS
//
//  Created by Chris Laan on 8/3/10.
//  Copyright Laan Labs 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhraseTTSViewController;

@interface PhraseTTSAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    PhraseTTSViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet PhraseTTSViewController *viewController;

@end

