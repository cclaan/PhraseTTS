//
//  WordSuggestionsView.h
//  PhraseTTS
//
//  Created by Chris Laan on 8/5/10.
//  Copyright 2010 Laan Labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UITextChecker.h>

@interface WordSuggestionsView : UIView {

	UITextChecker * textChecker;
	
	NSMutableArray * buttonList;
	
}

-(void) displaySuggestionsForWord:(NSString*)word;
-(void) clearSuggestions;

@end
