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


#define DATABASE_FILE @"phrases.sqlite3"
#define PHRASES_TEXT_FILE @"phrases.txt"

@interface Model : NSObject {
	
	
	FMDatabase * db;
	BOOL updatingIndex;
	float updateProgress;
	
}

@property (assign) BOOL updatingIndex;
@property float updateProgress;

@property (nonatomic,assign) FMDatabase * db;

+ (Model *) instance;


@end
