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



@end


@implementation SearchResult


@synthesize rowid , body , uses;

-(BOOL) checkIfExistsAndPopulateIfSo {

	BOOL exists = NO;
	
	FMDatabase * db = [Model instance].db;
	
	NSString * noPunc = [[self.body componentsSeparatedByCharactersInSet:[NSCharacterSet punctuationCharacterSet]] componentsJoinedByString:@""];
	
	// SELECT phrases.rowid, phrases.body, used_phrases.uses FROM phrases LEFT OUTER JOIN used_phrases ON phrases.rowid = used_phrases.rowid WHERE phrases.no_punc_body MATCH ? ORDER BY used_phrases.uses DESC;
	FMResultSet *rs = [db executeQuery:@"SELECT rowid FROM phrases WHERE no_punc_body = ?;" , noPunc ];
	
	int _rowid = 0;// = [db lastInsertRowId];
	
	while ([rs next]) {
		
		_rowid = [rs intForColumn:@"rowid"];
		exists = YES;
		
	}
	[rs close];
	
	self.rowid = _rowid;
	
	
	rs = [db executeQuery:@"SELECT uses FROM used_phrases WHERE rowid = ?;" , [NSNumber numberWithInt:self.rowid] ];
	
	while ([rs next]) {
		self.uses = [rs intForColumn:@"uses"];
	}
	[rs close];
	
	return exists;
	
}

-(BOOL) insertIntoDb {
	
	FMDatabase * db = [Model instance].db;
	
	//NSString * noPunc = [self.body stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@",.'?!@#$%^&*()-+\"\/><:;"]];
	NSString * noPunc = [[self.body componentsSeparatedByCharactersInSet:[NSCharacterSet punctuationCharacterSet]] componentsJoinedByString:@""];
							   
	//NSLog(@"%@" , noPunc )
	
	[db executeUpdate:@"INSERT INTO phrases(body, no_punc_body) VALUES(?, ?);" , self.body , noPunc ];

	
	if ([db hadError]) {
		
		NSLog(@"Err doing phrase insert %d: %@", [db lastErrorCode], [db lastErrorMessage]);
		return NO;
		
	} 
	
	// FIXME: 
	// the rowid wont be set in this object unless its uses are greater than 0... 
	// just the way the app indexes at load, it would slow that down a lot to re-query, unless the [db lastInsertRowId]; works, or im missing something
	
	if ( self.uses > 0 ) {
		
		// last row id doesnt seem to work here... there should be a better way...
		int _rowid = 0;// = [db lastInsertRowId];
		
		FMResultSet *rs = [db executeQuery:@"SELECT rowid FROM phrases WHERE no_punc_body = ?;" , noPunc ];
		
		while ([rs next]) {
			
			_rowid = [rs intForColumn:@"rowid"];
			
		}
		
		//NSLog(@"rowid: %i ", _rowid );
		
		self.rowid = _rowid;
		
		[db executeUpdate:@"INSERT INTO used_phrases(rowid, uses) VALUES(?, ?);" , [NSNumber numberWithInt:self.rowid], [NSNumber numberWithInt:self.uses]];
		
		if ([db hadError]) {
			
			NSLog(@"Err doing used phrase insert %d: %@", [db lastErrorCode], [db lastErrorMessage]);
			//return NO;
			
		} 
		
	}
	

	return YES;
	
	
}

/*
-(BOOL) insertIntoUsedPhrasesTable {
	
	FMDatabase * db = [Model instance].db;
	
	//NSString * noPunc = [self.body stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@",.'?!@#$%^&*()-+\"\/><:;"]];
	NSString * noPunc = [[self.body componentsSeparatedByCharactersInSet:[NSCharacterSet punctuationCharacterSet]] componentsJoinedByString:@""];
	
	NSLog(@"%@" , noPunc );
	
	//[db executeUpdate:@"INSERT INTO used_phrases(rowid, uses, body, no_punc_body) VALUES(?, 1, ?, ?);" ,[NSNumber numberWithInt:self.rowid] , self.body , noPunc ];
	[db executeUpdate:@"INSERT INTO used_phrases(rowid, uses) VALUES(?, 1);" ,[NSNumber numberWithInt:self.rowid] , self.body , noPunc ];
	
	if ([db hadError]) {
		
		NSLog(@"Err doing Game inset by name %d: %@", [db lastErrorCode], [db lastErrorMessage]);
		return NO;
		
	} 
	
	
	return YES;
	
	
}
*/



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
	
	FMResultSet *rs = [db executeQuery:@"SELECT rowid, uses FROM used_phrases WHERE rowid = ?;" , [NSNumber numberWithInt:self.rowid] ];
	
	//NSMutableArray * arr = [[[NSMutableArray alloc] init] autorelease];
	int count = 0;
	
    while ([rs next]) {
		
		count++;
		
    }
	
	if ( count == 0 ) {
		
		[db executeUpdate:@"INSERT INTO used_phrases(rowid, uses) VALUES(?, 1);" , [NSNumber numberWithInt:self.rowid], [NSNumber numberWithInt:self.uses]];
		
		if ([db hadError]) {
			
			NSLog(@"Err doing used phrase insert %d: %@", [db lastErrorCode], [db lastErrorMessage]);
			//return NO;
			
		} 
		
	}
	
	self.uses ++ ;
	
	[db executeUpdate:@"UPDATE used_phrases SET uses = ? WHERE rowid = ?;" , [NSNumber numberWithInt:self.uses] , [NSNumber numberWithInt:self.rowid] ];
	
	if ([db hadError]) {
		
		NSLog(@"Err updating used phrase use count %d: %@", [db lastErrorCode], [db lastErrorMessage]);
		//return NO;
		
	} 
	
}

