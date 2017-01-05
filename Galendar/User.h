//
//  User.h
//  Galendar
//
//  Created by Zorzin on 05.01.2017.
//  Copyright © 2017 Zorzin. All rights reserved.
//

#ifndef User_h
#define User_h


#endif /* User_h */

@interface User : NSObject

+ (NSString*) getName;
+ (void) setName:(NSString*)setname;

+ (NSString*) getUserId;
+ (void) setUserId:(NSString*)setid;

+ (NSString*) getEmail;
+ (void) setEmail:(NSString*)setemail;

+ (NSString*) getToken;
+ (void) setToken:(NSString*)settoken;
@end
