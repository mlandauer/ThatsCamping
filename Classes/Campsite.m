#import "Campsite.h"
#import "Park.h"
#include <math.h>

@implementation Campsite 

@dynamic latitude, longitude, shortName, longName, distance, bearing, park, webId, toilets, picnicTables,
	barbecues, showers, drinkingWater, caravans, trailers, car, textDescription;

// Convenience methods around Core Data
- (BOOL) hasFlushToilets
{
	return [self.toilets isEqualToString:@"flush"];
}

- (BOOL) hasNonFlushToilets
{
	return [self.toilets isEqualToString:@"non_flush"];	
}

- (BOOL) hasToilets
{
	return ![self.toilets isEqualToString:@"none"];
}

- (BOOL) hasWoodBarbecuesFirewoodSupplied
{
	return [self.barbecues isEqualToString:@"wood_supplied"];
}

- (BOOL) hasWoodBarbecuesBringYourOwn
{
	return [self.barbecues isEqualToString:@"wood_bring_your_own"];
}

- (BOOL) hasWoodBarbecues
{
	return ([self.barbecues isEqualToString:@"wood"] ||
			[self hasWoodBarbecuesFirewoodSupplied] || [self hasWoodBarbecuesBringYourOwn]);
}

- (BOOL) hasGasElectricBarbecues
{
	return [self.barbecues isEqualToString:@"gas_electric"];
}

- (BOOL) hasBarbecues
{
	return ![self.barbecues isEqualToString:@"none"];
}

- (BOOL) hasHotShowers
{
	return [self.showers isEqualToString:@"hot"];
}

- (BOOL) hasColdShowers
{
	return [self.showers isEqualToString:@"cold"];
}

- (BOOL) hasShowers
{
	return ![self.showers isEqualToString:@"none"];
}

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

// Methods to support of displaying this data in a map
- (CLLocationCoordinate2D) coordinate
{
	CLLocationCoordinate2D c;
	c.latitude = [[self latitude] doubleValue];
	c.longitude = [[self longitude] doubleValue];
	return c;
}

- (NSString *) title
{
	return self.shortName;
}

- (NSString *) subtitle
{
	return self.park.shortName;
}

@end
