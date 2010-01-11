#import "Campsite.h"
#import "Park.h"

@implementation Campsite 

@dynamic latitude, longitude, name, distance, park, webId;

- (CLLocation *) location
{
	return [[[CLLocation alloc] initWithLatitude:[[self latitude] doubleValue] longitude:[[self longitude] doubleValue]] autorelease];
}

@end
