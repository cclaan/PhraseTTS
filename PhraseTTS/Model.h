//
//  Model.h
//  PhraseTTS
//
//  Created by cclaan on 4/9/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "FMResultSet.h"
#import "FliteTTS.h"


#define DATABASE_FILE @"phrases.sqlite3"
#define PHRASES_TEXT_FILE @"phrases.txt"
//#define WORDS_TEXT_FILE @"words_clean.txt"
#define WORDS_TEXT_FILE @"words_short.txt"

@interface Model : NSObject {
	
	
	FMDatabase * db;
	BOOL updatingIndex;
	float updateProgress;
	
	FliteTTS * ttsEngine;
	
	
	
}

@property (assign) BOOL updatingIndex;
@property float updateProgress;

@property (nonatomic,assign) FMDatabase * db;

-(void) speakText:(NSString*)text;
-(void) setVoiceFromKey:(NSString*) key;

+ (Model *) instance;


@end
