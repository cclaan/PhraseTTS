//
//  UICustomSearchBar.m
//  PhraseTTS
//
//  Created by Chris Laan on 8/4/10.
//  Copyright 2010 Laan Labs. All rights reserved.
//

#import "UICustomSearchBar.h"


@implementation UICustomSearchBar


- (UIView *)inputAccessoryView {
	
    if (!inputAccessoryView) {
        CGRect accessFrame = CGRectMake(0.0, 0.0, 768.0, 77.0);
        inputAccessoryView = [[UIView alloc] initWithFrame:accessFrame];
        inputAccessoryView.backgroundColor = [UIColor blueColor];
        UIButton *compButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        compButton.frame = CGRectMake(313.0, 20.0, 158.0, 37.0);
        [compButton setTitle: @"Word Completions" forState:UIControlStateNormal];
        [compButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [compButton addTarget:self action:@selector(completeCurrentWord:)
			 forControlEvents:UIControlEventTouchUpInside];
        [inputAccessoryView addSubview:compButton];
    }
    return inputAccessoryView;
}


@end
