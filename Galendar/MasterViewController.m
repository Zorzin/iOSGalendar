//
//  MasterViewController.m
//  Galendar
//
//  Created by Zorzin on 05.01.2017.
//  Copyright © 2017 Zorzin. All rights reserved.
//
#import <AppAuth/AppAuth.h>
#import <GTMAppAuth/GTMAppAuth.h>
#import <QuartzCore/QuartzCore.h>
#import "MasterViewController.h"
#import "DetailViewController.h"
#import "User.h"
#import "GTMSessionFetcher.h"
#import "GTMSessionFetcherService.h"
#import "AppDelegate.h"
@interface MasterViewController ()<OIDAuthStateChangeDelegate,
OIDAuthStateErrorDelegate>

@property NSMutableArray *objects;
@end

@implementation MasterViewController

static NSString *const kIssuer = @"https://accounts.google.com";
static NSString *const kClientID = @"771428174670-83blj1mg19jdtudmp61jo669pkpslbjt.apps.googleusercontent.com";
static NSString *const kRedirectURI = @"com.googleusercontent.apps.771428174670-83blj1mg19jdtudmp61jo669pkpslbjt:/oauthredirect";
static NSString *const kAppAuthExampleAuthStateKey = @"authState";
static NSString *const kKeychainItemName = @"Google Calendar API";
OIDServiceConfiguration *configuration ;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    
    
    // Create a UITextView to display output.
    self.output = [[UITextView alloc] initWithFrame:self.view.bounds];
    self.output.editable = false;
    self.output.contentInset = UIEdgeInsetsMake(20.0, 0.0, 20.0, 0.0);
    self.output.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.output];
    
    
    
    configuration= [GTMAppAuthFetcherAuthorization configurationForGoogle];
    [self authWithAutoCodeExchange:nil];
    
    [self fetchEvents];
}


- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)insertNewObject:(id)sender {
    if (!self.objects) {
        self.objects = [[NSMutableArray alloc] init];
    }
    [User setEmail:@"mail"];
    [self.objects insertObject:[User getEmail] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}


#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDate *object = self.objects[indexPath.row];
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        [controller setDetailItem:object];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    NSDate *object = self.objects[indexPath.row];
    cell.textLabel.text = [object description];
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}





- (void)setGtmAuthorization:(GTMAppAuthFetcherAuthorization*)authorization {
    if ([_authorization isEqual:authorization]) {
        return;
    }
    _authorization = authorization;
    [self stateChanged];
}
- (void)stateChanged {
    [self saveState];
}

- (void)saveState {
    if (_authorization.canAuthorize) {
        [GTMAppAuthFetcherAuthorization saveAuthorization:_authorization
                                        toKeychainForName:kClientID];
    } else {
        [GTMAppAuthFetcherAuthorization removeAuthorizationFromKeychainForName:kClientID];
    }
}

////API STUFF
//
//// When the view appears, ensure that the Google Calendar API service is authorized, and perform API calls.
//- (void)viewDidAppear:(BOOL)animated {
//    if (!self.service.authorizer.canAuthorize) {
//        // Not yet authorized, request authorization by pushing the login UI onto the UI stack.
//        //[self presentViewController:[self createAuthController] animated:YES completion:nil];
//    }
//    else {
//            [self setGtmAuthorization:nil];
//        }
//    }
//
// Construct a query and get a list of upcoming events from the user calendar. Display the
// start dates and event summaries in the UITextView.
- (void)fetchEvents {
    GTLQueryCalendar *query = [GTLQueryCalendar queryForEventsListWithCalendarId:@"primary"];
    query.maxResults = 10;
    query.timeMin = [GTLDateTime dateTimeWithDate:[NSDate date]
                                         timeZone:[NSTimeZone localTimeZone]];;
    query.singleEvents = YES;
    query.orderBy = kGTLCalendarOrderByStartTime;
    
    [self.service executeQuery:query
                      delegate:self
             didFinishSelector:@selector(displayResultWithTicket:finishedWithObject:error:)];
}

