//
//  SearchResult.m
//  PhraseTTS
//
//  Created by cclaan on 4/14/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SearchResult.h"
#import "Model.h"

@interface SearchResult()

-(NSString*) stringForUses;

@end


@implementation SearchResult


@synthesize rowid , body , uses;


-(BOOL) insertIntoDb {
	
	FMDatabase * db = [Model instance].db;
	
	[db executeUpdate:@"INSERT INTO phrases(uses, body) VALUES(?, ?);" , [self stringForUses] , self.body ];

	
	if ([db hadError]) {
		
		NSLog(@"Err doing Game inset by name %d: %@", [db lastErrorCode], [db lastErrorMessage]);
		return NO;
		
	} 
	

	return YES;
	
	
}

-(NSString*) stringForUses {
	return [NSString stringWithFormat:@"%i",self.uses];
}

-(BOOL) removeFromDb {
	
	FMDatabase * db = [Model instance].db;
	
	BOOL success = [db executeUpdate:@"DELETE from phrases WHERE rowid = ?" , [NSNumber numberWithInt:self.rowid] ];
	
	if ([db hadError] || !success ) {
		
        NSLog(@"Err doing remove phrase from DB %d: %@", [db lastErrorCode], [db lastErrorMessage]);
		return NO;
	}
	
	
	return YES;
}

-(void) incrementUsesAndSave {
	
	FMDatabase * db = [Model instance].db;
	
	self.uses ++ ;
	
	[db executeUpdate:@"UPDATE phrases SET uses = ? WHERE rowid = ?;" , [NSString stringWithFormat:@"%i",self.uses] , [NSNumber numberWithInt:self.rowid] ];
	
	
}

+(NSArray*) sortedSearchForQuery:(NSString*)query {
	
	
	FMDatabase * db = [Model instance].db;
	
	//FMResultSet *rs = [db executeQuery:@"SELECT * FROM phrases WHERE body MATCH 'sqlite';"];
	
	//FMResultSet *rs = [db executeQuery:@"SELECT * FROM phrases WHERE body MATCH '\"my fun\"';"];
	
	FMResultSet *rs = [db executeQuery:@"SELECT rowid, body, uses FROM phrases WHERE body MATCH ?;" , query ];
	
	NSMutableArray * arr = [[[NSMutableArray alloc] init] autorelease];
	
    while ([rs next]) {
		
		//NSLog(@"%i - %@ - %@" , [rs intForColumn:@"rowid"],[rs stringForColumn:@"body"] , [rs stringForColumn:@"uses"] );
		[arr addObject:[SearchResult searchResultFromResultSet:rs]];
		
    }
	
	[rs close]; 
	
	if ([db hadError]) {
		NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
	}
	
	return arr;
	
	
}


+(SearchResult*) searchResultFromResultSet:(FMResultSet*) rs {
	
	SearchResult * sr = [[[SearchResult alloc] init] autorelease];
	
	sr.rowid = [rs intForColumn:@"rowid"];
	sr.body = [rs stringForColumn:@"body"];
	sr.uses = [[rs stringForColumn:@"uses"] integerValue];
	
	
	return sr;
	
}


@end
