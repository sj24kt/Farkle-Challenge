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
}

// create an score object if one does not already exist (lazy instantiation)
- (CalculateScore *)score {

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
        [self checkGameStateAfterRollForFarkel];
        self.isFirstRole =  !self.isFirstRole;
    } else {
        [self determineScoreForSelectedDice];
        [self showScoreForTurn];
        [self resetSelectedDice];
        [self rollAllUncheckedDice];
        [self checkGameStateAfterRollForFarkel];
        [self checkGameStateAfterRollForHotDice];
    }
}

// Add the total points banked to the players total score
-(IBAction)onBankPointsScoredPressed:(id)sender {

    self.scoreForTurn += [self.score calculatePLayersTotalScore:self.dice];
    [self bankedPointsAlert];
    [self updatePlayersTotalScoreForEndOfTurn];
    [self endCurrentPlayersTurnReadyForNewPlayer];
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

// Enable or Disable the user interaction for all dice. This is called
// initially in view did load to prevent the user from interacting with
// the dice prior to the initial roll
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
-(void)checkGameStateAfterRollForFarkel {

    NSInteger pointsPossible = 0;
    NSMutableArray *nonSelectedDice = [[NSMutableArray alloc]init];

    for (DieLabel *dieLabel in self.view.subviews) {
        if ([dieLabel isKindOfClass:[DieLabel class]] && dieLabel.enabled) {
            [nonSelectedDice addObject:dieLabel];
        }
    }

    pointsPossible = [self.score calculatePLayersTotalScore: nonSelectedDice];
    NSLog(@"points possbile: %li",(long)pointsPossible);

    if(pointsPossible == 0) {
        //[self playerFarkeledAlert];
        NSLog(@"Call player farkled alert");
    }

    nonSelectedDice = nil;
}

// Update the players score for the selected dice
// then reset the game state so the player can role again
-(void)playerHasHotDiceResetForPlayersNextRole {
    //update the players score
    self.scoreForTurn += [self.score calculatePLayersTotalScore:self.dice];

    //reset the hot dice counter and status flag
    self.numberOfDiceScored = 0;

    //reset the game state for next role
    [self resetSelectedDice];
    [self resetAllDiceForNextRoll];
}

// Deterine the points for the given turn. Add any scored dice
// to the scoredDice array to avoid double counting, and reset
// the selected dice array to empty for the next turn
-(void)determineScoreForSelectedDice {
    self.scoreForTurn += [self.score calculatePLayersTotalScore: self.dice];
}

// Player has "Farkled", forefitting all points and losing their turn
// The gamed state need to be reset for the next player, and the turn advanced
- (void)playerFarkledResetForNextPlayer {

    //forefit all points earned that turn
    self.scoreForTurn = 0;
    [self endCurrentPlayersTurnReadyForNewPlayer];
    [self nextPlayersTurn];
    [self showScoreForTurn];
}

// Check the number of dice scored is equal to 6,
// if so the player has HOT dice and we need to reset
// the game state for the players next role
-(void)checkGameStateAfterRollForHotDice {

    if (self.numberOfDiceScored == 6) {
        [self playerHasHotDiceAlert];
        return;
    }
}

// The player's turn has ended, we need to update the player's score, reset// the dice for rolling, clear selected dice, update the view and change the player
- (void)endCurrentPlayersTurnReadyForNewPlayer {

    if(self.Player1) {

        [self updatePlayersTotalScoreForEndOfTurn];
        self.Player1 = !self.Player1;
        [self resetAllDiceForNextRoll];
        [self resetSelectedDice];
        [self nextPlayersTurn];
        self.player1TotalScoreLabel.backgroundColor = GREEN_COLOR;
        self.player2TotalScoreLabel.backgroundColor = RED_COLOR;
    } else {

        [self updatePlayersTotalScoreForEndOfTurn];
        self.Player1 = !self.Player1;
        [self resetAllDiceForNextRoll];
        [self resetSelectedDice];
        [self nextPlayersTurn];
        self.player1TotalScoreLabel.backgroundColor = RED_COLOR;
        self.player2TotalScoreLabel.backgroundColor = GREEN_COLOR;
    }
}

#pragma mark - Helper Methods for Dice rolling

// roll all unchecked dice
- (void)rollAllUncheckedDice {

    for (DieLabel *dieLabel in self.view.subviews) {
        if ([dieLabel isKindOfClass:[DieLabel class]] && dieLabel.enabled) {
            [dieLabel roll];
        }
    }
}

// Remove all dice from the dice array. This method needs to be
// called before each roll after the first roll
- (void)resetSelectedDice {
    [self.dice removeAllObjects];
}

// Clear all label values, set the background color back to
// start color and set all DieLabels to Enabled
-(void)resetAllDiceForNextRoll {
    self.numberOfDiceScored = 0;

    //reset the dice labels for the next roll
    for (DieLabel *dieLabel in self.view.subviews) {
        if ([dieLabel isKindOfClass:[DieLabel class]]) {
            dieLabel.text = @"0";
            dieLabel.backgroundColor = nil;
            dieLabel.enabled = YES;
        }
    }
}

// The players turn is over, update the score and update the view
- (void)updatePlayersTotalScoreForEndOfTurn {
    if (self.Player1) {
        self.player1TotalScore += self.scoreForTurn;
        self.player1TotalScoreLabel.text = [NSString stringWithFormat:@"%li",(long)self.player1TotalScore];
        self.scoreForTurn = 0;
        self.currentPointsLabel.text = @"0";
    } else {
        self.player2TotalScore += self.scoreForTurn;
        self.player2TotalScoreLabel.text = [NSString stringWithFormat:@"%li",(long)self.player2TotalScore];
        self.scoreForTurn = 0;
        self.currentPointsLabel.text = @"0";
    }
}

#pragma mark - Alerts and UIAlervtViewDelegate Methods

// player Farkeled!!
-(void)playerFarkeledAlert {
    
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Farkel"
                                                       message:@"You Farkeled, all points for turn lost!"
                                                      delegate:self
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles: nil];
    [alertView show];
}

// Update the points for the current turn in the view
- (void)showScoreForTurn {
    self.currentPointsLabel.text = [NSString stringWithFormat:@" Current Turn Points: %li",(long)self.scoreForTurn];
}

// Called alert notification of points banked/saved
- (void)bankedPointsAlert {

    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Points Banked!"
                                                       message:[NSString stringWithFormat:@"You banked %ld points!", (long)self.scoreForTurn]
                                                      delegate:self
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles: nil];
    [alertView show];
}

// Called alert when the game is over and the next Player starts their turn
-(void)nextPlayersTurn {

    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Next Player"
                                                       message:@"End of turn, next player roll!"
                                                      delegate:self
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles: nil];
    [alertView show];
}

//
-(void)playerHasHotDiceAlert {

    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Hot Dice"
                                                       message:@"You've got Hot Dice, select and roll again!"
                                                      delegate:self
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles: nil];
    [alertView show];
}

// When the alert view is dismissed, check if it is a Farkel state or Hot Dice state
// and take appropiate action
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {

    //if player farkeled
    if([alertView.title isEqualToString:@"Farkel"]) {
        [self playerFarkledResetForNextPlayer];
    } else if ([alertView.title isEqualToString:@"Hot Dice"]) {
        //[self playerHasHotDiceResetForPlayersNextRole];
    }
}





#pragma mark -
#pragma mark -




@end


























