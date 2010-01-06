// Abstract: A Core Data managed object class to represent an event containing geographical coordinates and a time stamp.

@interface Campsite : NSManagedObject  {
}

@property (nonatomic, retain) NSNumber *latitude;
@property (nonatomic, retain) NSNumber *longitude;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *distance;

@end


