#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

@class Park;

@interface Campsite :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber *latitude;
@property (nonatomic, retain) NSNumber *longitude;
@property (nonatomic, retain) NSString *shortName;
@property (nonatomic, retain) NSString *longName;
@property (nonatomic, retain) NSNumber *distance;
@property (nonatomic, retain) NSNumber *bearing;
@property (nonatomic, retain) Park *park;
@property (nonatomic, retain) NSString *webId;
@property (nonatomic, retain) NSString *toilets;
@property (nonatomic, retain) NSNumber *picnicTables;
@property (nonatomic, retain) NSString *barbecues;
@property (nonatomic, retain) NSString *showers;
@property (nonatomic, retain) NSNumber *drinkingWater;
@property (nonatomic, retain) NSNumber *caravans;
@property (nonatomic, retain) NSNumber *trailers;
@property (nonatomic, retain) NSNumber *car;

- (CLLocation *) location;
- (NSNumber *) distanceFrom:(CLLocation *)location;
- (NSNumber *) bearingFrom:(CLLocation *)location;

@end
