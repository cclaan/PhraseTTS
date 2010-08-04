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

@implementation PhraseTTSAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize tabController;



#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
	// setup DB
	[Model instance];
	
	//[[Model instance] createTable];
	
	
	// SELECT * FROM mail WHERE body MATCH 'sqlite';
	
	
	[self searchTable];
	
	
	
	
	
	
	
    // Override point for customization after app launch. 
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];

	return YES;
}

-(void) searchTable {
	
	if ( [Model instance].updatingIndex ) {
		NSLog(@"model is updating... %3.2f " , [Model instance].updateProgress );
		[self performSelector:@selector(searchTable) withObject:nil afterDelay:0.1];
		return;
	}
	
	NSArray * arr = [[SearchResult sortedSearchForQuery:@"shirt"] retain];
	
	if ( [arr count] > 0 ) {
		SearchResult * r = [arr objectAtIndex:0];
		NSLog(@"body: %@  , uses: %i " , r.body , r.uses );
		[r incrementUsesAndSave];
	}
	
	NSLog(@"total: %i " , [arr count] );
	
	
	/*SearchResult * sr = [[SearchResult alloc] init];
	sr.body = @"My favorite phrase today peanuts";
	[sr insertIntoDb];
	*/
	
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
    [window release];
    [super dealloc];
}


@end
