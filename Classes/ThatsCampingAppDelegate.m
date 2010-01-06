// Abstract: Application delegate to set up the Core Data stack and configure the view and navigation controllers.

#import "ThatsCampingAppDelegate.h"
#import "RootViewController.h"


@implementation ThatsCampingAppDelegate

@synthesize window;
@synthesize navigationController;


#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	// Configure and show the window.
	
	RootViewController *rootViewController = [[RootViewController alloc] initWithStyle:UITableViewStylePlain];
	
	UINavigationController *aNavigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
	self.navigationController = aNavigationController;
	
	[window addSubview:[navigationController view]];
	[window makeKeyAndVisible];
	
	[rootViewController release];
	[aNavigationController release];
}

/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {	
}


#pragma mark -
#pragma mark Saving

/**
 Performs the save action for the application, which is to send the save:
 message to the application's managed object context.
 */
- (IBAction)saveAction:(id)sender {
}


#pragma mark -
#pragma mark Application's documents directory

/**
 Returns the path to the application's documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	
	[navigationController release];
	[window release];
	[super dealloc];
}


@end
