//
//  UICustomSearchBar.h
//  PhraseTTS
//
//  Created by Chris Laan on 8/4/10.
//  Copyright 2010 Laan Labs. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UICustomSearchBar : UISearchBar {
	
	UIView * inputAccessoryView;
	
}

@property (nonatomic, retain) UIView * inputAccessoryView;

@end
