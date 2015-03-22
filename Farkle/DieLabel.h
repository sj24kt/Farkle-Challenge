//
//  DieLabel.h
//  Farkle
//
//  Created by Sherrie Jones on 3/19/15.
//  Copyright (c) 2015 Sherrie Jones. All rights reserved.
//

#import <UIKit/UIKit.h>

// create the protocol
@protocol DieLabelDelegate
- (void)onDieLabelTapped:(UILabel *)dieLabel;
@end

@interface DieLabel : UILabel

// add a property to DieLabel called delegate of type id
@property (nonatomic, assign) id <DieLabelDelegate> delegate;

@property BOOL isHeld;

- (void)roll;

@end






















