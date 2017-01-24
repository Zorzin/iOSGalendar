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
    
    [self AllDaySwitchValueChanged:nil];
    [self checkButton];
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
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    if (switchStatus) {
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    }
    if ([type length]!=0) {
        if ([type isEqualToString:@"start"]) {
            NSString *formattedDateString = [dateFormatter stringFromDate:[Event getDateTimeStart].date];
            if (formattedDateString !=nil) {
                self.startDateField.text = formattedDateString;
            }
        }
        else
        {
            NSString *formattedDateString = [dateFormatter stringFromDate:[Event getDateTimeEnd].date];
            if (formattedDateString !=nil) {
                self.endDateField.text = formattedDateString;
            }
        }
    }
    [self checkButton];
}

-(void)checkButton{
    GTLDateTime *startdatetime,*enddatetime;
    startdatetime = [Event getDateTimeStart];
    enddatetime = [Event getDateTimeEnd];
    self.addButton.hidden = YES;
    if (startdatetime!=nil && enddatetime!=nil) {
        NSDate *end,*start;
        end = enddatetime.date;
        start = startdatetime.date;
        if (switchStatus) {
            NSCalendar *calendar = [NSCalendar currentCalendar];
            NSInteger comps = (NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear);
            
            NSDateComponents *date1Components = [calendar components:comps
                                                            fromDate: start];
            NSDateComponents *date2Components = [calendar components:comps
                                                            fromDate: end];
            
            start = [calendar dateFromComponents:date1Components];
            end = [calendar dateFromComponents:date2Components];
            NSComparisonResult result = [start compare:end];
            if (result!=NSOrderedDescending) {
                self.addButton.hidden = NO;
            }
        }
        else
        {
            NSComparisonResult result = [start compare:end];
            
            if (result==NSOrderedAscending) {
                self.addButton.hidden = NO;
            }
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
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    if (self.allDaySwitch.isOn) {
        
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
        GTLDateTime *end = [Event getDateTimeEnd];
        GTLDateTime *start = [Event getDateTimeStart];
        if (end!=nil) {
            NSDate *enddate = end.date;
            GTLDateTime *newend = [GTLDateTime dateTimeForAllDayWithDate:enddate];
            [Event setDateTimeEnd:newend];
        }
        if (start!=nil) {
            NSDate *startdate = start.date;
            GTLDateTime *newstart = [GTLDateTime dateTimeForAllDayWithDate:startdate];
            [Event setDateTimeStart:newstart];
        }

    }
    else
    {
        GTLDateTime *end = [Event getDateTimeEnd];
        GTLDateTime *start = [Event getDateTimeStart];
        if (end!=nil) {
            NSDate *enddate = end.date;
            GTLDateTime *newend = [GTLDateTime dateTimeWithDate:enddate timeZone:[NSTimeZone systemTimeZone]];
            [Event setDateTimeEnd:newend];
        }
        if (start!=nil) {
            NSDate *startdate = start.date;
            GTLDateTime *newstart = [GTLDateTime dateTimeWithDate:startdate timeZone:[NSTimeZone systemTimeZone]];
            [Event setDateTimeStart:newstart];
        }
    }
    
    
    if ([Event getDateTimeStart]!=nil) {
        
        NSString *formattedDateString = [dateFormatter stringFromDate:[Event getDateTimeStart].date];
        self.startDateField.text = formattedDateString;
    }
    if ([Event getDateTimeEnd]!=nil) {
        
        NSString *formattedDateString = [dateFormatter stringFromDate:[Event getDateTimeEnd].date];
        self.endDateField.text = formattedDateString;
    }
    
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
                         [Event setDateTimeEnd:nil];
                         [Event setDateTimeStart:nil];
                         [Event setType:nil];
                         [self dismissViewControllerAnimated:YES completion:nil];
                     } else {
                         NSLog(@"event added failed --- %@",[error description]);
                         [self showAlert:@"Error" message:[error localizedDescription]];
                     }
                 }];
    

    
}
- (IBAction)Cancel:(id)sender {
    [Event setDateTimeEnd:nil];
    [Event setDateTimeStart:nil];
    [Event setType:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}
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
