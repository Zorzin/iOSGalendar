//
//  AppDelegate.h
//  Galendar
//
//  Created by Zorzin on 05.01.2017.
//  Copyright © 2017 Zorzin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Google/SignIn.h>

@protocol OIDAuthorizationFlowSession;

@interface AppDelegate : UIResponder <UIApplicationDelegate, GIDSignInDelegate>

@property (strong, nonatomic) UIWindow *window;
@property(nonatomic, nullable) id<OIDAuthorizationFlowSession> currentAuthorizationFlow;

@end

