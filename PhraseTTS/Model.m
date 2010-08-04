//
//  Model.m
//  PhraseTTS
//
//  Created by cclaan on 4/9/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Model.h"
#include <stdio.h>
#import "SearchResult.h"

static Model *instance = nil;


@interface Model (privates)

-(void) initDb;
-(void) createOrCopyDB;
-(void) upgradeDbIfNeeded;
-(void) recreateIndex;
-(void) openFMDB;
-(void) createTables;
-(void) optimizeIndex;

NSString * readLineAsNSString(FILE *file);

@end


#pragma mark -
@implementation Model


@synthesize  db ;
@synthesize updatingIndex , updateProgress;


-(void) setupModel {
	

	[self initDb];
	
		
}

#pragma mark -
#pragma mark DB



- (void)initDb
{
	
	BOOL recreateIndex = NO;
	
	double lastDate = [[NSUserDefaults standardUserDefaults] doubleForKey:@"lastFileModDate"];
					   
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	NSString * pathOfPhrases = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:PHRASES_TEXT_FILE];
	
	BOOL phrasesFileExists = [fileManager fileExistsAtPath:pathOfPhrases];
	
	if ( !phrasesFileExists ) {
		NSAssert(0, @"Did not find phrase.txt file");
	}
	
	NSDictionary * d = [fileManager attributesOfItemAtPath:pathOfPhrases error:nil];
	
	NSDate * modDate = [d fileModificationDate];
	
	double timeSince = [modDate timeIntervalSinceReferenceDate];
	
	if ( lastDate != timeSince ) {
		
		[[NSUserDefaults standardUserDefaults] setDouble:timeSince forKey:@"lastFileModDate"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
		recreateIndex = YES;
		
		NSLog(@"recreate index");
		
	} else {
		NSLog(@"Date is the same, dont rebuild index");
	}
	
	
	
	NSError *error;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:DATABASE_FILE];
	
	
	/*
	 // not deleting since we have to keep the used phrases table
	if (recreateIndex) {
		[fileManager removeItemAtPath:writableDBPath error:&error];
	}
	*/
	
	BOOL dbExists = [fileManager fileExistsAtPath:writableDBPath];
	
	if (dbExists) {
		
		NSLog(@"DB Exists");
		//return;
		
	} else {
	
		// The writable database does not exist, so copy the default to the appropriate location.
		NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:DATABASE_FILE];
		BOOL success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
		
		if (!success) {
			
			NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
			
		}
		
	}
	
	[self openFMDB];
	
	if ( !dbExists ) {
		[self createTables];
	}
	
	if ( recreateIndex ) {
		
		updatingIndex = YES;
		[self performSelectorInBackground:@selector(recreateIndex) withObject:nil];
		
	} else {
		
		[self performSelectorInBackground:@selector(optimizeIndex) withObject:nil];
		
	}
	
}	
	
-(void) openFMDB {
	
	
	if (db == nil) {
		
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString *path = [documentsDirectory stringByAppendingPathComponent:DATABASE_FILE];
		
		
		db = [[FMDatabase databaseWithPath:path] retain];
		if (![db open]) {
			NSLog(@"Could not open db.");
			//[pool release];
			
		} else {
			NSLog(@"DB Open Success");
		}
		
	}
	
}


-(void) recreateIndex {
	
	updatingIndex = YES;
	
	while ([db inUse]) {
		//
		//NSLog(@"pause");
	}
	
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	NSLog(@"rebuilding index from phrase file...");
	
	[db executeQuery:@"DELETE FROM phrases;"];
	
	NSString * pathOfPhrases = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:PHRASES_TEXT_FILE];
	
	//FILE *file = fopen([pathOfPhrases UTF8String], "r");
	
	// FIXME: this needs to change to a stream if things get big.
	// the below method was just ascii
	NSString * phrases = [[NSString stringWithContentsOfFile:pathOfPhrases encoding:NSUTF8StringEncoding error:nil] retain];
	
	NSArray * lines = [[phrases componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] retain]; 
	
	SearchResult * sr = [[SearchResult alloc] init];
	float total_phrases = [lines count];
	float counter = 0;
	for (NSString * phrase in lines) {
		
		counter ++;
		
		self.updateProgress = counter / total_phrases;
		
		if ( [phrase length] == 0 ) {
			NSLog(@"EMPTY PHRASE");
		} else {
			
			//NSLog(@"line: %@ " , phrase );
			sr.body = phrase;
			[sr insertIntoDb];
			
		}
	}
	
	[lines release];
	
	/*
	// check for NULL
	while(!feof(file))
	{
		
		NSString * line = readLineAsNSString(file);
		NSLog(@"line: %@ " , line );
		
		
	}
	
	fclose(file);
	*/
	
	
	
	NSLog(@"complete!");
	
	[self updateUsedPhrasesWithProperRowIds];
	
	updatingIndex = NO;
	
	[self optimizeIndex];
	
	[pool release];
	
}

-(void) optimizeIndex {
	
	NSLog(@"optimizing index...");
	
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	updatingIndex = YES;
	
	// optimize the FTS index...
	[db executeUpdate:@"INSERT INTO phrases(phrases) VALUES('optimize');"];
	
	if ([db hadError]) {
		
		NSLog(@"optimize Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
		
	} else {
		
		NSLog(@"successful optimize");
		
	}
	
	updatingIndex = NO;
	
	[pool release];
	
}

-(void) updateUsedPhrasesWithProperRowIds {
	
	// query all used phrases..
	
	// loop over them and find each one in the FTS table if it exists..
	
	// then make sure the rowid of the entry in the used_phrases matches the one in the phrases FTS table
	
	
	
}


/*
NSString * readLineAsNSString(FILE *file)
{
    char buffer[4096];
	
    // tune this capacity to your liking -- larger buffer sizes will be faster, but
    // use more memory
    NSMutableString *result = [NSMutableString stringWithCapacity:256];
	
    // Read up to 4095 non-newline characters, then read and discard the newline
    int charsRead;
    do
    {
        if(fscanf(file, "%4095[^\n]%n%*c", buffer, &charsRead) == 1)
            [result appendFormat:@"%s", buffer];
        else
            break;
    } while(charsRead == 4095);
	
    return result;
}
*/		 


-(void) createTables  {
	
	
	[db executeUpdate:@"CREATE VIRTUAL TABLE phrases USING fts3(uses, keywords, body);"];
	
	[db executeUpdate:@"CREATE TABLE used_phrases (rowid integer, uses integer, body text)"];
	
	if ([db hadError]) {
		
		NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
		
	} else {
		
		NSLog(@"create tables success");
		
	}

	
	
}






#pragma mark -
#pragma mark SINGLETON

+ (Model*)instance {
    @synchronized(self) {
        if (instance == nil) {
            [[self alloc] init]; // assignment not done here
        }
    }
    return instance;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (instance == nil) {
            instance = [super allocWithZone:zone];
            return instance;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  //denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}


// setup the data collection
- init {
	if (self = [super init]) {
		
		[self setupModel];
		
	}
	return self;
}


@end
