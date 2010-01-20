#import "Park.h"
#import	"CampsiteCore.h"

int main(int argc, char *argv[])
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	NSLog(@"Have run application!");

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *applicationDocumentsDirectory = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;

    NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
	
	NSString *storePath = [applicationDocumentsDirectory stringByAppendingPathComponent: @"ThatsCamping.sqlite"];
	// If the sqlite database exists blast it away and regenerate it
	NSError *error;
	[[NSFileManager defaultManager] removeItemAtPath:storePath error:&error];
	
    NSURL *storeUrl = [NSURL fileURLWithPath: storePath];
    NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: managedObjectModel];
	
	// Do automatic lightweight migrations
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
							 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
							 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {
        // Handle the error.
    }    

    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] init];
	[managedObjectContext setPersistentStoreCoordinator: persistentStoreCoordinator];

	// Read in data from property list (depends on working directory being the project directory)
	
	// Read the parks data from the property list
	id parksPList;
	NSString *parksPath = [[NSBundle mainBundle] pathForResource:@"Parks" ofType:@"plist"];
	NSEnumerator *enumerator = [[NSArray arrayWithContentsOfFile:parksPath] objectEnumerator];
	while (parksPList = [enumerator nextObject]) {
		Park *park = (Park *)[NSEntityDescription insertNewObjectForEntityForName:@"Park" inManagedObjectContext:managedObjectContext];
		park.shortName = [parksPList objectForKey:@"shortName"];
		park.longName = [parksPList objectForKey:@"longName"];
		park.webId = [parksPList objectForKey:@"webId"];
		park.textDescription = [parksPList objectForKey:@"description"];
		NSLog(@"Read in park %@", park.longName);
	}

	// Now retrieve all the parks from the store
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Park" inManagedObjectContext:managedObjectContext];
	[request setEntity:entity];
	error = nil;
	NSArray *parks = [managedObjectContext executeFetchRequest:request error:&error];
	
	// Read the data from the property lists and store it in the datastore
	NSString *campsitesPath = [[NSBundle mainBundle] pathForResource:@"Campsites" ofType:@"plist"];
	id campsitePList;
	enumerator = [[NSArray arrayWithContentsOfFile:campsitesPath] objectEnumerator];
	while (campsitePList = [enumerator nextObject])
	{
		// TODO: Hmmm.. Must be a shorthand way of doing this: the names of the attributes match up with the method names
		CampsiteCore *campsite = (CampsiteCore *)[NSEntityDescription insertNewObjectForEntityForName:@"Campsite" inManagedObjectContext:managedObjectContext];
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
		campsite.textDescription = [campsitePList objectForKey:@"description"];
		
		// Now wire up the park (by looking up the park using the webId)
		NSString *parkWebId = [campsitePList objectForKey:@"parkWebId"];
		NSEnumerator *enumerator = [parks objectEnumerator];
		id park;
		while ((park = [enumerator nextObject])) {
			if ([[park webId] isEqualToString:parkWebId]) {
				campsite.park = park;
				break;
			}
		}
	}
	
	// Commit the change.
	if (![managedObjectContext save:&error]) {
		// Handle the error
	}
	
	[pool release];
}
