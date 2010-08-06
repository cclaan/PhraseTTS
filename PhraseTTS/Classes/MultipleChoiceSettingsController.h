//
//  MultipleChoiceSettingsController.h
//  PhraseTTS
//
//  Created by Chris Laan on 8/4/10.
//  Copyright 2010 Laan Labs. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MultipleChoiceSettingsController : UIViewController <UITableViewDataSource , UITableViewDelegate> {
	
	NSArray * items;
	id delegate;
	
	IBOutlet UITableView * tableView;
	NSString * key;
	
}
@property (nonatomic, retain) NSString * key;
@property (nonatomic, retain) NSArray * items;
@property (nonatomic, retain) id delegate;


@end
