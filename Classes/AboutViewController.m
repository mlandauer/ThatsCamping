//
// Copyright (C) 2010 Matthew Landauer and Katherine Szuminska
//

#import "AboutViewController.h"

@implementation AboutViewController

@synthesize webView, delegate;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	// Add content to the web page
	NSURL *baseURL = [NSURL URLWithString:@"http://foo.co.uk/"];
	NSString *htmlFilePath = [[NSBundle mainBundle] pathForResource:@"About" ofType:@"html"];
	NSData *htmlData = [[NSFileManager defaultManager] contentsAtPath:htmlFilePath];
	[webView loadData:htmlData MIMEType:@"text/html" textEncodingName:@"utf-8" baseURL:baseURL];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (IBAction)doneButtonPressed:(id)sender
{
	[delegate aboutDone];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		[[UIApplication sharedApplication] openURL:request.URL];
		return NO;
	}
	else {
		return YES;
	}

}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
