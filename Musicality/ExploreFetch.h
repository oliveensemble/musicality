//
//  ExploreFetch.h
//  Musicality
//
//  Created by Evan Lewis on 11/7/15.
//  Copyright © 2015 Evan Lewis. All rights reserved.
//

@import Foundation;

@protocol ExploreFetchDelegate;

//Fetches an array of albums for the explore view
@interface ExploreFetch : NSOperation <NSXMLParserDelegate>

@property (nonatomic, weak) id<ExploreFetchDelegate> delegate;
@property (nonatomic) NSURL *url;
@property (nonatomic) NSMutableArray *albumArray;

- (instancetype)initWithURL:(NSURL*)url delegate:(id<ExploreFetchDelegate>) delegate;

@end

@protocol ExploreFetchDelegate <NSObject>

- (void)exploreFetchDidFinish:(ExploreFetch*)downloader;

@end
