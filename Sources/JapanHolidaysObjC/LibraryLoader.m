//
//  LibraryLoader.m
//  JapanHolidays
//
//  Created by uhimania on 2026/02/05.
//

#import <Foundation/Foundation.h>

@import JapanHolidays;

@interface LibraryLoader : NSObject
@end

@implementation LibraryLoader

+ (void)load {
    [HolidaysInitializer setup];
}

@end
