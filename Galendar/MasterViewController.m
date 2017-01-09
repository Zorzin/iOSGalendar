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
#import "AddEventViewController.h"
@interface MasterViewController ()

@property NSMutableArray *objects;
@end

@implementation MasterViewController
dispatch_semaphore_t sema;
static BOOL deleteResult;
static NSString *const kIssuer = @"https://accounts.google.com";
static NSString *const kClientID = @"771428174670-83blj1mg19jdtudmp61jo669pkpslbjt.apps.googleusercontent.com";
static NSString *const kRedirectURI = @"com.googleusercontent.apps.771428174670-83blj1mg19jdtudmp61jo669pkpslbjt:/oauthredirect";
static NSString *const kAppAuthExampleAuthStateKey = @"authState";
static NSString *const kKeychainItemName = @"Google Calendar API";
OIDServiceConfiguration *configuration ;
//- (void)didChangeState:(OIDAuthState *)state {
//    [self stateChanged];
//}
//
//- (void)authState:(OIDAuthState *)state didEncounterAuthorizationError:(nonnull NSError *)error {
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"LogOut" style:UIBarButtonItemStyleDone target:self action:@selector(logOut)];
    self.navigationItem.leftBarButtonItems = @[self.editButtonItem, backButton];

    UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(fetchEvents)];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(openAddPage)];
    self.navigationItem.rightBarButtonItems = @[addButton,refreshButton];
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    self.service = [[GTLServiceCalendar alloc] init];
    
    
}


- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
    [self fetchEvents];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)logOut{
    [[GIDSignIn sharedInstance] signOut];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)openAddPage{
    AddEventViewController *addEventViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddEvent"];
    [self presentViewController:addEventViewController animated:NO completion:nil];
}
- (void)insertNewEvent:(GTLCalendarEvent*)event{
    if (!self.objects) {
        self.objects = [[NSMutableArray alloc] init];
    }
    [self.objects insertObject:event atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        GTLCalendarEvent *object = self.objects[indexPath.row];
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

    GTLCalendarEvent *object = self.objects[indexPath.row];
    cell.textLabel.text = object.summary;
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        GTLCalendarEvent *event = [self.objects objectAtIndex:indexPath.row];
        [self deleteFromCalendar:event];
        
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

-(void)deleteFromCalendar:(GTLCalendarEvent*)event
{
    GTLQueryCalendar *deletequery = [GTLQueryCalendar queryForEventsDeleteWithCalendarId:@"primary" eventId:event.identifier];
    [self.service executeQuery:deletequery
                      delegate:self
             didFinishSelector:@selector(deleteResult:finishedWithObject:error:)];
}

-(void) deleteResult:(GTLServiceTicket *)ticket
                        finishedWithObject:(GTLCalendarEvents *)events
                        error:(NSError *)error
{
    if (error == nil) {
        deleteResult = YES;
        NSLog(@"event deleted");
        [self fetchEvents];
        
    } else {
        deleteResult = NO;
        [self showAlert:@"Error" message:[error localizedDescription]];
        NSLog(@"event deleted failed --- %@",[error description]);
    }
}
////API STUFF

// Construct a query and get a list of upcoming events from the user calendar. Display the
// start dates and event summaries in the UITextView.
- (void)fetchEvents {
    [self.objects removeAllObjects];
    [self.tableView reloadData];
    GTLQueryCalendar *query = [GTLQueryCalendar queryForEventsListWithCalendarId:@"primary"];
    GIDGoogleUser* user = [User getUser];
    self.service.authorizer = user.authentication.fetcherAuthorizer;
    query.singleEvents = YES;
    query.orderBy = kGTLCalendarOrderByStartTime;
    
    [self.service executeQuery:query
                      delegate:self
             didFinishSelector:@selector(displayResultWithTicket:finishedWithObject:error:)];
}

- (void)displayResultWithTicket:(GTLServiceTicket *)ticket
             finishedWithObject:(GTLCalendarEvents *)events
                          error:(NSError *)error {
    if (error == nil) {
        NSMutableString *eventString = [[NSMutableString alloc] init];
        if (events.items.count > 0) {
            for (GTLCalendarEvent *event in events) {
                NSDate *end = event.end.dateTime.date;
                NSDate *now = [NSDate date];
                if (end==nil) {
                    end = event.end.date.date;
                    NSCalendar *calendar = [NSCalendar currentCalendar];
                    NSInteger comps = (NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear);
                    
                    NSDateComponents *date1Components = [calendar components:comps
                                                                    fromDate: now];
                    NSDateComponents *date2Components = [calendar components:comps
                                                                    fromDate: end];
                    
                    now = [calendar dateFromComponents:date1Components];
                    end = [calendar dateFromComponents:date2Components];
                    NSComparisonResult result = [now compare:end];
                    if (result!=NSOrderedDescending) {
                        [self insertNewEvent:event];
                    }
                }
                else
                {
                    
                    NSComparisonResult result = [now compare:end];
                    
                    if (result==NSOrderedAscending) {
                        [self insertNewEvent:event];
                    }
                }
            }
        } else {
            [self showAlert:@"Nothing to show" message:@"No upcoming events found"];
        }
        self.output.text = eventString;
    } else {
        [self showAlert:@"Error" message:error.localizedDescription];
    }
}



// Creates the auth controller for authorizing access to Google Calendar API.
- (GTMOAuth2ViewControllerTouch *)createAuthController {
    GTMOAuth2ViewControllerTouch *authController;
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    NSArray *scopes = [NSArray arrayWithObjects:kGTLAuthScopeCalendarReadonly, nil];
    authController = [[GTMOAuth2ViewControllerTouch alloc]
                      initWithScope:[scopes componentsJoinedByString:@" "]
                      clientID:kClientID
                      clientSecret:nil
                      keychainItemName:kKeychainItemName
                      delegate:self
                      finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    return authController;
}

// Handle completion of the authorization process, and update the Google Calendar API
// with the new credentials.
- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)authResult
                 error:(NSError *)error {
    if (error != nil) {
        [self showAlert:@"Authentication Error" message:error.localizedDescription];
        self.service.authorizer = nil;
    }
    else {
        self.service.authorizer = authResult;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

// Helper for showing an alert
- (void)showAlert:(NSString *)title message:(NSString *)message {
    UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:title
                                        message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok =
    [UIAlertAction actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action)
     {
         [alert dismissViewControllerAnimated:YES completion:nil];
     }];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
    
}

@end
