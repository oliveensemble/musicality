//
//  ExploreFetch.m
//  Musicality
//
//  Created by Elle Lewis on 11/7/15.
//  Copyright © 2015 Later Creative LLC. All rights reserved.
//

#import "ExploreFetch.h"
#import "Album.h"
#import "MStore.h"

typedef NS_OPTIONS(NSUInteger, FeedType) {
  new = 1 << 0,
  topCharts = 1 << 1
};

@interface ExploreFetch () <NSXMLParserDelegate> {
  
  NSMutableDictionary *album;
  NSString *element;
  
  NSMutableString *albumNameFeed;
  NSMutableString *artistNameFeed;
  NSString *albumArtFeed;
  NSMutableString *albumURLFeed;
  NSMutableString *releaseDateFeed;
  NSMutableString *artistURLFeed;
  NSString *artistID;
  
}

@property (nonatomic) NSURL *url;
@property (nonatomic) NSMutableArray *albumArray;

@property BOOL elementDidBegin;

@end

@implementation ExploreFetch

- (instancetype)initWithDelegate:(id<ExploreFetchDelegate>)delegate {
  self = [super init];
  if (self) {
    _delegate = delegate;
    self.queuePriority = NSOperationQueuePriorityVeryHigh;
    self.qualityOfService = NSOperationQualityOfServiceUserInitiated;
  }
  return self;
}

- (void)fetchWithGenre:(int)genreID {
    if (genreID == -1) {
      _url = [NSURL URLWithString:@"https://itunes.apple.com/us/rss/topalbums/explicit=true/limit=100/xml"];
    } else {
      _url = [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/us/rss/topalbums/explicit=true/limit=100/genre=%i/xml", genreID]];
    }
  
  // Begin the operation
  [self start];
  
}

- (void)main {
  
  @autoreleasepool {
    
    if (self.isCancelled) {
      return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      NSXMLParser *parser = [[NSXMLParser alloc]initWithContentsOfURL:self.url];
      parser.delegate = self;
      [parser parse];
    });
  }
}

#pragma mark NSXMLParser Delegate Methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
  
  element = elementName;
  
  if ([elementName isEqualToString:@"item"] || [elementName isEqualToString:@"entry"]) {
    album = [[NSMutableDictionary alloc] init];
    albumNameFeed = [[NSMutableString alloc] init];
    artistNameFeed = [[NSMutableString alloc] init];
    albumURLFeed = [[NSMutableString alloc] init];
    releaseDateFeed = [[NSMutableString alloc] init];
    artistURLFeed = [[NSMutableString alloc] init];
  }
  
  //Get the artist id link from the href attribute
  if ([elementName isEqualToString:@"im:artist"] && artistID == nil) {
    NSURL *artistURL = [NSURL URLWithString:[attributeDict valueForKey:@"href"]];
    if (artistURL) {
      artistID = [mStore formattedAlbumIDFromURL:artistURL];
    }
  }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
  
  string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  if (string.length == 0) {
    return;
  }
  
  if ([element isEqualToString:@"itms:album"] || [element isEqualToString:@"im:name"]) {
    [albumNameFeed appendString:string];
  } else if ([element isEqualToString:@"itms:artist"] || [element isEqualToString:@"im:artist"]) {
    [artistNameFeed appendString:string];
  } else if ([element isEqualToString:@"itms:coverArt"] || [element isEqualToString:@"im:image"]) {
    albumArtFeed = string;
  } else if ([element isEqualToString:@"itms:albumLink"] || [element isEqualToString:@"id"]) {
    [albumURLFeed appendString:string];
  } else if ([element isEqualToString:@"im:releaseDate"]) {
    [releaseDateFeed appendString:string];
  } else if ([element isEqualToString:@"itms:artistLink"]) {
    [artistURLFeed appendString:string];
  }
  
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
  
  if ([elementName isEqualToString:@"item"] || [elementName isEqualToString:@"entry"]) {
    
    if (!artistID && artistURLFeed != nil && ![artistURLFeed isEqualToString:@""]) {
      NSURL *artistURL = [NSURL URLWithString:artistURLFeed];
      artistID = [mStore formattedAlbumIDFromURL:artistURL];
    }
    
    Album *newAlbum = [[Album alloc] initWithAlbumTitle:albumNameFeed artist:artistNameFeed artworkURL:albumArtFeed albumURL:albumURLFeed releaseDate:releaseDateFeed];
    [newAlbum addArtistId: artistID];
    
    if (!self.albumArray) {
      _albumArray = [NSMutableArray arrayWithCapacity: 100];
    }
    
    [self.albumArray addObject:newAlbum];
    albumNameFeed = nil;
    artistNameFeed = nil;
    albumArtFeed = nil;
    albumURLFeed = nil;
    releaseDateFeed = nil;
    artistURLFeed = nil;
    artistID = nil;
  }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
  [(NSObject *)self.delegate performSelectorOnMainThread:@selector(didFinishFetchingFeed:) withObject:[self.albumArray copy]  waitUntilDone:YES];
}

@end
