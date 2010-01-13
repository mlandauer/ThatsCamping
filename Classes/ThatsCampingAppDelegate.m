// Abstract: Application delegate to set up the Core Data stack and configure the view and navigation controllers.

#import "ThatsCampingAppDelegate.h"
#import "NearestCampsitesViewController.h"
#import "Park.h"
#import "Campsite.h"

@implementation ThatsCampingAppDelegate

@synthesize window;
@synthesize navigationController;


#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	// Configure and show the window.
	
	NearestCampsitesViewController *rootViewController = [[NearestCampsitesViewController alloc] initWithNibName:@"NearestCampsitesViewController" bundle:nil];
	
	NSManagedObjectContext *context = [self managedObjectContext];
	if (!context) {
		// Handle the error.
	}
	rootViewController.managedObjectContext = context;
	
	UINavigationController *aNavigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
	self.navigationController = aNavigationController;
	
	[window addSubview:[navigationController view]];
	[window makeKeyAndVisible];
	
	[rootViewController release];
	[aNavigationController release];
	
	// Now check the data store has been initialised
	[self initialiseStore];
}

/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
	
    NSError *error;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			// Handle the error.
        } 
    }
}


#pragma mark -
#pragma mark Saving

/**
 Performs the save action for the application, which is to send the save:
 message to the application's managed object context.
 */
- (IBAction)saveAction:(id)sender {
	
    NSError *error;
    if (![[self managedObjectContext] save:&error]) {
		// Handle error
    }
}


#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"Locations.sqlite"]];
	
	NSError *error;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
        // Handle the error.
    }    
	
    return persistentStoreCoordinator;
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
	
    [managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
    
	[navigationController release];
	[window release];
	[super dealloc];
}

- (NSPersistentStore *)persistentStore {
	NSArray *persistentStores = [[managedObjectContext persistentStoreCoordinator] persistentStores];
	assert([persistentStores count] == 1);
	return [persistentStores objectAtIndex:0];
}

- (BOOL)isStoreInitialised {
	
	NSDictionary *metadata = [[self persistentStore] metadata];
	// TODO: Check for metadata == nill
	return ([[metadata objectForKey:@"loaded"] boolValue] == YES);
}

- (void)setStoreInitialised {	
	NSPersistentStore *persistentStore = [self persistentStore];
	NSDictionary *metadata = [persistentStore metadata];
	// TODO: Check for metadata == nill
	NSMutableDictionary *newMetadata = [[metadata mutableCopy] autorelease];
    [newMetadata setObject:[NSNumber numberWithBool:YES] forKey:@"loaded"];
	[persistentStore setMetadata:newMetadata];
}

// Load the data store with initial data (if necessary). Will only actually do anything once.
// TODO: Probably should do this earlier in the proceedings. I would say the ThatsCampingAppDelegate would be a fairly logical place.
- (void)initialiseStore {
	if (![self isStoreInitialised]) {
		// Read the parks data from the property list
		NSString *parksPath = [[NSBundle mainBundle] pathForResource:@"Parks" ofType:@"plist"];
		id parksPList;
		NSEnumerator *enumerator = [[NSArray arrayWithContentsOfFile:parksPath] objectEnumerator];
		while (parksPList = [enumerator nextObject]) {
			Park *park = (Park *)[NSEntityDescription insertNewObjectForEntityForName:@"Park" inManagedObjectContext:managedObjectContext];
			[park setShortName:[parksPList objectForKey:@"shortName"]];
			[park setLongName:[parksPList objectForKey:@"longName"]];
			[park setWebId:[parksPList objectForKey:@"webId"]];
		}
		
		// Now retrieve all the parks from the store
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Park" inManagedObjectContext:managedObjectContext];
		[request setEntity:entity];
		NSError *error = nil;
		NSArray *parks = [managedObjectContext executeFetchRequest:request error:&error];
		
		// Read the data from the property lists and store it in the datastore
		NSString *campsitesPath = [[NSBundle mainBundle] pathForResource:@"Campsites" ofType:@"plist"];
		id campsitePList;
		enumerator = [[NSArray arrayWithContentsOfFile:campsitesPath] objectEnumerator];
		while (campsitePList = [enumerator nextObject])
		{
			// TODO: Hmmm.. Must be a shorthand way of doing this: the names of the attributes match up with the method names
			Campsite *campsite = (Campsite *)[NSEntityDescription insertNewObjectForEntityForName:@"Campsite" inManagedObjectContext:managedObjectContext];
			campsite.shortName = [campsitePList objectForKey:@"shortName"];
			campsite.longName = [campsitePList objectForKey:@"longName"];
			campsite.latitude = [campsitePList objectForKey:@"latitude"];
			campsite.longitude = [campsitePList objectForKey:@"longitude"];
			campsite.webId = [campsitePList objectForKey:@"webId"];
			campsite.toilets = [campsitePList objectForKey:@"toilets"];
			campsite.picnicTables = [campsitePList objectForKey:@"picnicTables"];
			campsite.barbecues = [campsitePList objectForKey:@"barbecues"];
			campsite.showers = [campsitePList objectForKey:@"showers"];
			campsite.drinkingWater = [campsitePList objectForKey:@"drinkingWater"];
			campsite.caravans = [campsitePList objectForKey:@"caravans"];
			campsite.trailers = [campsitePList objectForKey:@"trailers"];
			campsite.car = [campsitePList objectForKey:@"car"];
			
			// Now wire up the park (by looking up the park using the webId)
			NSString *parkWebId = [campsitePList objectForKey:@"parkWebId"];
			NSPredicate *predicate = [NSPredicate predicateWithFormat:@"webId == %@", parkWebId];
			NSArray *park = [parks filteredArrayUsingPredicate:predicate];
			assert([park count] == 1);
			[campsite setPark:[park lastObject]];
		}
		
		// Commit the change.
		if ([managedObjectContext save:&error]) {
			// This way we only load the data into the store once
			[self setStoreInitialised];
		}
		else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	}
}

@end
