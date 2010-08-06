    //
//  SettingsViewController.m
//  PhraseTTS
//
//  Created by Chris Laan on 8/4/10.
//  Copyright 2010 Laan Labs. All rights reserved.
//

#import "SettingsViewController.h"
#import "MultipleChoiceSettingsController.h"
#import "Constants.h"
#import "Model.h"
#import "SearchResult.h"

@implementation SettingsViewController


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        
    }
    return self;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	// Custom initialization
	self.navigationItem.title = @"Settings";
	
}

-(void) viewWillAppear:(BOOL)animated {
	
	[tableView reloadData];
	
}


-(void) autoCorrectSwitched:(id) sender {
	
	UISwitch * sw = (UISwitch*)sender;
	BOOL on = sw.on;
	
	NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
	[defs setBool:sw.on forKey:kAutoCorrectKey];
	
	
	
}

-(void) showKeyboardSelection {
	
	//NSLog(@"keyboard");
	MultipleChoiceSettingsController * msc = [[MultipleChoiceSettingsController alloc] initWithItems:[NSArray arrayWithObjects:
																									  [NSDictionary dictionaryWithObjectsAndKeys:@"QWERTY",@"label",kQWERTYKeyboard,@"key",nil],
																									 [NSDictionary dictionaryWithObjectsAndKeys:@"ABCD",@"label",kABCDKeyboard,@"key",nil],
																									 nil
																									  ]];
	msc.key = kKeyboardTypeKey;
	msc.navigationItem.title = @"Select Keyboard";
	msc.delegate = self;
	[self.navigationController pushViewController:msc animated:YES];
	[msc release];
	
}

-(void) showVoiceSelection {
	
	//NSLog(@"voice");

	MultipleChoiceSettingsController * msc = [[MultipleChoiceSettingsController alloc] initWithItems:[NSArray arrayWithObjects:
																									  [NSDictionary dictionaryWithObjectsAndKeys:@"Male",@"label",kMaleVoice,@"key",nil],
																									  [NSDictionary dictionaryWithObjectsAndKeys:@"Female",@"label",kFemaleVoice,@"key",nil],
																									  [NSDictionary dictionaryWithObjectsAndKeys:@"Male 2",@"label",kMaleVoice2,@"key",nil],
																									  [NSDictionary dictionaryWithObjectsAndKeys:@"Male 3",@"label",kMaleVoice3,@"key",nil],
																									  [NSDictionary dictionaryWithObjectsAndKeys:@"Male 4",@"label",kMaleVoice4,@"key",nil],
																									  nil
																									  ]];
	
	//msc.key = @"blah";
	msc.key = kVoiceKey;
	msc.navigationItem.title = @"Select Voice";
	msc.delegate = self;
	[self.navigationController pushViewController:msc animated:YES];
	[msc release];
	
}

-(void) multipleChoice:(MultipleChoiceSettingsController*)msc didSelectItemWithKey:(NSString*)key {
	
	NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
	
	NSLog(@"KEY: %@" , key);
	
	[defs setObject:key forKey:msc.key];
	[self.navigationController popViewControllerAnimated:YES];
	
	 
	if ( [msc.key isEqualToString:kKeyboardTypeKey] ) {
		
		
		
	} else if ( [msc.key isEqualToString:kVoiceKey] ) {
		
		[[Model instance] setVoiceFromKey:key];
		
	}
}

-(void) clearSearchHistory {
	
	UIAlertView * al = [[UIAlertView alloc] initWithTitle:@"Clear History?" message:@"Do you want to delete all of your phrase history? This can't be undone." delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes, Delete",nil];
	[al show];
	[al release];
	
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex { 
	
	if ( buttonIndex == 0 ) {
		NSLog(@"Cancel");
	} else if ( buttonIndex == 1 ) {
		
		// delete
		[SearchResult clearSearchHistory];
		
		
	}
	
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
	switch (section) {
		case 0:
			return 3;
			break;
		case 1:
			return 1;
			break;
	}
	
	return 0;
	
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	
	// for the record im not happy with this implementation... 
	
	UITableViewCell *cell = nil;
	NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
	
	switch (indexPath.section) {
			
		case 0: {	
			switch (indexPath.row) {
				case 0:
					cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"keyboardCell"] autorelease];
					cell.textLabel.text = @"Keyboard Type";
					
					cell.detailTextLabel.text = [defs objectForKey:kKeyboardTypeKey];
					
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					break;
				case 1:
					cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"autoCell"] autorelease];
					cell.textLabel.text = @"Auto-correct on";
					UISwitch * sw = [[UISwitch alloc] init];
					
					sw.on = [defs boolForKey:kAutoCorrectKey];
					[sw addTarget:self action:@selector(autoCorrectSwitched:) forControlEvents:UIControlEventValueChanged];
					cell.accessoryView = sw;
					break;
				case 2:
					cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Voice"] autorelease];
					cell.textLabel.text = @"Voice";
					
					cell.detailTextLabel.text = [defs objectForKey:kVoiceKey];
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					break;
			}
			break;
		}
		
		case 1: {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"clearHistoryCell"] autorelease];
			cell.textLabel.textAlignment = UITextAlignmentCenter;
			cell.textLabel.text = @"Clear Search History";
			
			break;
		}
	}
	
	
	
	/*
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    */
	
    // Configure the cell...
    
    return cell;
			 
			 
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */


/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }   
 }
 */


/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	
	switch (indexPath.section) {
			
		case 0: {	
			switch (indexPath.row) {
				case 0:
					[self showKeyboardSelection];
					break;
				case 1:
					/// nothing
					break;
				case 2:
					[self showVoiceSelection];
					break;
			}
			break;
		}
			
		case 1: {
			[self clearSearchHistory];
			break;
		}
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	
}




- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
