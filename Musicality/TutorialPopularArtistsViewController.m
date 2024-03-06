//
//  TutorialPopularArtistsViewController.m
//  Musicality
//
//  Created by Elle Lewis on 7/30/16.
//  Copyright © 2016 Elle Lewis. All rights reserved.
//

#import "TutorialPopularArtistsViewController.h"
#import "ArtistList.h"

@interface TutorialPopularArtistsViewController ()

@end

@implementation TutorialPopularArtistsViewController

- (IBAction)followPopularArtistsButtonTapped:(id)sender {
  [[ArtistList sharedList] addPopularArtists];
  [self loadMainStoryboard];
}
  
- (IBAction)dontFollowPopularArtistsButtonTapped:(id)sender {
  [self loadMainStoryboard];
}

- (void)loadMainStoryboard {
  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"notFirstRun"];
  [[NSUserDefaults standardUserDefaults] synchronize];
  UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
  UIViewController *initialViewController = [storyBoard instantiateInitialViewController];
  [self presentViewController:initialViewController animated:YES completion:nil];
}

@end
