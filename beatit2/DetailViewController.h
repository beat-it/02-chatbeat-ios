//
//  DetailViewController.h
//  beatit2
//
//  Created by Dusan Beblavy on 01/05/2017.
//  Copyright © 2017 Dusan Beblavy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) NSDate *detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

