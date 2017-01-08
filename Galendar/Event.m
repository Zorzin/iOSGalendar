//
//  Event.m
//  Galendar
//
//  Created by Zorzin on 08.01.2017.
//  Copyright © 2017 Zorzin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"
@implementation Event

static NSString *type;
static GTLDateTime *startDate;
static GTLDateTime *endDate;


+ (NSString*) getType{
    return type;
}
+ (void) setType:(NSString*)settype{
    type = settype;
}

+(GTLDateTime*) getDateTimeStart{
    return startDate;
}
+ (void) setDateTimeStart: (GTLDateTime*)setDateTimeStart{
    startDate = setDateTimeStart;
}

+(GTLDateTime*) getDateTimeEnd{
    return endDate;
}
+ (void) setDateTimeEnd: (GTLDateTime*)setDateTimeEnd{
    endDate = setDateTimeEnd;
}

@end
