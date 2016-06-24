//
//  MTableViewController.h
//  Musicality
//
//  Created by Evan Lewis on 6/14/16.
//  Copyright © 2016 Evan Lewis. All rights reserved.
//

#import "MTableViewController.h"
#import "UserPrefs.h"

@interface MTableViewController ()

@end

@implementation MTableViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)configureView {
    if ([[UserPrefs sharedPrefs] isDarkModeEnabled]) {
        self.view.backgroundColor = [UIColor blackColor];
    } else {
        self.view.backgroundColor = [UIColor whiteColor];
    }
}

@end
