//
//  LoadingView.h
//  TimeLapse
//
//  Created by cclaan on 9/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LoadingView : UIView {
	
	UIActivityIndicatorView * spinner;
	UILabel * infoLabel;
	UIImageView * bgImage;
	BOOL fadeBackground;
	UIView * bgView;
	
	
}	

@property BOOL fadeBackground;
@property ( nonatomic, retain ) UIActivityIndicatorView * spinner;
@property ( nonatomic, retain ) UILabel * infoLabel;
@property ( nonatomic, retain ) UIImageView * bgImage;
@property ( nonatomic, retain ) UIView * bgView;


-(void) showInView:(UIView*) view;
-(void) showInMainWindow;
-(void) sizeViews;
-(void) setLabel:(NSString*) text;
-(void) hide;

@end
