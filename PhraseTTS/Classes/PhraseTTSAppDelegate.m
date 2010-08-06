//
//  PhraseTTSAppDelegate.m
//  PhraseTTS
//
//  Created by Chris Laan on 8/3/10.
//  Copyright Laan Labs 2010. All rights reserved.
//

#import "PhraseTTSAppDelegate.h"
#import "PhraseTTSViewController.h"
#import "Model.h"

#import "SearchResult.h"

#import "Constants.h"

@interface PhraseTTSAppDelegate()

-(void) setDefaults;

@end


@implementation PhraseTTSAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize tabController;



#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
	[self setDefaults];
	
	// setup DB
	[Model instance];
	
	// display a loading bar if the database is indexing...
	[self performSelector:@selector(checkIfUpdating) withObject:nil afterDelay:0.1];	
	
    [window addSubview:tabController.view];
    [window makeKeyAndVisible];

	return YES;
}

-(void) setDefaults {
	
	NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
	
	if ( ![defs boolForKey:kHasLoadedAppKey] ) {
		
		[defs setBool:YES forKey:kHasLoadedAppKey];
		[defs setBool:YES forKey:kAutoCorrectKey];
		[defs setObject:kQWERTYKeyboard forKey:kKeyboardTypeKey];
		[defs setObject:kMaleVoice4 forKey:kVoiceKey];
		
	}
	
}

-(void) checkIfUpdating {
	
	if ( [Model instance].updatingIndex ) {

		loadingView = [[[LoadingView alloc] init] autorelease];
		loadingView.fadeBackground = YES;
		[loadingView showInView:window];
		
		 
		updateTimer = [NSTimer scheduledTimerWithTimeInterval:(1/15.) target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(databaseReady) name:@"PhraseDatabaseReady" object:nil];
		
	}
	
}

-(void) updateProgress {
	
	[loadingView setLabel:[NSString stringWithFormat:@"Updating Index - %3.0f%% " , [Model instance].updateProgress*100.]];
	
}

-(void) databaseReady {
	
	[updateTimer invalidate];
	updateTimer = nil;
	
	[loadingView hide];
	loadingView = nil;
	
	
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [viewController release];
	[tabController release];
    [window release];
    [super dealloc];
}


@end
