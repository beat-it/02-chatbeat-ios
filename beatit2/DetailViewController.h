//
//  DetailViewController.h
//  beatit2
//
//  Created by Dusan Beblavy on 01/05/2017.
//  Copyright © 2017 Dusan Beblavy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JSQMessagesViewController/JSQMessages.h>
#import <SendBirdSDK/SendBirdSDK.h>

@interface DetailViewController : JSQMessagesViewController<SBDChannelDelegate>

@property (strong, nonatomic) SBDOpenChannel *detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@property (strong, nonatomic) NSMutableArray *messages;

@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;

@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;

@end