//- (void)displayResultWithTicket:(GTLServiceTicket *)ticket
//             finishedWithObject:(GTLCalendarEvents *)events
//                          error:(NSError *)error {
//    if (error == nil) {
//        NSMutableString *eventString = [[NSMutableString alloc] init];
//        if (events.items.count > 0) {
//            [eventString appendString:@"Upcoming 10 events:\n"];
//            for (GTLCalendarEvent *event in events) {
//                GTLDateTime *start = event.start.dateTime ?: event.start.date;
//                NSString *startString =
//                [NSDateFormatter localizedStringFromDate:[start date]
//                                               dateStyle:NSDateFormatterShortStyle
//                                               timeStyle:NSDateFormatterShortStyle];
//                [eventString appendFormat:@"%@ - %@\n", startString, event.summary];
//            }
//        } else {
//            [eventString appendString:@"No upcoming events found."];
//        }
//        self.output.text = eventString;
//    } else {
//        [self showAlert:@"Error" message:error.localizedDescription];
//    }
//}
//
//
//
//// Creates the auth controller for authorizing access to Google Calendar API.
//- (GTMOAuth2ViewControllerTouch *)createAuthController {
//    GTMOAuth2ViewControllerTouch *authController;
//    // If modifying these scopes, delete your previously saved credentials by
//    // resetting the iOS simulator or uninstall the app.
//    NSArray *scopes = [NSArray arrayWithObjects:kGTLAuthScopeCalendarReadonly, nil];
//    authController = [[GTMOAuth2ViewControllerTouch alloc]
//                      initWithScope:[scopes componentsJoinedByString:@" "]
//                      clientID:kClientID
//                      clientSecret:nil
//                      keychainItemName:kKeychainItemName
//                      delegate:self
//                      finishedSelector:@selector(viewController:finishedWithAuth:error:)];
//    return authController;
//}
//
//// Handle completion of the authorization process, and update the Google Calendar API
//// with the new credentials.
//- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
//      finishedWithAuth:(GTMOAuth2Authentication *)authResult
//                 error:(NSError *)error {
//    if (error != nil) {
//        [self showAlert:@"Authentication Error" message:error.localizedDescription];
//        self.service.authorizer = nil;
//    }
//    else {
//        self.service.authorizer = authResult;
//        [self dismissViewControllerAnimated:YES completion:nil];
//    }
//}
//
//// Helper for showing an alert
//- (void)showAlert:(NSString *)title message:(NSString *)message {
//    UIAlertController *alert =
//    [UIAlertController alertControllerWithTitle:title
//                                        message:message
//                                 preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *ok =
//    [UIAlertAction actionWithTitle:@"OK"
//                             style:UIAlertActionStyleDefault
//                           handler:^(UIAlertAction * action)
//     {
//         [alert dismissViewControllerAnimated:YES completion:nil];
//     }];
//    [alert addAction:ok];
//    [self presentViewController:alert animated:YES completion:nil];
//    
//}


///////////
- (void)setAuthState:(nullable OIDAuthState *)authState {
    if (_authState == authState) {
        return;
    }
    _authState = authState;
    _authState.stateChangeDelegate = self;
    [self stateChanged];
}


- (void)authWithAutoCodeExchange:(nullable id)sender {
    NSURL *issuer = [NSURL URLWithString:kIssuer];
    NSURL *redirectURI = [NSURL URLWithString:kRedirectURI];
    
    // discovers endpoints
    [OIDAuthorizationService discoverServiceConfigurationForIssuer:issuer
         completion:^(OIDServiceConfiguration *_Nullable configuration, NSError *_Nullable error) {
            
            if (!configuration) {
                [self setAuthState:nil];
                return;
            }
            
            
            // builds authentication request
            OIDAuthorizationRequest *request =
            [[OIDAuthorizationRequest alloc] initWithConfiguration:configuration
                                                          clientId:kClientID
                                                            scopes:@[OIDScopeOpenID, OIDScopeProfile]
                                                       redirectURL:redirectURI
                                                      responseType:OIDResponseTypeCode
                                              additionalParameters:nil];
            // performs authentication request
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            
            appDelegate.currentAuthorizationFlow =
            [OIDAuthState authStateByPresentingAuthorizationRequest:request
           presentingViewController:self
                           callback:^(OIDAuthState *_Nullable authState,
                                      NSError *_Nullable error) {
                               if (authState) {
                                   [self setAuthState:authState];
                                   self.service = [[GTLServiceCalendar alloc] init];
                                   self.service.authorizer = _authorization;
                               } else {
                                   [self setAuthState:nil];
                               }
                           }];
        }];
}



@end
