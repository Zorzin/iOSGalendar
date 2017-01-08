//
//  AddEventViewController.h
//  Galendar
//
//  Created by Zorzin on 08.01.2017.
//  Copyright © 2017 Zorzin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DateViewController.h"
#import "DateTimeViewController.h"

@interface AddEventViewController : UIViewController
@property (nonatomic, strong) GTLServiceCalendar *service;
@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UITextField *descriptionField;
@property (weak, nonatomic) IBOutlet UITextField *placeField;
@property (weak, nonatomic) IBOutlet UILabel *startDateField;
@property (weak, nonatomic) IBOutlet UILabel *endDateField;
@property (weak, nonatomic) IBOutlet UIButton *selectStartDateButton;
@property (weak, nonatomic) IBOutlet UIButton *selectEndDateButton;
@property (weak, nonatomic) IBOutlet UISwitch *allDaySwitch;
@end
