//
//  ViewController.m
//  PebbleKit-iOS-Tutorial-2
//
//  Created by Chris Lewis on 12/9/14.
//  Copyright (c) 2014 Pebble. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *outputLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic) NSUInteger currentPage;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    self.currentPage = 0;

    self.outputLabel.text = @"Connection Pending";

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if([appDelegate.watch isConnected])
    {
        self.outputLabel.text = @"Connected";
    }else{
        self.outputLabel.text = @"Disconnected";
    }

    [self addMyButton];
}

- (void)addMyButton{
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn setFrame:CGRectMake(52, 252, 215, 40)];
    [btn setTitle:@"Update!" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

-(void) buttonClicked:(UIButton*)sender
{
    NSLog(@"buttonClicked");

    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(![appDelegate.watch isConnected])
    {
        self.outputLabel.text = @"Disconnected";
        [appDelegate connectPebble];
    }else{
        self.outputLabel.text = @"Connected";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
