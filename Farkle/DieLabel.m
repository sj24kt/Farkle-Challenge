//
//  DieLabel.m
//  Farkle
//
//  Created by Sherrie Jones on 3/19/15.
//  Copyright (c) 2015 Sherrie Jones. All rights reserved.
//

#import "DieLabel.h"

@implementation DieLabel

// connect it to the tap gesture recognizer for each die
- (IBAction)onTapped:(UITapGestureRecognizer *)sender {
    [self.delegate onDieLabelTapped:self];
}

// gets a random number - called for each die when roll button is pressed
- (void)roll {

    if (!self.isKept) {
        NSInteger random = arc4random_uniform(6) + 1;
        [self setText:[NSString stringWithFormat:@"%ld", (long)random]];

        // set die background color to green
        //self.backgroundColor = [UIColor colorWithRed:76/255.0 green:153/255.0 blue:0/255.0 alpha:1.0f];
    }
}

@end































