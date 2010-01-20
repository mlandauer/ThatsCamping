//
// Copyright (C) 2010 Matthew Landauer and Katherine Szuminska
//

#import "MyAnnotationView.h"

@implementation MyAnnotationView

@synthesize delegate;

// Override this method so that we can get access to when the pins on the maps are clicked and selected
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	[super setSelected:selected animated:animated];
	if (selected) {
		[delegate annotationSelected:self.annotation];
	}
}

@end
