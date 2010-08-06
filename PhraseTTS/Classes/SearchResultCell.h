//
//  SearchResultCell.h
//  PhraseTTS
//
//  Created by Chris Laan on 8/4/10.
//  Copyright 2010 Laan Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchResult.h"


@interface SearchResultCell : UITableViewCell {
	
	SearchResult * searchResultOne;
	SearchResult * searchResultTwo;
	
	UIButton * resultButtonOne;
	UIButton * resultButtonTwo;
	
	UIButton * plusButtonOne;
	UIButton * plusButtonTwo;
	
	id clickDelegate;
	
	UIView * dividerView;
	
}

@property (nonatomic, retain) SearchResult * searchResultOne;
@property (nonatomic, retain) SearchResult * searchResultTwo;
@property (assign) id clickDelegate;

-(void) setLeftSearchResult:(SearchResult*) result;
-(void) setRightSearchResult:(SearchResult*) result;


@end
