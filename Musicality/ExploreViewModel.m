//
//  ExploreViewModel.m
//  Musicality
//
//  Created by Evan Lewis on 6/28/16.
//  Copyright © 2016 Evan Lewis. All rights reserved.
//

#import "ExploreViewModel.h"
#import "ExplorePendingOperations.h"
#import "ExploreFetch.h"

typedef NS_OPTIONS(NSUInteger, FeedType) {
    new = 1 << 0,
    topCharts = 1 << 1
};

@interface ExploreViewModel() <ExploreFetchDelegate>

@property (nonatomic, weak) id<ExploreViewModelDelegate> delegate;
@property (nonatomic) NSArray *albumArray;

@end

@implementation ExploreViewModel

- (instancetype)initWithDelegate:(id<ExploreViewModelDelegate>)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
    }
    return  self;
}

- (void)beginWithFeedType:(NSUInteger)feedType andGenre:(int)genreID {
    NSURL *url;
    
    if (feedType == topCharts) {
        if (genreID == -1) {
            url = [NSURL URLWithString:@"https://itunes.apple.com/us/rss/topalbums/explicit=true/limit=100/xml"];
        } else {
            url = [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/us/rss/topalbums/explicit=true/limit=100/genre=%i/xml", genreID]];
        }
    } else {
        if (genreID == -1) {
            url = [NSURL URLWithString:@"https://itunes.apple.com/WebObjects/MZStore.woa/wpa/MRSS/newreleases/sf=143441/explicit=true/limit=100/rss.xml"];
        } else {
            url = [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/WebObjects/MZStore.woa/wpa/MRSS/newreleases/sf=143441/explicit=true/limit=100/genre=%i/rss.xml", genreID]];
        }
    }
    
    ExploreFetch *exploreFetch = [[ExploreFetch alloc] initWithURL:url delegate:self];
    exploreFetch.queuePriority = NSOperationQueuePriorityVeryHigh;
    [[[ExplorePendingOperations sharedOperations] exploreRequestsInProgress] setObject:exploreFetch forKey:@"ExploreFetch"];
    [[[ExplorePendingOperations sharedOperations] exploreRequestQueue] addOperation:exploreFetch];
    [[ExplorePendingOperations sharedOperations] beginOperations];
}

- (void)exploreFetchDidFinish:(ExploreFetch *)downloader {
    [[[ExplorePendingOperations sharedOperations] exploreRequestsInProgress] removeObjectForKey:@"ExploreFetch"];
    self.albumArray = downloader.albumArray;
    [(NSObject *)self.delegate performSelectorOnMainThread:@selector(didFinishFetchingFeed:) withObject:self.albumArray waitUntilDone:NO];
}

@end
