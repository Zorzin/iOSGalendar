//
//  User.m
//  Galendar
//
//  Created by Zorzin on 05.01.2017.
//  Copyright © 2017 Zorzin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
@implementation User

static NSString* name;
static NSString* userid;
static NSString* email;
static NSString* token;
static GIDGoogleUser* user;

+ (NSString*) getName {
    return name;
}

+ (void) setName: (NSString*)setname{
    name = setname;
}

+ (NSString*) getUserId {
    return userid;
}

+ (void) setUserId: (NSString*)setid{
    userid = setid;
}

+ (NSString*) getEmail {
    return email;
}

+ (void) setEmail: (NSString*)setemail{
    email = setemail;
}

+ (NSString*) getToken {
    return token;
}

+ (void) setToken: (NSString*)settoken{
    token = settoken;
}

+(void) setUser: (GIDGoogleUser*)setuser{
    user = setuser;
}
+(GIDGoogleUser*) getUser{
    return user;
}

@end
