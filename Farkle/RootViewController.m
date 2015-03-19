//
//  RootViewController.m
//  Farkle
//
//  Created by Sherrie Jones on 3/19/15.
//  Copyright (c) 2015 Sherrie Jones. All rights reserved.
//

#import "RootViewController.h"
#import "DieLabel.h"

@interface RootViewController () <DieLabelDelegate>

@property IBOutletCollection(DieLabel) NSArray *labels;
@property (weak, nonatomic) IBOutlet UILabel *userScore;
@property (weak, nonatomic) IBOutlet UIButton *rollButton;
@property NSMutableArray *die;
@property NSMutableArray *selectedDies;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.die = [NSMutableArray new];
    self.selectedDies = [@[@"1", @"5"]mutableCopy];

    for (DieLabel *label in self.labels) {
        label.delegate = self;
    }
}

-(void)onDieLabelTapped:(UILabel *)label {
    //
    label.backgroundColor = [UIColor colorWithRed:22/255.0 green:128/255.0 blue:18/255.0 alpha:1.0f];
}

// calls the roll method in DieLabel.m when roll button is pressed
// gets new random number for each die
- (IBAction)onRollPressed:(UIButton *)sender {

    // call the roll method on each DieLabel
    // fast enumerates through your IBOutletCollecion of die labels 
    for (DieLabel * label in self.labels) {
        [label roll];
    }
}

@end


























