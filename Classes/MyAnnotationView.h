//
// Copyright (C) 2010 Matthew Landauer and Katherine Szuminska
//

#import <MapKit/MapKit.h>

@protocol AnnotationSelectedDelegate <NSObject>
- (void) annotationSelected:(id <MKAnnotation>)annotation;
@end

@interface MyAnnotationView : MKPinAnnotationView {
	id <AnnotationSelectedDelegate> delegate;
}

@property (nonatomic, retain) id <AnnotationSelectedDelegate> delegate;

@end
