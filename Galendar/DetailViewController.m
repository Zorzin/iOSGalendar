//
//  DetailViewController.m
//  Galendar
//
//  Created by Zorzin on 05.01.2017.
//  Copyright © 2017 Zorzin. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.detailItem) {
        GTLDateTime *start = self.detailItem.start.dateTime ?: self.detailItem.start.date;
        NSString *startString =
        [NSDateFormatter localizedStringFromDate:[start date]
                                       dateStyle:NSDateFormatterShortStyle
                                       timeStyle:NSDateFormatterShortStyle];
        GTLDateTime *end = self.detailItem.end.dateTime ?: self.detailItem.end.date;
        NSString *endString =
        [NSDateFormatter localizedStringFromDate:[end date]
                                       dateStyle:NSDateFormatterShortStyle
                                       timeStyle:NSDateFormatterShortStyle];
        
        
        self.detailDescriptionLabel.text = self.detailItem.summary;
        self.startDateLabel.text = startString;
        self.endDateLabel.text = endString;
        self.descriptionLabel.text = self.detailItem.descriptionProperty;
        self.placeLabel.text = self.detailItem.location;
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Managing the detail item

- (void)setDetailItem:(GTLCalendarEvent *)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}


@end
