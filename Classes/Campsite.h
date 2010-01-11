#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

@class Park;

@interface Campsite :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber *latitude;
@property (nonatomic, retain) NSNumber *longitude;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *distance;
@property (nonatomic, retain) NSNumber *bearing;
@property (nonatomic, retain) Park *park;
@property (nonatomic, retain) NSString *webId;

- (CLLocation *) location;
- (NSNumber *) distanceFrom:(CLLocation *)location;
- (NSNumber *) bearingFrom:(CLLocation *)location;

@end
