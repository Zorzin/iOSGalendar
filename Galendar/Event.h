//
//  Event.h
//  Galendar
//
//  Created by Zorzin on 08.01.2017.
//  Copyright © 2017 Zorzin. All rights reserved.
//

#ifndef Event_h
#define Event_h
#import "GTLCalendar.h"

#endif /* Event_h */

@interface Event : NSObject

+ (NSString*) getType;
+ (void) setType:(NSString*)settype;

+(GTLDateTime*) getDateTimeStart;
+ (void) setDateTimeStart: (GTLDateTime*)setDateTimeStart;

+(GTLDateTime*) getDateTimeEnd;
+ (void) setDateTimeEnd: (GTLDateTime*)setDateTimeEnd;
@end
