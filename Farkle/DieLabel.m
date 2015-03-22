//
//  DieLabel.m
//  Farkle
//
//  Created by Sherrie Jones on 3/19/15.
//  Copyright (c) 2015 Sherrie Jones. All rights reserved.
//

#import "DieLabel.h"

@interface DieLabel () {
    UIImage *image;
}
@end


@implementation DieLabel

// call delegate-protocol method on DieLabel's property
// connect it to the tap gesture recognizer for each die
- (IBAction)labelWasTapped:(UITapGestureRecognizer*)tapGestureReconizer {

    if(tapGestureReconizer.state == UIGestureRecognizerStateEnded) {
        //tell the delegate a lable was tapped
        [self.delegate onDieLabelTapped:self];
    }
}

// gets a random number - called for each die when roll button is pressed
- (void)roll {
    NSInteger randomNumber = arc4random_uniform(6) + 1;
    //int randomNumber = (arc4random()%6)+1;
    self.text = [NSString stringWithFormat:@"%li",(long)randomNumber];
    image = [UIImage imageNamed:[NSString stringWithFormat:@"dice%li",(long)randomNumber]];
}


@end































