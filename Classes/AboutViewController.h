//
// Copyright (C) 2010 Matthew Landauer and Katherine Szuminska
//

#import <UIKit/UIKit.h>

@protocol AboutDoneDelegate <NSObject>
- (void) aboutDone;
@end

@interface AboutViewController : UIViewController
{
	UIWebView *webView;
	id <AboutDoneDelegate> delegate;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) id <AboutDoneDelegate> delegate;

- (IBAction)doneButtonPressed:(id)sender;

@end