+(void) clearSearchHistory {
	
	FMDatabase * db = [Model instance].db;
	
	[db executeUpdate:@"DELETE FROM used_phrases;"];
	
	if ([db hadError]) {
		NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
	}
	
}

+(NSArray*) sortedSearchForQuery:(NSString*)query {
	
	if ( [query length] == 0 ) return nil;
	
	FMDatabase * db = [Model instance].db;
	
	//FMResultSet *rs = [db executeQuery:@"SELECT * FROM phrases WHERE body MATCH 'sqlite';"];
	//FMResultSet *rs = [db executeQuery:@"SELECT * FROM phrases WHERE body MATCH '\"my fun\"';"];
	
	NSString * noPunc = [[query componentsSeparatedByCharactersInSet:[NSCharacterSet punctuationCharacterSet]] componentsJoinedByString:@""];
	
	// add * to specify partial matches on words...b
	if ( [noPunc characterAtIndex:([noPunc length]-1)] != ' ' ) {
		NSLog(@"no space");
		noPunc = [noPunc stringByAppendingString:@"*"];
	}
	
	// SELECT * FROM phrases LEFT OUTER JOIN used_phrases ON phrases.rowid = used_phrases.rowid;
	// SELECT phrases.body,used_phrases.uses FROM phrases LEFT OUTER JOIN used_phrases ON phrases.rowid = used_phrases.rowid WHERE phrases.no_punc_body MATCH 'hav*';
	// SELECT phrases.body,used_phrases.uses FROM phrases LEFT OUTER JOIN used_phrases ON phrases.rowid = used_phrases.rowid WHERE phrases.no_punc_body MATCH 'hav*' ORDER BY used_phrases.uses DESC;
	
	//FMResultSet *rs = [db executeQuery:@"SELECT rowid, body, uses FROM phrases WHERE no_punc_body MATCH ?;" , noPunc ];
	FMResultSet *rs = [db executeQuery:@"SELECT phrases.rowid, phrases.body, used_phrases.uses FROM phrases LEFT OUTER JOIN used_phrases ON phrases.rowid = used_phrases.rowid WHERE phrases.no_punc_body MATCH ? ORDER BY used_phrases.uses DESC;" , noPunc ];
	
	NSMutableArray * arr = [[[NSMutableArray alloc] init] autorelease];
	
    while ([rs next]) {
		
		//NSLog(@"%i - %@ - %@" , [rs intForColumn:@"rowid"],[rs stringForColumn:@"body"] , [rs stringForColumn:@"uses"] );
		[arr addObject:[SearchResult searchResultFromResultSet:rs]];
		
    }
	
	[rs close]; 
	
	if ([db hadError]) {
		NSLog(@"Err %d: %@", [db lastErrorCode], [db lastErrorMessage]);
	}
	
	
	
	/// this is tough....
	
	BOOL addORSearch = NO;
	
	if ( addORSearch && [noPunc rangeOfString:@" "].length == 1 && [noPunc rangeOfString:@" "].location != ([noPunc length]-1) ) {
		
		NSString * orPhrase = [noPunc stringByReplacingOccurrencesOfString:@" " withString:@" OR "];
		NSLog(@"OR: %@" , orPhrase);
		FMResultSet *rs = [db executeQuery:@"SELECT rowid, body, uses FROM phrases WHERE no_punc_body MATCH ? ORDER BY uses DESC;" , orPhrase ];
		
		
		while ([rs next]) {
			
			SearchResult * sr = [SearchResult searchResultFromResultSet:rs];
			
			BOOL alreadyExists = NO;
			
			for (SearchResult * sr2 in arr) {
				if ( sr.rowid == sr2.rowid ) {
					alreadyExists = YES;
					break;
				}
			}
			
			if ( !alreadyExists ) {
				[arr addObject:sr];
			}
			
		}
		
		
		[rs close]; 
		
		
	}
	
	
	return arr;
	
	
}

