#import <CoreData/CoreData.h>

@class Park;

@interface Campsite :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber *latitude;
@property (nonatomic, retain) NSNumber *longitude;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *distance;
@property (nonatomic, retain) Park *park;

@end
