//
//  AddEventViewController.m
//  Galendar
//
//  Created by Zorzin on 08.01.2017.
//  Copyright © 2017 Zorzin. All rights reserved.
//
#import "Event.h"
#import "AddEventViewController.h"
#import <AppAuth/AppAuth.h>
#import <GTMAppAuth/GTMAppAuth.h>
#import <QuartzCore/QuartzCore.h>
#import "User.h"
#import "GTMSessionFetcher.h"
#import "GTMSessionFetcherService.h"
#import "AppDelegate.h"
@interface AddEventViewController () <UIPopoverPresentationControllerDelegate>
@end

@implementation AddEventViewController
UIDatePicker *startDatePicker;
UIDatePicker *endDatePicker;
static BOOL switchStatus;
static NSString *date;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSString *type = [Event getType];
    if ([type length]!=0) {
        if ([type isEqualToString:@"start"]) {
            self.startDateField.text = [Event getDateTimeStart].stringValue;
        }
        else
        {
            self.endDateField.text = [Event getDateTimeEnd].stringValue;
        }
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
- (IBAction)StartDateLabel:(id)sender {
    [Event setType:@"start"];
    // grab the view controller we want to show
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *controller;
    if (switchStatus) {
        controller= [storyboard instantiateViewControllerWithIdentifier:@"DateController"];
    }
    else
    {
        controller = [storyboard instantiateViewControllerWithIdentifier:@"DateTimeController"];
    }
    
    // present the controller
    // on iPad, this will be a Popover
    // on iPhone, this will be an action sheet
    controller.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:controller animated:YES completion:nil];
    
    // configure the Popover presentation controller
    UIPopoverPresentationController *popController = [controller popoverPresentationController];
    popController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    popController.delegate = self;
}
- (IBAction)EndDateLabel:(id)sender {
    [Event setType:@"end"];
    // grab the view controller we want to show
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *controller;
    if (switchStatus) {
        controller= [storyboard instantiateViewControllerWithIdentifier:@"DateController"];
    }
    else
    {
        controller = [storyboard instantiateViewControllerWithIdentifier:@"DateTimeController"];
    }
    
    // present the controller
    // on iPad, this will be a Popover
    // on iPhone, this will be an action sheet
    controller.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:controller animated:YES completion:nil];
    
    // configure the Popover presentation controller
    UIPopoverPresentationController *popController = [controller popoverPresentationController];
    popController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    popController.delegate = self;
}


-(void)LabelChange:(id)sender
{
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    df.dateStyle = NSDateFormatterMediumStyle;
    NSLog(@"%@",[NSString stringWithFormat:@"%@",[df stringFromDate:startDatePicker.date]]);
}

- (IBAction)AllDaySwitchValueChanged:(id)sender {
    switchStatus = self.allDaySwitch.isOn;
}
- (IBAction)AddEvent:(id)sender {
    GTLCalendarEvent *calEvent = [GTLCalendarEvent object];
    calEvent.summary = self.titleField.text;
    calEvent.descriptionProperty = self.descriptionField.text;
    calEvent.location = self.placeField.text;
    GTLDateTime *startdatetime =[Event getDateTimeStart];
    GTLDateTime *enddatetime =[Event getDateTimeEnd];
    calEvent.start = [GTLCalendarEventDateTime object];
    calEvent.end = [GTLCalendarEventDateTime object];
    if (switchStatus) {
        calEvent.start.date = startdatetime;
        calEvent.end.date=enddatetime;
        calEvent.start.dateTime = nil;
        calEvent.end.dateTime = nil;
    }
    else{
        calEvent.start.dateTime = startdatetime;
        calEvent.end.dateTime = enddatetime;
    }
    calEvent.reminders = [GTLCalendarEventReminders object];
    calEvent.reminders.useDefault = [NSNumber numberWithBool:YES];
    
    self.service = [[GTLServiceCalendar alloc] init];
    GIDGoogleUser* user = [User getUser];
    self.service.authorizer = user.authentication.fetcherAuthorizer;
    GTLQueryCalendar *insertQuery = [GTLQueryCalendar queryForEventsInsertWithObject:calEvent
                                                                          calendarId:@"primary"];
    [self.service executeQuery:insertQuery
                 completionHandler:^(GTLServiceTicket *ticket, id object, NSError *error) {
                     if (error == nil) {
                         NSLog(@"event added");
                     } else {
                         NSLog(@"event added failed --- %@",[error description]);
                     }
                 }];

    
}
- (IBAction)Cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}





@end
