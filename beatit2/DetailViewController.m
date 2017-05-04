//
//  DetailViewController.m
//  beatit2
//
//  Created by Dusan Beblavy on 01/05/2017.
//  Copyright © 2017 Dusan Beblavy. All rights reserved.
//

#import "DetailViewController.h"
#import <SendBirdSDK/SendBirdSDK.h>

@interface DetailViewController ()

@end

@implementation DetailViewController

- (void)configureView {
    // Update the user interface for the detail item.
    self.messages = [[NSMutableArray alloc] init];
    
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    
    self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated {
    [SBDMain removeChannelDelegateForIdentifier:_detailItem.channelUrl];
    [super viewWillDisappear:animated];
}

#pragma mark - Managing the detail item

- (void)setDetailItem:(SBDOpenChannel *)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
        
        [_detailItem enterChannelWithCompletionHandler:^(SBDError * _Nullable error) {
            if (error != nil) {
                NSLog(@"Error: %@", error);
                return;
            }
            
            [SBDMain addChannelDelegate:self identifier:_detailItem.channelUrl];
            
            SBDPreviousMessageListQuery *previousMessageQuery = [_detailItem createPreviousMessageListQuery];
            [previousMessageQuery loadPreviousMessagesWithLimit:30 reverse:YES completionHandler:^(NSArray<SBDBaseMessage *> * _Nullable messages, SBDError * _Nullable error) {
                if (error != nil) {
                    NSLog(@"Error: %@", error);
                    return;
                }
                NSLog(@"We have messages huraaaa");
                for (SBDBaseMessage *message in messages) {
                    if ([message isKindOfClass:[SBDUserMessage class]]){
                        SBDUserMessage *myMessage = (SBDUserMessage *)message;
                        JSQMessage *messageX = [[JSQMessage alloc]
                                                initWithSenderId:myMessage.sender.userId
                                                senderDisplayName:myMessage.sender.nickname
                                                date:[NSDate dateWithTimeIntervalSince1970: (myMessage.createdAt/1000)]
                                                text:myMessage.message];
                        [self.messages insertObject:messageX atIndex:0];
                    }
                    if ([message isKindOfClass:[SBDFileMessage class]]){
                        
//                        [_detailItem deleteMessage:message completionHandler:^(SBDError * _Nullable error) {
//                            if (error != nil) {
//                                NSLog(@"Error");
//                                return;
//                            }
//                        }];
                        
                        SBDFileMessage *myMessage = (SBDFileMessage *)message;
                        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:myMessage.url]]];
                        
                        JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:image];
                        
                        JSQMessage *messageX = [[JSQMessage alloc]
                                                initWithSenderId:myMessage.sender.userId
                                                senderDisplayName:myMessage.sender.nickname
                                                date:[NSDate dateWithTimeIntervalSince1970: (myMessage.createdAt/1000)]
                                                media:photoItem];
                        [self.messages insertObject:messageX atIndex:0];
                    }
                    
                    
                    
                }
                [self performSelectorOnMainThread:@selector(finishReceivingMessage) withObject:nil waitUntilDone:YES];
            }];
            
            
        }];
        //        }];
    }
}

#pragma mark - JSQMessageVievController

- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date {
    NSString *myText = text;

    
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId
                                             senderDisplayName:senderDisplayName
                                                          date:date
                                                          text:myText];
    [self.messages addObject:message];
    
    [[self detailItem] sendUserMessage:myText data:nil completionHandler:^(SBDUserMessage * _Nullable userMessage, SBDError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Error: %@", error);
            return;
        }
        NSLog(@"Message sent");
    }];
    [self finishSendingMessageAnimated:YES];
}

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.messages objectAtIndex:indexPath.item];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.messages.count;
}

-(id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.outgoingBubbleImageData;
    }
    
    return self.incomingBubbleImageData;
    
}

-(id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    /**
     *  Configure almost *anything* on the cell
     *
     *  Text colors, label text, label colors, etc.
     *
     *
     *  DO NOT set `cell.textView.font` !
     *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
     *
     *
     *  DO NOT manipulate cell layout information!
     *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
     */
    
    JSQMessage *msg = [self.messages objectAtIndex:indexPath.item];
    
    if (!msg.isMediaMessage) {
        
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor blackColor];
        }
        else {
            cell.textView.textColor = [UIColor whiteColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    else {
        cell.textView.textColor = [UIColor blackColor];
    }
    
    //cell.accessoryButton.hidden = ![self shouldShowAccessoryButtonForMessage:msg];
    
    return cell;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
     *  The other label text delegate methods should follow a similar pattern.
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    /**
     *  iOS7-style sender name labels
     */
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }
    
    /**
     *  Don't specify attributes to use the defaults.
     */
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
     */
    
    /**
     *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
     *  The other label height delegate methods should follow similarly
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  iOS7-style sender name labels
     */
    JSQMessage *currentMessage = [self.messages objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

-(void)channel:(SBDBaseChannel *)sender didReceiveMessage:(SBDBaseMessage *)message {
    //message.channelType
    if ([message isKindOfClass:[SBDUserMessage class]]){
        SBDUserMessage *myMessage = (SBDUserMessage *)message;
        JSQMessage *messageX = [[JSQMessage alloc]
                                initWithSenderId:myMessage.sender.userId
                                senderDisplayName:myMessage.sender.nickname
                                date:[NSDate dateWithTimeIntervalSince1970: (myMessage.createdAt/1000)]
                                text:myMessage.message];
        [self.messages addObject:messageX];
    }
    if ([message isKindOfClass:[SBDFileMessage class]]){
        SBDFileMessage *myMessage = (SBDFileMessage *)message;
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:myMessage.url]]];
        
        JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:image];
        JSQMessage *messageX = [[JSQMessage alloc]
                                initWithSenderId:myMessage.sender.userId
                                senderDisplayName:myMessage.sender.nickname
                                date:[NSDate dateWithTimeIntervalSince1970: (myMessage.createdAt/1000)]
                                media:photoItem];
        [self.messages addObject:messageX];
    }
    [self finishReceivingMessageAnimated:YES];
}

- (void)didPressAccessoryButton:(UIButton *)sender
{
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Media messages" message:@"Send media message to chat" preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
        // Cancel button tappped.
        //[self dismissViewControllerAnimated:YES completion:^{
        //}];
    }]];
    
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Send photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSData * myData = UIImagePNGRepresentation([UIImage imageNamed:@"beatit.png"]);
        // Send photo button tapped.
        [[self detailItem] sendFileMessageWithBinaryData:myData filename:@"imagex" type:@"image/png" size:myData.length data:nil completionHandler:^(SBDFileMessage * _Nullable fileMessage, SBDError * _Nullable error) {
            JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:[UIImage imageNamed:@"beatit.png"]];
            JSQMessage *messageX = [[JSQMessage alloc]
                                    initWithSenderId:fileMessage.sender.userId
                                    senderDisplayName:fileMessage.sender.nickname
                                    date:[NSDate dateWithTimeIntervalSince1970: (fileMessage.createdAt/1000)]
                                    media:photoItem];
            [self.messages addObject:messageX];
            [self performSelectorOnMainThread:@selector(finishSendingMessage) withObject:nil waitUntilDone:YES];
        }];
        
        //[self dismissViewControllerAnimated:YES completion:^{
        //}];
    }]];
    
    // Present action sheet.
    [self presentViewController:actionSheet animated:YES completion:nil];
}



@end
