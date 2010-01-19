#import <CoreData/CoreData.h>


@interface Park :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * shortName;
@property (nonatomic, retain) NSString * longName;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSString * webId;
@property (nonatomic, retain) NSSet * campsites;
@property (nonatomic, retain) NSString * textDescription;

@end



