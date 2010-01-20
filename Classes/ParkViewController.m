//
// Copyright (C) 2010 Matthew Landauer and Katherine Szuminska
//

#import "ParkViewController.h"
#import "CampsiteViewController.h"

@implementation ParkViewController

@synthesize currentPark, campsites, locationManager;

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

- (void)viewDidLoad {
    [super viewDidLoad];

	self.title = [currentPark shortName];
	
	// Create an array out of the set of campsites returned from Core Data
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"longName" ascending:YES];
	self.campsites = [[[currentPark campsites] allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	[sortDescriptor release];
	
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		if ([[currentPark textDescription] isEqualToString:@""])
			return 1;
		else
			return 2;
	}
	else
		return [campsites count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section == 1)
		return @"Campsites";
	else
		return nil;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
	
	// Defaults (unless overridden below)
	cell.textLabel.numberOfLines = 1;
	cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	if (indexPath.section == 0) {
		if (indexPath.row == 0) {
			cell.textLabel.text = currentPark.longName;
			cell.textLabel.numberOfLines = 2;
		}
		else if (indexPath.row == 1) {
			cell.textLabel.text = currentPark.textDescription;
			cell.textLabel.numberOfLines = 0;
			UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:13.0];
			cell.textLabel.font = cellFont;
		}
	}
	else if (indexPath.section == 1) {
		cell.textLabel.text = [[campsites objectAtIndex:indexPath.row] longName];
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	}
    return cell;
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == 0 && indexPath.row == 1) {
		NSString *cellText = currentPark.textDescription;
		UIFont *cellFont = [UIFont fontWithName:@"Helvetica" size:13.0];
		CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
		CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:UILineBreakModeWordWrap];
		
		return labelSize.height + 20;
	}
	return aTableView.rowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 1) {
		CampsiteViewController *campsiteViewController = [[CampsiteViewController alloc] initWithNibName:@"CampsiteViewController" bundle:nil];
		campsiteViewController.campsite = [campsites objectAtIndex:indexPath.row];
		// TODO: Get rid of this passing coordinates around nonsense
		campsiteViewController.locationManager = locationManager;
		[self.navigationController pushViewController:campsiteViewController animated:YES];
		[campsiteViewController release];
	}
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	[self tableView:tableView didSelectRowAtIndexPath:indexPath];
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


- (void)dealloc {
    [super dealloc];
}


@end

