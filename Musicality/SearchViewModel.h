//
//  SearchViewModel.h
//  Musicality
//
//  Created by Evan Lewis on 7/18/16.
//  Copyright © 2016 Evan Lewis. All rights reserved.
//

@import Foundation;

@protocol SearchViewModelDelegate;

@interface SearchViewModel : NSObject

- (instancetype)initWithDelegate:(id<SearchViewModelDelegate>)delegate;
- (void)beginWithSearchType:(NSUInteger)searchType searchTerm: (NSString *)searchTerm;

@end

@protocol SearchViewModelDelegate <NSObject>

- (void)didFinishSearch:(NSArray *)searchResultsArray;

@end