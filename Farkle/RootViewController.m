//
//  RootViewController.m
//  Farkle
//
//  Created by Sherrie Jones on 3/19/15.
//  Copyright (c) 2015 Sherrie Jones. All rights reserved.
//

#import "RootViewController.h"
#import "DieLabel.h"
#import "CalculateScore.h"

#define MAX_RGB 255.0f
#define GREEN_COLOR [UIColor colorWithRed:0/MAX_RGB green:102/MAX_RGB blue:0/MAX_RGB alpha:1.0]
#define RED_COLOR [UIColor redColor]
#define BLACK_COLOR [UIColor blackColor]
#define WHITE_COLOR [UIColor whiteColor]
#define ORANGE_COLOR [UIColor colorWithRed:255/MAX_RGB green:153/MAX_RGB blue:51/MAX_RGB alpha:1.0];

@interface RootViewController () <DieLabelDelegate, UIAlertViewDelegate>

@property IBOutletCollection(DieLabel) NSArray *dieLabels;
@property (weak, nonatomic) IBOutlet UILabel *currentPointsLabel;
@property (weak, nonatomic) IBOutlet UILabel *player1TotalScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *player2TotalScoreLabel;

@property (nonatomic) NSMutableArray *dice;
@property (nonatomic) NSMutableArray *selectedDies;
@property (nonatomic) BOOL isHeld;
@property (nonatomic) BOOL isItPlayerOne;

@property (nonatomic) CalculateScore *score;
@property (nonatomic) NSInteger player1TotalScore;
@property (nonatomic) NSInteger player2TotalScore;
@property (nonatomic) NSInteger scoreForTurn;
@property (nonatomic) NSInteger numberOfTurnsTaken;
@property (nonatomic) NSInteger numberOfDiceScored;
@property (nonatomic) BOOL isFirstRole;
@property (nonatomic) BOOL Player1;

@end

@implementation RootViewController

#pragma mark - ViewLifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dice = [NSMutableArray new];
    self.Player1 = YES;
    self.isFirstRole = YES;
    [self setLabelDelegate];
    [self enableAllDiceForUserInteraction:NO];

    self.player1TotalScoreLabel.textColor = RED_COLOR;
    self.player2TotalScoreLabel.textColor = GREEN_COLOR;
    self.currentPointsLabel.TextColor = ORANGE_COLOR;
    //self.selectedDies = [@[@"1", @"5"]mutableCopy];
    //self.selectedDies.cornerRadius = 20;
}

// create an score object if one does not already exist (lazy instantiation)
-(CalculateScore*)score {
    if (!_score)     {
        _score =[[CalculateScore alloc]init];
    }

    return _score;
}


#pragma mark - IBActions

// Begin the game by rolling the full set of dice, subsequent turns
// involve rolling the non-scoring dice unless Hot Dice is achived,
// in which case the player gets to roll all dice again
- (IBAction)onRollButtonPressed:(id)sender {

    if (self.isFirstRole) {
        // when roll is pressed, only call roll on the DieLabels not in the dice array
        [self enableAllDiceForUserInteraction:YES];
        [self rollAllUncheckedDice];
        //[self checkGameStateAfterRollForFarkel];
        self.isFirstRole =  !self.isFirstRole;
    }
}

#pragma mark - Dice Label Delegate methods

// add the DieLabel instance to your dice array
- (void)onDieLabelTapped:(UILabel *)dieLabel {

    if (!self.isFirstRole) {
        //add the dice label to the array for re-rolls
        [self.dice addObject:dieLabel];

        //change the background color of dice which are saved
        dieLabel.backgroundColor = GREEN_COLOR;
        //dieLabel.textColor = [UIColor whiteColor];

        //disable the selected label
        dieLabel.enabled = NO;

        //increment the numberOfDiceScored
        self.numberOfDiceScored++;
    }
}

// set the delegate properties of all the DieLabels to the ViewController instance
- (void)setLabelDelegate {
    for (DieLabel *label in self.dieLabels) {
        label.delegate = self;
    }
}

#pragma mark - Game Playing Methods

/* Enable or Disable the user interaction for all dice. This is called
 * initially in view did load to prevent the user from interacting with the
 * dice prior to the initial roll
 */
-(void)enableAllDiceForUserInteraction:(BOOL)enable {

    //reset the dice labels for the next roll
    if (enable) {
        for (DieLabel *dieLabel in self.view.subviews) {
            dieLabel.enabled = YES;
        }
    } else {
        for (DieLabel *dieLabel in self.view.subviews) {
            dieLabel.enabled = NO;
        }
    }
}

// Check that there are dice available to earn more points,
// if not call Farkel alert
//-(void)checkGameStateAfterRollForFarkel {
//{
//    NSInteger pointsPossible = 0;
//    NSMutableArray *nonSelectedDice = [[NSMutableArray alloc]init];
//
//    for (DieLabel *dieLabel in self.view.subviews) {
//        if ([dieLabel isKindOfClass:[DieLabel class]] && dieLabel.enabled) {
//            [nonSelectedDice addObject:dieLabel];
//        }
//    }
//
//    pointsPossible = [self.score calculatePLayersTotalScore: nonSelectedDice];
//    NSLog(@"points possbile: %li",(long)pointsPossible);
//
////    if(pointsPossible == 0) {
////        [self playerFarkeledAlert];
////    }
//
//    nonSelectedDice = nil;
//}

#pragma mark - Helper Methods for Dice rolling

// roll all unchecked dice
- (void)rollAllUncheckedDice {

    for (DieLabel *dieLabel in self.view.subviews) {
        if ([dieLabel isKindOfClass:[DieLabel class]] && dieLabel.enabled) {
            [dieLabel roll];
        }
    }
}

// Remove all dice from the dice array. This method needs to be called
// before each roll after the first roll
- (void)resetSelectedDice {
    [self.dice removeAllObjects];
}






#pragma mark -
#pragma mark -
#pragma mark -




@end


























