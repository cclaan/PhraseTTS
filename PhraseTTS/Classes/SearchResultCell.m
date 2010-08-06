//
//  SearchResultCell.m
//  PhraseTTS
//
//  Created by Chris Laan on 8/4/10.
//  Copyright 2010 Laan Labs. All rights reserved.
//

#import "SearchResultCell.h"
#import "Constants.h"

@implementation SearchResultCell

@synthesize searchResultOne , searchResultTwo;
@synthesize clickDelegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
		
		resultButtonOne = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		resultButtonOne.frame = CGRectMake(0, 0, 400, CELL_HEIGHT);
		//resultButtonOne.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin; 
		resultButtonOne.titleLabel.font = [UIFont boldSystemFontOfSize:26];
		resultButtonOne.titleLabel.adjustsFontSizeToFitWidth = YES;
		resultButtonOne.titleLabel.minimumFontSize = 14;
		resultButtonOne.titleLabel.textColor = [UIColor blackColor];
		[resultButtonOne setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		
		[resultButtonOne addTarget:self action:@selector(resultOneClicked) forControlEvents:UIControlEventTouchUpInside];
		[resultButtonOne addTarget:self action:@selector(buttonDown:) forControlEvents:UIControlEventTouchDown];
		[resultButtonOne addTarget:self action:@selector(buttonUp:) forControlEvents:UIControlEventTouchUpInside];
		[resultButtonOne addTarget:self action:@selector(buttonUp:) forControlEvents:UIControlEventTouchUpOutside];
		[resultButtonOne addTarget:self action:@selector(buttonUp:) forControlEvents:UIControlEventTouchCancel];
		
		//resultButtonTwo = [[UIButton alloc] initWithFrame:CGRectMake(404, 0, 400, CELL_HEIGHT)];
		resultButtonTwo = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		resultButtonTwo.frame = CGRectMake(404, 0, 400, CELL_HEIGHT);
		//resultButtonTwo.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		resultButtonTwo.titleLabel.font = [UIFont boldSystemFontOfSize:26];
		resultButtonTwo.titleLabel.adjustsFontSizeToFitWidth = YES;
		resultButtonTwo.titleLabel.minimumFontSize = 14;
		resultButtonTwo.titleLabel.textColor = [UIColor blackColor];
		[resultButtonTwo setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		
		[resultButtonTwo addTarget:self action:@selector(resultTwoClicked) forControlEvents:UIControlEventTouchUpInside];
		[resultButtonTwo addTarget:self action:@selector(buttonDown:) forControlEvents:UIControlEventTouchDown];
		[resultButtonTwo addTarget:self action:@selector(buttonUp:) forControlEvents:UIControlEventTouchUpInside];
		[resultButtonTwo addTarget:self action:@selector(buttonUp:) forControlEvents:UIControlEventTouchUpOutside];
		[resultButtonTwo addTarget:self action:@selector(buttonUp:) forControlEvents:UIControlEventTouchCancel];
		
		[self.contentView addSubview:resultButtonOne];
		[self.contentView addSubview:resultButtonTwo];
		
		
		// TODO: make the plus buttons work
		plusButtonOne = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		[plusButtonOne setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		[plusButtonOne setBackgroundColor:[UIColor lightGrayColor]];
		[plusButtonOne setTitle:@"+" forState:UIControlStateNormal];
		plusButtonOne.titleLabel.font = [UIFont boldSystemFontOfSize:36];
		plusButtonOne.hidden = YES;
		
		plusButtonTwo = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		
		[plusButtonTwo setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		[plusButtonTwo setBackgroundColor:[UIColor lightGrayColor]];
		[plusButtonTwo setTitle:@"+" forState:UIControlStateNormal];
		plusButtonTwo.titleLabel.font = [UIFont boldSystemFontOfSize:36];
		plusButtonTwo.hidden = YES;
		
		if ( SHOW_PLUS_BUTTONS ) {
			[self.contentView addSubview:plusButtonOne];
			[self.contentView addSubview:plusButtonTwo];
		} else {
			dividerView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width/2-2, 0, 2, self.frame.size.height)];
			dividerView.backgroundColor= [UIColor colorWithWhite:0.9 alpha:1.0];
			[self.contentView addSubview:dividerView];
			
		}
    }
    return self;
}

