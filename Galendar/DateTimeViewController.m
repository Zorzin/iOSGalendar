//
//  DateTimeViewController.m
//  Galendar
//
//  Created by Zorzin on 08.01.2017.
//  Copyright © 2017 Zorzin. All rights reserved.
//

#import "DateTimeViewController.h"
#import "GTLCalendar.h"
#import "Event.h"
@interface DateTimeViewController ()

@end

@implementation DateTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)SaveDate:(id)sender {
    //addsave
    NSDate *date = self.dateTime.date;
    GTLDateTime *dt = [GTLDateTime dateTimeWithDate:date timeZone:[NSTimeZone systemTimeZone]];
    NSString *type = [Event getType];
    if ([type  isEqual: @"start"]) {
        [Event setDateTimeStart:dt];
    }
    else
    {
        [Event setDateTimeEnd:dt];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)Cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
