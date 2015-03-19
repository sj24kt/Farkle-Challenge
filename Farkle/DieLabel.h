//
//  DieLabel.h
//  Farkle
//
//  Created by Sherrie Jones on 3/19/15.
//  Copyright (c) 2015 Sherrie Jones. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DieLabelDelegate
- (void)onDieLabelTapped:(UILabel *)label;
@end

@interface DieLabel : UILabel

// set the delegate
@property (nonatomic, assign) id <DieLabelDelegate> delegate;
@property BOOL isKept;

- (void)roll;

@end






















