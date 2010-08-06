//
//  LoadingView.m
//  TimeLapse
//
//  Created by cclaan on 9/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LoadingView.h"


@interface LoadingView()

-(UIWindow*) getMainWindow;
-(void) createUi;
-(void) createBg;
-(void) sizeBg:(UIView*)v;

@end


@implementation LoadingView

@synthesize bgImage, spinner, infoLabel, fadeBackground, bgView;

- (id) init
{
	self = [super init];
	if (self != nil) {
		[self createUi];
	}
	return self;
}



-(void) createUi {
	
	self.frame = CGRectMake(0, 0, 150, 50);
	self.backgroundColor = [UIColor clearColor];
	
	UIImage * img = [UIImage imageNamed:@"black_rounded_rect_s9_dark.png"];
	img = [img stretchableImageWithLeftCapWidth:4 topCapHeight:4];
	bgImage = [[UIImageView alloc] initWithImage:img];
	[self addSubview:bgImage];
	
	spinner = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	[spinner startAnimating];
 	[self addSubview:spinner];
	
	infoLabel = [[UILabel alloc] init];
	infoLabel.backgroundColor= [UIColor clearColor];
	infoLabel.text = @"";
	infoLabel.textColor = [UIColor whiteColor];
	infoLabel.font = [UIFont boldSystemFontOfSize:17.];
	infoLabel.textAlignment = UITextAlignmentCenter;
	[self addSubview:infoLabel];
	
	
	
}

-(void) createBg {
	
	bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
	bgView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.65];
	
	
}

-(UIWindow*) getMainWindow {
	
	UIWindow * mainWindow = [[UIApplication sharedApplication] keyWindow];
	
	NSArray * windows = [[UIApplication sharedApplication] windows];
	
	if ( mainWindow == nil ) {
		if ( [windows count] > 0 )
			mainWindow = (UIWindow*)[windows objectAtIndex:0];
	}
	
	return mainWindow;
	
}


-(void) showInView:(UIView*) view {
	
	if ( fadeBackground ) {
		
		if ( !bgView ) [self createBg];
		
		[self sizeBg:view];
		bgView.alpha = 0.0;
		[view addSubview:bgView];
		
		
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.3];
		bgView.alpha = 0.6;
		[UIView commitAnimations];
		
	}
	
	
	
	[view addSubview:self];
	[self sizeViews];
	
}

-(void) showInMainWindow {
	
	UIWindow * view = [self getMainWindow];
	
	if ( fadeBackground ) {
		
		if ( !bgView ) [self createBg];
		
		[self sizeBg:view];
		bgView.alpha = 0.0;
		[view addSubview:bgView];
		
		
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.3];
		bgView.alpha = 0.6;
		[UIView commitAnimations];
		
	}
	

	
	[view addSubview:self];
	[self sizeViews];
	
}

-(void) hide {
	
	if ( bgView ) {
		
		[bgView removeFromSuperview];
		[bgView release];
		bgView = nil;
		
	}
	
	[super removeFromSuperview];
	
}

-(void) removeFromSuperview {
	
	if ( bgView ) {
		
		[bgView removeFromSuperview];
		[bgView release];
		bgView = nil;
		
	}
	
	[super removeFromSuperview];
	
}

-(void) setLabel:(NSString*) text {
	
	//if ( !infoLabel ) [self createUi];
	
	infoLabel.text = text;
	[self sizeViews];
	
}

-(void) sizeBg:(UIView*)forView {
	
	bgView.frame = forView.bounds;
	//bgView.frame = CGRectMake(0, 0, 320, 480);
	
}

-(void) sizeViews {
	
	[infoLabel sizeToFit];
	
	self.frame = CGRectMake(0, 0, infoLabel.frame.size.width+68, 30);
	bgImage.frame = self.frame;
	infoLabel.frame = CGRectMake(40, 3, infoLabel.frame.size.width, infoLabel.frame.size.height);
	
	
	spinner.frame = CGRectMake(3, self.frame.size.height/2.-10, 20, 20);
	self.center = self.superview.center;
	
	
	
	
	
	
	
	
}

//
//- (void)drawRect:(CGRect)rect {
//    // Drawing code
//}


- (void)dealloc {
	
	[bgView release];
	[spinner release];
	[infoLabel release];
	[bgImage release];
    [super dealloc];
	
}


@end
