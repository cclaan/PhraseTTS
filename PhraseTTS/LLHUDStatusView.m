//
//  LLHUDStatusView.m
//  iTorch
//
//  Created by Chris Laan on 6/19/10.
//  Copyright 2010 Laan Labs. All rights reserved.
//

#import "LLHUDStatusView.h"
#import <QuartzCore/QuartzCore.h>

@implementation LLHUDStatusView

@synthesize title, image, showSpinner;


- (id) init
{
	self = [super init];
	if (self != nil) {
		
		self.layer.cornerRadius = 9;
		self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.7];
		self.opaque = NO;
		
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

-(id) initWithTitle:(NSString*)txt image:(UIImage*)img andSpinning:(BOOL)spinning {
	
	
	self = [super init];
	if (self != nil) {
		
		self.layer.cornerRadius = 9;
		
		
		
		//self.layer.shadowOpacity = 1.0;
		//self.layer.shadowRadius = 2.0;
		//self.layer.shadowOffset = CGSizeMake(0.1, 0.1);
		//self.layer.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0].CGColor;
		
		self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.74];
		
		//self.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.7];
		
		self.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.35].CGColor;
		self.layer.borderWidth = 1;
		
		
		//self.opaque = NO;
		
		self.showSpinner = spinning;
		self.image = img;
		self.title = txt;
		
	}
	
	return self;
	
}

-(void) setImage:(UIImage *)img {
	
	if ( img == nil ) return;
	
	if ( !imageView ) {
		imageView = [[UIImageView alloc] init];
	}
	
	imageView.image = img;
	imageView.frame = CGRectMake(0, 0, img.size.width, img.size.height);
	image = img;
	
	
}

-(void) setTitle:(NSString *) txt {
	
	if ( !label ) {
		
		label = [[UILabel alloc] init];
		label.backgroundColor = [UIColor clearColor];
		label.font = [UIFont boldSystemFontOfSize:15.0];
		label.textColor = [UIColor whiteColor];
		label.textAlignment = UITextAlignmentCenter;
		label.frame = CGRectMake(0, 4, 132, 22);
		label.shadowColor = [UIColor colorWithWhite:0.0 alpha:1.0];
		label.shadowOffset = CGSizeMake(0, 2);
		
	}
	label.text = txt;
	title = [txt retain];
	
}

-(void) setShowSpinner:(BOOL) b {
	
	if ( b ) {
		
		if ( !spinner ) {
			spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		}
		
		if ( self.superview ) {
			[self addSubview:spinner];
			[spinner startAnimating];
		}
		
	} else {
		
		if ( spinner ) {
			[spinner stopAnimating];
			[spinner removeFromSuperview];
		} 
		
	}
	
	showSpinner = b;
	
}

-(void) showInView:(UIView*) view {
	
	self.center = view.center;
	
	CGRect fr;
	fr.size.height = 132;
	fr.size.width = 132;
	fr.origin.x = view.center.x - fr.size.width/2.0;
	fr.origin.y = view.center.y - fr.size.height/2.0;
	
	self.frame = fr;
	
	if ( self.image != nil ) {
		[self addSubview:imageView];
		imageView.center = CGPointMake(self.bounds.size.width/2.0, self.bounds.size.height/2.0); 
	}
	
	if ( self.showSpinner ) {
		[self addSubview:spinner];
		spinner.frame = CGRectMake(fr.size.width/2.0-11, (fr.size.height-18)-11, 22, 22);
		[spinner startAnimating];
	}
	
	if ( self.title ) {
		[self addSubview:label];
	}
	
	
	
	self.alpha = 0.0;
	
	[view addSubview:self];
	
	[UIView beginAnimations:@"fadeIn" context:nil];
	[UIView setAnimationDuration:0.4];
	[UIView setAnimationDelegate:self];
	
	self.alpha = 1.0;
	
	[UIView commitAnimations];
	
	
}

-(void) hide {
	
	[UIView beginAnimations:@"fadeOut" context:nil];
	[UIView setAnimationDuration:0.7];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(fadeOutDone)];
	self.alpha = 0.0;
	
	[UIView commitAnimations];
	
}

-(void) fadeOutDone {

	[self removeFromSuperview];
	
}	

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
    [super dealloc];
	
	self.image = nil;
	self.title = nil;
	[spinner release];
	spinner = nil;
	[imageView release];
	imageView=nil;
	[label release];
	label = nil;
	
}


@end
