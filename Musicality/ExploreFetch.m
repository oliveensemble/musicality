//
//  ExploreFetch.m
//  Musicality
//
//  Created by Evan Lewis on 11/7/15.
//  Copyright © 2015 Evan Lewis. All rights reserved.
//

#import "ExploreFetch.h"
#import "Album.h"
#import "MStore.h"

@interface ExploreFetch () {

  NSMutableDictionary *album;
  NSString *element;
  
  NSMutableString *albumNameFeed;
  NSMutableString *artistNameFeed;
  NSString *albumArtFeed;
  NSMutableString *albumURLFeed;
  NSMutableString *releaseDateFeed;
  
}

@property BOOL elementDidBegin;

@end

@implementation ExploreFetch

- (instancetype)initWithURL:(NSURL *)url delegate:(id<ExploreFetchDelegate>)delegate {
  self = [super init];
  if (self) {
    _albumArray = [NSMutableArray array];
    _delegate = delegate;
    _url = url;
  }
  return self;
}

- (void)main {
  
  @autoreleasepool {
    
    if (self.isCancelled) {
      return;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      // do your background tasks here
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
  }

}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
  if ([elementName isEqualToString:@"item"] || [elementName isEqualToString:@"entry"]) {
    
    Album *newAlbum = [[Album alloc] initWithAlbumTitle:albumNameFeed artist:artistNameFeed artworkURL:albumArtFeed albumURL:albumURLFeed releaseDate:releaseDateFeed];
    newAlbum.artistID = [NSNumber numberWithInt:[mStore formattedAlbumIDFromURL:newAlbum.URL].intValue];
    [self.albumArray addObject:newAlbum];
    
    albumNameFeed = nil;
    artistNameFeed = nil;
    albumArtFeed = nil;
    albumURLFeed = nil;
    releaseDateFeed = nil;
    
  }
  
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
  [(NSObject *)self.delegate performSelectorOnMainThread:@selector(exploreFetchDidFinish:) withObject:self waitUntilDone:NO];
}

@end
