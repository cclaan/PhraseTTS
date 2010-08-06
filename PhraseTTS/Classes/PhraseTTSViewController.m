//
//  PhraseTTSViewController.m
//  PhraseTTS
//
//  Created by Chris Laan on 8/3/10.
//  Copyright Laan Labs 2010. All rights reserved.
//

#import "PhraseTTSViewController.h"
#import "SearchResultCell.h"
#import "Model.h"
#import "Constants.h"

@implementation PhraseTTSViewController

@synthesize searchBar , tableView, currentSearchResults , searchTextField;


/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	
	//searchTextField.inputView = [[UIView alloc] init];
	
	// Observe keyboard hide and show notifications to resize the text view appropriately.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	
	
	
}

-(void) viewWillAppear:(BOOL)animated {
	
	if ( [Model instance].updatingIndex ) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(phraseDbReady) name:@"PhraseDatabaseReady" object:nil];
	} else {
		[self phraseDbReady];
	}
	
	
	NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
	BOOL ac = [defs boolForKey:kAutoCorrectKey];
	
	if ( ac ) {
		searchTextField.autocorrectionType = UITextAutocorrectionTypeYes;
	} else {
		searchTextField.autocorrectionType = UITextAutocorrectionTypeNo;
	}
}

-(void) phraseDbReady {
	
	[self searchTable];
	
}

-(void) searchTable {
	
	if ( [Model instance].updatingIndex ) {
		NSLog(@"model is updating... %3.2f " , [Model instance].updateProgress );
		[self performSelector:@selector(searchTable) withObject:nil afterDelay:0.1];
		return;
	}
	
	//NSString * query = searchBar.text;
	NSString * query = searchTextField.text;
	
	NSMutableArray * arr = nil;
	
	if ( [query length] == 0 ) {
		
		// perform the recent lookup
		//arr = (NSMutableArray*)[[SearchResult sortedSearchFromUsedPhrases: query ] retain];
		arr = (NSMutableArray*)[[SearchResult getTopUsedPhrases] retain];
		
	} else {
		
		arr = (NSMutableArray*)[[SearchResult sortedSearchForQuery: query ] retain];
		
	}
	
	
	
	
	NSLog(@"total: %i " , [arr count] );
	
	self.currentSearchResults = arr;
	[tableView reloadData];
	
	
	
	
	/*SearchResult * sr = [[SearchResult alloc] init];
	 sr.body = @"My favorite phrase today peanuts";
	 [sr insertIntoDb];
	 */
	
}


#pragma mark -
#pragma mark Responding to keyboard events

- (void)keyboardWillShow:(NSNotification *)notification {
    
    /*
     Reduce the size of the text view so that it's not obscured by the keyboard.
     Animate the resize so that it's in sync with the appearance of the keyboard.
     */
	
    NSDictionary *userInfo = [notification userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
	
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    CGFloat keyboardTop = keyboardRect.origin.y;
    CGRect newTextViewFrame = tableView.frame;
    newTextViewFrame.size.height = keyboardTop - tableView.frame.origin.y;
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    tableView.frame = newTextViewFrame;
	
    [UIView commitAnimations];
}


- (void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary* userInfo = [notification userInfo];
    
    /*
     Restore the size of the text view (fill self's view).
     Animate the resize so that it's in sync with the disappearance of the keyboard.
     */
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    
    tableView.frame = CGRectMake(0, 44, self.view.bounds.size.width, self.view.bounds.size.height - 44);
    
    [UIView commitAnimations];
}

#pragma mark -
#pragma mark UITextField Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(searchTable) object:nil];
	[self performSelector:@selector(searchTable) withObject:nil afterDelay:0.1];
	
	if ( USE_WORD_LIST ) {
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayedWordCheck) object:nil];
		[self performSelector:@selector(delayedWordCheck) withObject:nil afterDelay:0.5];
	}
	
	return YES;
}

-(void) delayedWordCheck {
	
	[wordSuggestionsView displaySuggestionsForWord:searchTextField.text];
	
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(searchTable) object:nil];
	[self performSelector:@selector(searchTable) withObject:nil afterDelay:0.06];
	
	return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	//[searchTextField becomeFirstResponder];
	
	
	
	if ( USE_WORD_LIST ) {
		
		
		 
		if (searchTextField.inputAccessoryView == nil) {
			
			wordSuggestionsView = [[WordSuggestionsView alloc] init];
			
			searchTextField.inputAccessoryView = wordSuggestionsView;    
			
			
		}
	
	}
	
	
	return YES;
	
}

#pragma mark -
#pragma mark Accessory view action

- (IBAction)tappedMe:(id)sender {
    /*
    // When the accessory view button is tapped, add a suitable string to the text view.
    NSMutableString *text = [textView.text mutableCopy];
    NSRange selectedRange = textView.selectedRange;
    
    [text replaceCharactersInRange:selectedRange withString:@"You tapped me.\n"];
    textView.text = text;
    [text release];
	 */
	
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
	//[searchTextField resignFirstResponder];
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	
	if ( [searchTextField.text length] > 0 ) {
		//FIXME: this doesnt check if this exact phrase exists already in the DB
		SearchResult * sr = [[SearchResult alloc] init];
		sr.body = textField.text;
		sr.uses = 1;
		//[sr insertIntoUsedPhrasesTable];
		[sr insertIntoDb];
		[sr release];
		
		[[Model instance] speakText:searchTextField.text];
		
	}
	
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	
}



#pragma mark -
#pragma mark Search Bar Delegate 

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	return YES;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(searchTable) object:nil];
	[self performSelector:@selector(searchTable) withObject:nil afterDelay:0.06];
	 
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
	return YES;
}


- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
	return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
	
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
	
}



#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return CELL_HEIGHT;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
 
	if ( currentSearchResults == nil ) {
		
		return 0;
		
	} else {
		
		return ceil([currentSearchResults count] / 2.0 );
		
	}
	
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    SearchResultCell *cell = (SearchResultCell*)[_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[SearchResultCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.clickDelegate = self;
    }
    
	// each cell has two items...
	[cell setLeftSearchResult:[currentSearchResults objectAtIndex:(indexPath.row*2)]];
	
	// make sure there is an item on the right side of the cell...
	if ( (indexPath.row+1)*2 <= [currentSearchResults count] ) {
		[cell setRightSearchResult:[currentSearchResults objectAtIndex:(indexPath.row*2 + 1)]];
	} else {
		[cell setRightSearchResult:nil];
	}
	
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

-(void) resultClicked:(SearchResult*) result {
	
	NSLog(@"result clicked: %@ " , result.body );
	
	[[Model instance] speakText: result.body ];
	
	[result incrementUsesAndSave];
	
	/*
	SearchResult * sr = [[SearchResult alloc] init];
	sr.rowid = result.rowid;
	sr.body = result.body;
	[sr insertIntoUsedPhrasesTable];
	[sr release];
	*/
	
	
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    
	[super dealloc];
	
	[searchBar release];
	searchBar = nil;
	
	[tableView release];
	tableView = nil;
	
	[currentSearchResults release];
	currentSearchResults = nil;
	
}

@end
