//
//  MasterViewController.h
//  Galendar
//
//  Created by Zorzin on 05.01.2017.
//  Copyright © 2017 Zorzin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTMOAuth2ViewControllerTouch.h"
#import "GTLCalendar.h"

@class DetailViewController;
@class OIDAuthState;
@class GTMAppAuthFetcherAuthorization;
@class OIDServiceConfiguration;

@interface MasterViewController : UITableViewController

@property (nonatomic, strong) GTLServiceCalendar *service;
@property (nonatomic, strong) UITextView *output;
@property (strong, nonatomic) DetailViewController *detailViewController;
@property(nonatomic, nullable) GTMAppAuthFetcherAuthorization *authorization;
@property(nonatomic, readonly, nullable) OIDAuthState *authState;
@end

