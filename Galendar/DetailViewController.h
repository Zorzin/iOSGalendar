//
//  DetailViewController.h
//  Galendar
//
//  Created by Zorzin on 05.01.2017.
//  Copyright © 2017 Zorzin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTMOAuth2ViewControllerTouch.h"
#import "GTLCalendar.h"

@interface DetailViewController : UIViewController

@property (strong, nonatomic) GTLCalendarEvent *detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *startDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *endDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeLabel;

@end

