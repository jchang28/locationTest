//
//  ParseStarterProjectViewController.m
//  ParseStarterProject
//
//  Copyright 2014 Parse, Inc. All rights reserved.
//

#import "ParseStarterProjectViewController.h"
#import "LocationViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface ParseStarterProjectViewController ()

@property (weak, nonatomic) IBOutlet UITextView *userInformationTextView;
@property (weak, nonatomic) IBOutlet UIButton *loginLogoutButton;
@property (weak, nonatomic) IBOutlet UIButton *showMapButton;

@end

@implementation ParseStarterProjectViewController

#pragma mark - UIViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Welcome and Log In";
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self _setupUI];
    
    MBProgressHUD *parseRetrieveUserDataHUD = [MBProgressHUD showHUDAddedTo:self.view
                                                      animated:YES];
    //parseRetrieveUserDataHUD.mode = MBProgressHUDModeText;
    parseRetrieveUserDataHUD.labelText = @"Retrieving user data...";
    
    
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Obligations
#pragma mark PFLogInViewController Obligations
- (void)logInViewController:(PFLogInViewController *)logInController
               didLogInUser:(PFUser *)user {
    [self _setupUI];
    
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self _setupUI];
    
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

//Optional
//- (void)logInViewController:(PFLogInViewController *)logInController
//    didFailToLogInWithError:(NSError *)error {
//    
//}


#pragma mark PFSignUpViewController Obligations
- (void)signUpViewController:(PFSignUpViewController *)signUpController
               didSignUpUser:(PFUser *)user {
    [self _setupUI];
    
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    [self _setupUI];
    
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}



#pragma mark -
#pragma mark Privates - UI Setup
- (void)_setupUIAsLoggedIn {
    
    //1.    Updated login/logout button.
    [self.loginLogoutButton setTitle:@"Log Out"
                            forState:UIControlStateNormal];
    
    //2.    Setup selector for proper action.
    [self.loginLogoutButton removeTarget:self
                                  action:@selector(ibLogIn:)
                        forControlEvents:UIControlEventTouchUpInside];
    
    [self.loginLogoutButton addTarget:self
                               action:@selector(ibLogOut:)
                     forControlEvents:UIControlEventTouchUpInside];
    
    //3.    Display the user info.
    self.userInformationTextView.text = [self _getUserInfo];
}

- (void)_setupUIAsLoggedOut {

    //1.    Update the button label.
    [self.loginLogoutButton setTitle:@"Log In"
                            forState:UIControlStateNormal];
    
    //2.    Setup selector for proper action
    [self.loginLogoutButton removeTarget:self
                                  action:@selector(ibLogOut:)
                        forControlEvents:UIControlEventTouchUpInside];
    
    [self.loginLogoutButton addTarget:self
                               action:@selector(ibLogIn:)
                     forControlEvents:UIControlEventTouchUpInside];
    
    //3.    Clear out user info display.
    self.userInformationTextView.text = @"";
}

- (void)_setupUI {
    if([PFUser currentUser]) {
        [self _setupUIAsLoggedIn];
        
        return;
    }
    
    [self _setupUIAsLoggedOut];
}

#pragma mark -
#pragma mark Privates - Utilities
- (NSString *)_getUserInfo {
    PFUser *currentUser = [PFUser currentUser];
    NSMutableString *userInfo = [[NSMutableString alloc] init];
    [userInfo appendFormat:@"User name:[%@].\n", currentUser.username];
    [userInfo appendFormat:@"User email:[%@].\n", currentUser.email];
    [userInfo appendFormat:@"User is[%@].\n", currentUser.isNew ? @"New" : @"Not New"];
    [userInfo appendFormat:@"User session token[%@].\n", currentUser.sessionToken];
    
    return userInfo;
}

- (PFLogInViewController *)_factoryLoginViewController {
    PFLogInViewController *parseLoginViewController = [[PFLogInViewController alloc] init];
//    parseLoginViewController.fields = PFLogInFieldsUsernameAndPassword | PFLogInFieldsLogInButton | PFLogInFieldsFacebook | PFLogInFieldsTwitter;

    parseLoginViewController.delegate = self;
    parseLoginViewController.signUpController.delegate = self;
    
    return parseLoginViewController;
}

#pragma mark -
#pragma mark IBActions
- (IBAction)ibLogOut:(id)sender {
    
    //1.    Log out.
    [PFUser logOut];
    
    //2.    Setup UI
    [self _setupUI];
}

- (IBAction)ibLogIn:(id)sender {
    PFLogInViewController *loginViewController = [self _factoryLoginViewController];
    
    [self presentViewController:loginViewController
                       animated:YES
                     completion:nil];
}

- (IBAction)ibShowMapViewController:(id)sender {
    LocationViewController *locationViewController = [[LocationViewController alloc] initWithNibName:@"LocationViewController"
                                                                                              bundle:nil];
    
    [self.navigationController pushViewController:locationViewController
                                         animated:YES];
}


@end
