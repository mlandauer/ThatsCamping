#import "Campsite.h"
#import "Park.h"
#include <math.h>

@implementation Campsite 

@dynamic latitude, longitude, shortName, distance, bearing, park, webId;

- (CLLocation *) location
{
	return [[[CLLocation alloc] initWithLatitude:[[self latitude] doubleValue] longitude:[[self longitude] doubleValue]] autorelease];
}

// Distance (in metres) to this campsite from the given location
- (NSNumber *) distanceFrom:(CLLocation *)location
{
	return [NSNumber numberWithDouble:[location getDistanceFrom:[self location]]];
}

// Bearing (as an angle) to this campsite from the given location
- (NSNumber *) bearingFrom:(CLLocation *)location
{
	double lon1 = location.coordinate.longitude * M_PI / 180.0;
	double lat1 = location.coordinate.latitude * M_PI / 180.0;
	double lon2 = [self location].coordinate.longitude * M_PI / 180.0;
	double lat2 = [self location].coordinate.latitude * M_PI / 180.0;
	
	double dLon = lon2 - lon1;
	
	double y = sin(dLon) * cos(lat2);
	double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
	// This is a number between 0 and 360
	double bearing = fmod(atan2(y, x) * 180.0 / M_PI + 360.0, 360.0);
	return [NSNumber numberWithDouble:bearing];
}

@end
