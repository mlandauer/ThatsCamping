// Application delegate to set up the Core Data stack and configure the view and navigation controllers.

@interface ThatsCampingAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
	
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) UINavigationController *navigationController;

- (IBAction)saveAction:sender;

@property (nonatomic, readonly) NSString *applicationDocumentsDirectory;

@end
