//
//  ViewController.m
//  TipTacToeObjc
//
//  Created by Jose Aponte on 10/22/16.
//  Copyright © 2016 jappsku. All rights reserved.
//

#import "ViewController.h"
#import "Player.h"

@interface ViewController ()

@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) MCSession *session;
@property (nonatomic, strong) MCBrowserViewController *browser;
@property (nonatomic, strong) MCAdvertiserAssistant *advertiser;
@property (strong, nonatomic) IBOutletCollection(Player) NSArray *buttons;

@property (nonatomic, strong) NSString *currentPlayer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _currentPlayer = @"X";
    _appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [_appDelegate.mcManager setupPeerAndSessionWithDisplayName:[UIDevice currentDevice].name];
    
    [_appDelegate.mcManager advertiseSelf:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveData:) name:@"MCDidReceiveDataNotification" object:nil];
    
}

- (IBAction)connectAction:(id)sender
{
    [_appDelegate.mcManager setupMCBrowser];
    _appDelegate.mcManager.browser.delegate = self;
    [self presentViewController:_appDelegate.mcManager.browser animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)playAction:(Player *)sender
{
    NSError *error;
    NSDictionary *dict = @{@"player":_currentPlayer, @"tag": @(sender.tag)};
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    sender.player = _currentPlayer;
    [sender setBackgroundImage:[UIImage imageNamed:_currentPlayer] forState:UIControlStateNormal];
    [_appDelegate.mcManager.session sendData:data
                                     toPeers:_appDelegate.mcManager.session.connectedPeers
                                    withMode:MCSessionSendDataReliable
                                       error:&error];
    
    [self checkWinner:_currentPlayer];
}
- (IBAction)newGameAction:(id)sender
{
    for (Player *player in _buttons)
    {
        player.player = @"";
        [player setBackgroundImage:nil forState:UIControlStateNormal];
    }
    _currentPlayer = @"X";
}


-(void)receiveData:(NSNotification*) notification
{
    NSData *data = [notification.userInfo objectForKey:@"data"];
    NSError *error;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    NSString *player = [dict objectForKey:@"player"];
    NSNumber *tag = [dict objectForKey:@"tag"];
    Player *button = (Player*)[self.view viewWithTag:tag.integerValue];
    
    
    
    if ([player isEqualToString:@"X"])
    {
        _currentPlayer = @"O";
        dispatch_async(dispatch_get_main_queue(), ^{
            button.player = @"X";
            [button setBackgroundImage:[UIImage imageNamed:@"X"] forState:UIControlStateNormal];
        });
    }
    else
    {
        _currentPlayer = @"X";
        
        dispatch_async(dispatch_get_main_queue(), ^{
            button.player = @"O";
            [button setBackgroundImage:[UIImage imageNamed:@"O"] forState:UIControlStateNormal];
        });
        
    }
    NSLog(@"dict : %@", dict);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self checkWinner:player];
    });
   
    
}

-(void)checkWinner:(NSString*) player
{
    if (([[_buttons[0] player] isEqualToString:player] && [[_buttons[1] player] isEqualToString:player] && [[_buttons[2] player] isEqualToString:player]) ||
        ([[_buttons[3] player] isEqualToString:player] && [[_buttons[4] player] isEqualToString:player] && [[_buttons[5] player] isEqualToString:player]) ||
        ([[_buttons[6] player] isEqualToString:player] && [[_buttons[7] player] isEqualToString:player] && [[_buttons[8] player] isEqualToString:player]) ||
        ([[_buttons[0] player] isEqualToString:player] && [[_buttons[3] player] isEqualToString:player] && [[_buttons[6] player] isEqualToString:player]) ||
        ([[_buttons[1] player] isEqualToString:player] && [[_buttons[4] player] isEqualToString:player] && [[_buttons[7] player] isEqualToString:player]) ||
        ([[_buttons[2] player] isEqualToString:player] && [[_buttons[5] player] isEqualToString:player] && [[_buttons[8] player] isEqualToString:player]) ||
        ([[_buttons[0] player] isEqualToString:player] && [[_buttons[4] player] isEqualToString:player] && [[_buttons[8] player] isEqualToString:player]) ||
        ([[_buttons[2] player] isEqualToString:player] && [[_buttons[4] player] isEqualToString:player] && [[_buttons[6] player] isEqualToString:player]))
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Winer!"
                                                                       message:[NSString stringWithFormat:@"Ha ganado %@", player]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}


-(void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController
{
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController
{
    [browserViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
