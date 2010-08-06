//
//  WordSuggestionsView.m
//  PhraseTTS
//
//  Created by Chris Laan on 8/5/10.
//  Copyright 2010 Laan Labs. All rights reserved.
//

#import "WordSuggestionsView.h"
#import "SearchResult.h"

@implementation WordSuggestionsView


- (id) init
{
	self = [super initWithFrame:CGRectMake(0, 0, 768, 80)];
	if (self != nil) {
		
		self.backgroundColor = [UIColor lightGrayColor];
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		buttonList = [[NSMutableArray alloc] init];
		
	}
	return self;
}

-(void) displaySuggestionsForWord:(NSString*)word {
	
	if ( !textChecker ) {
		textChecker = [[UITextChecker alloc] init];
	}
	
	//self.completionRange = [self computeCompletionRange];
    // The UITextChecker object is cached in an instance variable
	
	// this list is useless...
    //NSArray *possibleCompletions = [textChecker completionsForPartialWordRange:NSMakeRange(0, [word length]) inString:word language:@"en"];
	
	NSArray *possibleCompletions = [SearchResult getWordCompletions:word];
	
	// as is this one..
	//NSArray *possibleCompletions = [textChecker guessesForWordRange:NSMakeRange(0, [word length]) inString:word language:@"en"];
	
	
	[self removeAllButtons];
	
	int count = 0;
	int bw = ((self.frame.size.width - (9*8+16)) / 10.);
	
	for (NSString*s in possibleCompletions) {
		
		NSLog(@"WorD: %@ " , s);
		
		UIButton * button = nil;
		
		if ( [buttonList count] > count)  {
			button = [buttonList objectAtIndex:count];
		} else {
			
			button = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
			button.titleLabel.font = [UIFont boldSystemFontOfSize:26];
			button.titleLabel.textColor = [UIColor blackColor];
			button.titleLabel.adjustsFontSizeToFitWidth = YES;
			
			[buttonList	addObject:button];			
		}
		
		[button setTitle:s forState:UIControlStateNormal];
		button.frame = CGRectMake(count*(bw+8) + 8, 2, bw, self.frame.size.height-4);
		button.titleLabel.text = s;
		
		[self addSubview:button];
		
		count++;
		
		if ( count == 10 ) return;
	}
	
	
	
	
}

-(void) clearSuggestions {
	[self removeAllButtons];
}

-(void) removeAllButtons {
	
	for (UIButton * b in buttonList) {
		
		[b removeFromSuperview];
		
	}
	
}

/*
- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        
		// Initialization code
		
		
		
    }
    return self;
}
*/
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
    [super dealloc];
}


@end