//+(NSArray*) sortedSearchFromUsedPhrases:(NSString*)query {
+(NSArray*) getTopUsedPhrases {	
	
	FMDatabase * db = [Model instance].db;
	
	//FMResultSet *rs = [db executeQuery:@"SELECT * FROM phrases WHERE body MATCH 'sqlite';"];
	//FMResultSet *rs = [db executeQuery:@"SELECT * FROM phrases WHERE body MATCH '\"my fun\"';"];
	
	/*
	NSString * noPunc;
	
	if ( [query length] != 0 ) {
		
		noPunc = [[query componentsSeparatedByCharactersInSet:[NSCharacterSet punctuationCharacterSet]] componentsJoinedByString:@""];
		noPunc = [@"%" stringByAppendingString:[noPunc stringByAppendingString:@"%"]];
		NSLog(@"USed: %@" , noPunc);
		
	} else {
		
		noPunc = query;
		
	}
	*/
	
	/*
	// add * to specify partial matches on words...b
	if ( [noPunc characterAtIndex:([noPunc length]-1)] != ' ' ) {
		NSLog(@"no space");
		noPunc = [noPunc stringByAppendingString:@"*"];
	}
	*/
	
	FMResultSet *rs;
	
	// SELECT phrases.rowid, phrases.body,used_phrases.uses FROM phrases LEFT OUTER JOIN used_phrases ON phrases.rowid = used_phrases.rowid where used_phrases.uses > 0 ORDER BY used_phrases.uses DESC;
	
	rs = [db executeQuery:@"SELECT phrases.rowid, phrases.body,used_phrases.uses FROM phrases LEFT OUTER JOIN used_phrases ON phrases.rowid = used_phrases.rowid where used_phrases.uses > 0 ORDER BY used_phrases.uses DESC;" ];
	
	/*
	if ( [noPunc length] != 0 ) {
		rs = [db executeQuery:@"SELECT rowid, body, uses FROM used_phrases WHERE no_punc_body LIKE ?;" , noPunc ];
	} else {
		rs = [db executeQuery:@"SELECT rowid, body, uses FROM used_phrases;" ];
	}
	*/
	
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

+(NSArray*) getWordCompletions:(NSString*)word  {	
	
	FMDatabase * db = [Model instance].db;
	
	//FMResultSet *rs = [db executeQuery:@"SELECT * FROM phrases WHERE body MATCH 'sqlite';"];
	//FMResultSet *rs = [db executeQuery:@"SELECT * FROM phrases WHERE body MATCH '\"my fun\"';"];
	
	/*
	 NSString * noPunc;
	 
	 if ( [query length] != 0 ) {
	 
	 noPunc = [[query componentsSeparatedByCharactersInSet:[NSCharacterSet punctuationCharacterSet]] componentsJoinedByString:@""];
	 noPunc = [@"%" stringByAppendingString:[noPunc stringByAppendingString:@"%"]];
	 NSLog(@"USed: %@" , noPunc);
	 
	 } else {
	 
	 noPunc = query;
	 
	 }
	 */
	
	/*
	 // add * to specify partial matches on words...b
	 if ( [noPunc characterAtIndex:([noPunc length]-1)] != ' ' ) {
	 NSLog(@"no space");
	 noPunc = [noPunc stringByAppendingString:@"*"];
	 }
	 */
	
	word = [word stringByAppendingString:@"%"];
	
	FMResultSet *rs;
	
	// SELECT phrases.rowid, phrases.body,used_phrases.uses FROM phrases LEFT OUTER JOIN used_phrases ON phrases.rowid = used_phrases.rowid where used_phrases.uses > 0 ORDER BY used_phrases.uses DESC;
	
	rs = [db executeQuery:@"SELECT word FROM words WHERE word LIKE ? ORDER BY rank DESC LIMIT 10" , word ];
	
	/*
	 if ( [noPunc length] != 0 ) {
	 rs = [db executeQuery:@"SELECT rowid, body, uses FROM used_phrases WHERE no_punc_body LIKE ?;" , noPunc ];
	 } else {
	 rs = [db executeQuery:@"SELECT rowid, body, uses FROM used_phrases;" ];
	 }
	 */
	
	NSMutableArray * arr = [[[NSMutableArray alloc] init] autorelease];
	
    while ([rs next]) {
		
		//NSLog(@"%i - %@ - %@" , [rs intForColumn:@"rowid"],[rs stringForColumn:@"body"] , [rs stringForColumn:@"uses"] );
		//[arr addObject:[SearchResult searchResultFromResultSet:rs]];
		[arr addObject:[rs stringForColumn:@"word"]];
		
		
    }
	
	[rs close]; 
	
	if ([db hadError]) {
		NSLog(@"Err searching words %d: %@", [db lastErrorCode], [db lastErrorMessage]);
	}
	
	return arr;
	
}



+(SearchResult*) searchResultFromResultSet:(FMResultSet*) rs {
	
	SearchResult * sr = [[[SearchResult alloc] init] autorelease];
	
	sr.rowid = [rs intForColumn:@"rowid"];
	sr.body = [rs stringForColumn:@"body"];
	//sr.uses = [[rs stringForColumn:@"uses"] integerValue];
	sr.uses = [rs intForColumn:@"uses"];
	
	return sr;
	
}


@end
