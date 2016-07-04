//
//  MStore.m
//  Musicality
//
//  Created by Evan Lewis on 9/29/14.
//  Copyright (c) 2014 Evan Lewis. All rights reserved.
//

@import MediaPlayer;

#import "UserPrefs.h"
#import "Artist.h"
#import "MStore.h"
#import "AutoScan.h"
#define requestHandler [URLRequestHandler sharedHandler]

@interface MStore ()

@property (nonatomic, strong) UIWindow *mainWindow;
@property (nonatomic, strong) UIView *loadingView;

@end

@implementation MStore

+ (instancetype)sharedStore {
    static MStore *sharedStore = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedStore = [[self alloc] initPrivate];
    });
    
    return sharedStore;
}

- (instancetype)initPrivate {
    self = [super init];
    if (self) {
        if (!self.lastLibraryScanDate) {
            [self setLastLibraryScanDate:[NSDate dateWithTimeIntervalSince1970:1]];
        }
    }
    return self;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"Singleton"
                                   reason:@"Use mStore instead"
                                 userInfo:nil];
    return nil;
}

- (NSString *)affiliateToken {
    return @"1l3vuBC";
}

#pragma mark Date formatting

- (void)setLastLibraryScanDate:(NSDate *)lastLibraryScanDate {
    [[NSUserDefaults standardUserDefaults] setObject:lastLibraryScanDate forKey:@"lastLibraryScanDate"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSDate *)lastLibraryScanDate {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"lastLibraryScanDate"];
}

- (NSDate *)formattedDateFromString:(NSString *)unFormattedDate {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
    NSDate *formattedDate = [dateFormatter dateFromString:unFormattedDate];
    return formattedDate;
    
}

- (BOOL)thisDate:(NSDate*)date1 isMoreRecentThan:(NSDate*)date2 {
    if ([date1 compare:date2] == NSOrderedDescending) {
        return YES;
    }
    return NO;
}

- (BOOL)isToday:(NSDate *)date {
    NSDate *today = [NSDate date];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    calendar.timeZone = [NSTimeZone localTimeZone];
    NSDateComponents* currentDateComponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:today]; // Get necessary date components
    NSDate *currentDate = [calendar dateWithEra:1 year:[currentDateComponents year] month:[currentDateComponents month] day:[currentDateComponents day] hour:12 minute:12 second:12 nanosecond:12];
    
    NSDateComponents* checkDateComponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date]; // Get necessary date components
    NSDate *checkDate = [calendar dateWithEra:1 year:[checkDateComponents year] month:[checkDateComponents month] day:[checkDateComponents day] hour:12 minute:12 second:12 nanosecond:12];
    if ([checkDate isEqualToDate:currentDate]) {
        return YES;
    }
    return NO;
}

- (BOOL)isSameDay:(NSDate*)date1 as:(NSDate*)date2 {
    NSCalendar* calendar = [NSCalendar currentCalendar];
    calendar.timeZone = [NSTimeZone localTimeZone];
    NSDateComponents* firstDateComponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date1]; // Get necessary date components
    NSDate *firstDateFormatted = [calendar dateWithEra:1 year:[firstDateComponents year] month:[firstDateComponents month] day:[firstDateComponents day] hour:12 minute:12 second:12 nanosecond:12];
    
    NSDateComponents* checkDateComponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date2]; // Get necessary date components
    NSDate *secondDateFormatted = [calendar dateWithEra:1 year:[checkDateComponents year] month:[checkDateComponents month] day:[checkDateComponents day] hour:12 minute:12 second:12 nanosecond:12];
    if ([firstDateFormatted isEqualToDate:secondDateFormatted]) {
        return YES;
    }
    return NO;
}

- (NSNumber*)formattedAlbumIDFromURL:(NSURL*)url {
    
    if (!url) {
        DLog(@"Cannot format, url is empty: %@", url);
        return nil;
    }
    
    NSString *stringUrl = [url absoluteString];
    NSString *idString = @"/id";
    NSString *uoString = @"?";
    if ([stringUrl containsString:@"i="]) {
        idString = @"i=";
        uoString = @"&uo";
    }
    NSRange firstCut = [stringUrl rangeOfString:idString];
    NSRange secondCut = [stringUrl rangeOfString:uoString];
    NSRange intersectionRange = NSUnionRange(firstCut, secondCut);
    NSString *formattedString = @"";
    @try {
        formattedString = [[[stringUrl substringWithRange:intersectionRange] stringByReplacingOccurrencesOfString:idString withString:@""] stringByReplacingOccurrencesOfString:uoString withString:@""];
    }
    @catch (NSException *exception) {
        DLog(@"Cannot format string: %@", stringUrl);
    }
    @finally {
        NSInteger albumID = [formattedString integerValue];
        return [NSNumber numberWithInteger: albumID];
    }
    return nil;
    
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - User Library
- (NSArray*)artistsFromUserLibrary {
    
    MPMediaQuery *userArtists = [MPMediaQuery artistsQuery];
    NSArray *artists = [userArtists collections];
    NSMutableOrderedSet *userSet = [[NSMutableOrderedSet alloc] init];
    
    for (MPMediaItemCollection *collection in artists) {
        MPMediaItem *item = [collection representativeItem];
        if (item.artist) {
            Artist* artist = [[Artist alloc] initWithArtistID:nil andName:item.artist];
            [userSet addObject:artist];
        }
    }
    return [userSet array];
}

@end
