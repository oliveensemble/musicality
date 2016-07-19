//
//  SearchViewModel.m
//  Musicality
//
//  Created by Evan Lewis on 7/18/16.
//  Copyright © 2016 Evan Lewis. All rights reserved.
//

#import "SearchViewModel.h"
#import "SearchFetch.h"
#import "SearchPendingOperations.h"

typedef NS_OPTIONS(NSUInteger, SearchType) {
  artists = 1 << 0,
  albums = 1 << 1
};

@interface SearchViewModel() <SearchFetchDelegate>

@property (nonatomic, weak) id<SearchFetchDelegate> delegate;
@property (nonatomic) NSArray *searchResultsArray;

@end

@implementation SearchViewModel

- (instancetype)initWithDelegate:(id<SearchFetchDelegate>)delegate {
  self = [super init];
  if (self) {
    _delegate = delegate;
  }
  return  self;
}

- (void)beginWithSearchType:(NSUInteger)searchType searchTerm: (NSString *)searchTerm {
  SearchFetch *searchFetch = [[SearchFetch alloc] initWithSearchType:searchType searchTerm:searchTerm delegate:self];
  [[[SearchPendingOperations sharedOperations] searchRequestsInProgress] setObject:searchFetch forKey:@"SearchFetch"];
  [[[SearchPendingOperations sharedOperations] searchRequestQueue] addOperation:searchFetch];
  [[SearchPendingOperations sharedOperations] beginOperations];
}

- (void)searchFetchDidFinish:(NSMutableArray *)searchResultsArray {
  [[[SearchPendingOperations sharedOperations] searchRequestsInProgress] removeObjectForKey:@"SearchFetch"];
  self.searchResultsArray = searchResultsArray;
  [(NSObject *)self.delegate performSelectorOnMainThread:@selector(didFinishSearch:) withObject:self.searchResultsArray waitUntilDone:NO];
}

@end
