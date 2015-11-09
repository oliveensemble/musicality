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

@interface ExploreFetch ()

@property BOOL elementDidBegin;
@property (nonatomic) NSString *targetNode;
@property (nonatomic) NSMutableString *albumNameFeed;
@property (nonatomic) NSMutableString *artistNameFeed;
@property (nonatomic) NSString *albumArtFeed;
@property (nonatomic) NSString *albumURLFeed;
@property (nonatomic) NSNumber *artistID;

@end

@implementation ExploreFetch

- (instancetype)initWithURL:(NSURL *)url delegate:(id<ExploreFetchDelegate>)delegate {
  self = [super init];
  if (self) {
    _delegate = delegate;
    _url = url;
    _albumArray = [NSMutableArray array];
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
  self.targetNode = nil;
  
  if ([elementName isEqualToString:@"item"] || [elementName isEqualToString:@"entry"]) {
    self.elementDidBegin = YES;
    return;
  } else {
    if ([elementName isEqualToString:@"im:artist"] && !self.artistID) {
      NSString* artistLink = [attributeDict objectForKey:@"href"];
      if (artistLink && !self.artistID) {
        self.artistID = [NSNumber numberWithInt:[[mStore formattedAlbumIDFromURL:[NSURL URLWithString:artistLink]] intValue]];
      }
    }
    self.targetNode = elementName;
  }
  
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
  
  if ([self.targetNode isEqualToString:@"itms:album"] || [self.targetNode isEqualToString:@"im:name"]) {
    if (!self.albumNameFeed) {
      _albumNameFeed = [[NSMutableString alloc] initWithString:string];
    } else {
      [self.albumNameFeed appendString:string];
    }
  } else if ([self.targetNode isEqualToString:@"itms:artist"] || [self.targetNode isEqualToString:@"im:artist"]) {
    if (!self.artistNameFeed) {
      _artistNameFeed = [[NSMutableString alloc] initWithString:string];
    } else {
      [self.artistNameFeed appendString:string];
    }
  } else if ([self.targetNode isEqualToString:@"itms:coverArt"] || [self.targetNode isEqualToString:@"im:image"]) {
    self.albumArtFeed = string;
  } else if ([self.targetNode isEqualToString:@"itms:albumLink"] || [self.targetNode isEqualToString:@"id"]) {
    self.albumURLFeed = string;
  } else if ([self.targetNode isEqualToString:@"itms:artistLink"]) {
    self.artistID = [NSNumber numberWithInt:[[mStore formattedAlbumIDFromURL:[NSURL URLWithString:string]] intValue]];
  } else {
    return;
  }
  self.targetNode = nil;
  
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
  if ([elementName isEqualToString:@"item"] || [elementName isEqualToString:@"entry"]) {
    if (self.albumNameFeed && self.artistNameFeed && self.albumArtFeed) {
      Album *newAlbum = [[Album alloc] initWithAlbumTitle:self.albumNameFeed
                                                   artist:self.artistNameFeed
                                               artworkURL:self.albumArtFeed
                                                 albumURL:self.albumURLFeed
                                              releaseDate:nil];
      newAlbum.userData = self.artistID;
      // when that method finishes you can run whatever you need to on the main thread
      dispatch_async(dispatch_get_main_queue(), ^{
        [self.albumArray addObject:newAlbum];
      });
    }
    
    self.elementDidBegin = NO;
    self.targetNode = nil;
    self.albumNameFeed = nil;
    self.artistNameFeed = nil;
    self.albumArtFeed = nil;
    self.albumURLFeed = nil;
    self.artistID = nil;
  }
  
  if ([elementName isEqualToString:@"channel"] || [elementName isEqualToString:@"feed"]) {
    DLog(@"Finished");
    //Cast the operation to NSObject, and notify the caller on the main thread.
    [(NSObject *)self.delegate performSelectorOnMainThread:@selector(exploreFetchDidFinish:) withObject:self waitUntilDone:NO];
  }
  
}

@end
