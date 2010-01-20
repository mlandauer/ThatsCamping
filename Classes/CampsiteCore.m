//
// Copyright (C) 2010 Matthew Landauer and Katherine Szuminska
//

#import "CampsiteCore.h"

@implementation CampsiteCore

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

@end
