//
//  LoginPageViewController.m
//  Galendar
//
//  Created by Zorzin on 05.01.2017.
//  Copyright © 2017 Zorzin. All rights reserved.
//

#import "LoginPageViewController.h"
#import "MasterViewController.h"

@interface LoginPageViewController ()

@end

@implementation LoginPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // TODO(developer) Configure the sign-in button look/feel
    
    [GIDSignIn sharedInstance].uiDelegate = self;
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(receiveToggleAuthUINotification:)
     name:@"ToggleAuthUINotification"
     object:nil];
    
    
    // Uncomment to automatically sign in the user.
//    [[GIDSignIn sharedInstance] signInSilently];
    [self toggleAuthUI];
    self.statusText.text = @"Google Sign in\niOS Demo";
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self toggleAuthUI];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapSignOut:(id)sender {
    [[GIDSignIn sharedInstance] signOut];
    [self toggleAuthUI];
}

- (void)toggleAuthUI {
    if ([GIDSignIn sharedInstance].currentUser.authentication == nil) {
        // Not signed in
        self.statusText.text = @"Google Sign in\niOS Demo";
        self.signInButton.hidden = NO;
        self.signOutButton.hidden = YES;
        self.disconnectButton.hidden = YES;
    } else {
        // Signed in
        self.signInButton.hidden = YES;
        self.signOutButton.hidden = NO;
        self.disconnectButton.hidden = NO;
    }
}
// [END toggle_auth]

- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    // Perform any operations on signed in user here.
    NSString *userId = user.userID;                  // For client-side use only!
    NSString *idToken = user.authentication.idToken; // Safe to send to the server
    NSString *name = user.profile.name;
    NSString *email = user.profile.email;
    NSLog(@"Customer details: %@ %@ %@ %@", userId, idToken, name, email);
    // ...
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:@"ToggleAuthUINotification"
     object:nil];
    
}

- (void) receiveToggleAuthUINotification:(NSNotification *) notification {
    if ([notification.name isEqualToString:@"ToggleAuthUINotification"]) {
        [self toggleAuthUI];
        UISplitViewController *masterViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SplitViewController"];
        [self presentViewController:masterViewController animated:NO completion:nil];
        self.statusText.text = notification.userInfo[@"statusText"];
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