// left side..
-(void) setLeftSearchResult:(SearchResult*) result {
	
	self.searchResultOne = result;
	
	//NSString * cellBody = [NSString stringWithFormat:@"%i %@" , result.uses , result.body];
	//[resultButtonOne setTitle:cellBody forState:UIControlStateNormal];
	
	[resultButtonOne setTitle:result.body forState:UIControlStateNormal];
	
	
	plusButtonOne.hidden = (result == nil);
	
}

// right side...
-(void) setRightSearchResult:(SearchResult*) result {
	
	self.searchResultTwo = result;
	
	//NSString * cellBody = [NSString stringWithFormat:@"%i %@" , result.uses , result.body];
	//[resultButtonTwo setTitle:cellBody forState:UIControlStateNormal];
	
	[resultButtonTwo setTitle:result.body forState:UIControlStateNormal];
	

	plusButtonTwo.hidden = (result == nil);
	
}

-(void) buttonDown:(id) sender {
	
	UIButton * button  = (UIButton*)sender;
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[button setBackgroundColor:[UIColor blueColor]];
	
	
}

-(void) buttonUp:(id) sender {
	UIButton * button  = (UIButton*)sender;
	[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[button setBackgroundColor:[UIColor whiteColor]];
	
}

-(void) resultOneClicked {
	
	if ( self.searchResultOne == nil ) {
		return;
	}
	
	if ( self.clickDelegate ) {
		
		[self.clickDelegate performSelector:@selector(resultClicked:) withObject:searchResultOne];
		
	}
	
}

-(void) resultTwoClicked {
	
	if ( self.searchResultTwo == nil ) {
		return;
	}
		
	if ( self.clickDelegate ) {
		
		[self.clickDelegate performSelector:@selector(resultClicked:) withObject:searchResultTwo];
		
	}
	
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	
	//[super setSelected:selected animated:animated];

}

-(void) layoutSubviews {
	[super layoutSubviews];
	
	if ( SHOW_PLUS_BUTTONS ) {
		resultButtonOne.frame = CGRectMake(0, 0, self.frame.size.width/2 - PLUS_BUTTON_WIDTH, CELL_HEIGHT);
		resultButtonTwo.frame = CGRectMake(self.frame.size.width/2, 0, self.frame.size.width/2 - PLUS_BUTTON_WIDTH, CELL_HEIGHT);
	} else {
		resultButtonOne.frame = CGRectMake(0, 0, self.frame.size.width/2, CELL_HEIGHT);
		resultButtonTwo.frame = CGRectMake(self.frame.size.width/2, 0, self.frame.size.width/2, CELL_HEIGHT);
	}
	
	plusButtonOne.frame = CGRectMake(self.frame.size.width/2 - PLUS_BUTTON_WIDTH, 0, PLUS_BUTTON_WIDTH, CELL_HEIGHT);
	plusButtonTwo.frame = CGRectMake(self.frame.size.width - PLUS_BUTTON_WIDTH, 0, PLUS_BUTTON_WIDTH, CELL_HEIGHT);
	
	
	dividerView.frame = CGRectMake(self.frame.size.width/2-2, 0, 2, self.frame.size.height);
	
}


- (void)dealloc {
	
    [super dealloc];
	
	[searchResultOne release];
	searchResultOne = nil;
	[searchResultTwo release];
	searchResultTwo = nil;
	
	[resultButtonOne release];
	resultButtonOne = nil;
	
	[resultButtonTwo release];
	resultButtonTwo = nil;
	
	[plusButtonOne release];
	plusButtonOne = nil;
	
	[plusButtonTwo release];
	plusButtonTwo = nil;
	
	
}


@end
