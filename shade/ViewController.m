//
//  ViewController.m
//  shade
//
//  Created by Troy Stribling on 3/2/13.
//  Copyright (c) 2013 Troy Stribling. All rights reserved.
//

#import "ViewController.h"
#import "ViewGeneral.h"
#import "AnimateView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    ViewGeneral* general = [ViewGeneral instance];
    [general createViews:self.view];
    [general cameraViewPosition:[AnimateView inWindowRect]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
