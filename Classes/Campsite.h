// Abstract: A Core Data managed object class to represent an event containing geographical coordinates and a time stamp.

@interface Campsite : NSObject  {
	NSNumber *latitude, *longitude;
	NSString *name;
	// Distance from the current location (in metres)
	NSNumber *distance;
}

@property (nonatomic, retain) NSNumber *latitude;
@property (nonatomic, retain) NSNumber *longitude;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *distance;

@end


