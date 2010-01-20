#import <UIKit/UIKit.h>


@interface AboutViewController : UIViewController
{
	UIWebView *webView;
	UIViewController *delegate;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) UIViewController *delegate;

- (IBAction)doneButtonPressed:(id)sender;

@end
