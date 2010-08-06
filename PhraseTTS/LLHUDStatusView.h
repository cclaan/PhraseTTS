//
//  LLHUDStatusView.h
//  iTorch
//
//  Created by Chris Laan on 6/19/10.
//  Copyright 2010 Laan Labs. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LLHUDStatusView : UIView {
	
	UIImageView * imageView;
	
	UIImage * image;
	
	UILabel * label;
	
	UIActivityIndicatorView * spinner;
	
}

@property (nonatomic , retain ) NSString * title;
@property BOOL showSpinner;
@property (nonatomic, retain) UIImage * image;

-(id) initWithTitle:(NSString*)txt image:(UIImage*)img andSpinning:(BOOL)spinning;
-(void) showInView:(UIView*) view;
-(void) hide;

@end
