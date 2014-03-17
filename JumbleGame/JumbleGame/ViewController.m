//
//  ViewController.m
//  JumbleGame
//
//  Created by Gurminder Deep Singh on 3/15/14.
//  Copyright (c) 2014 Gurminder Deep Singh. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
{
    NSMutableArray *results;
    NSArray *dictionary;
    
    dispatch_queue_t serialQueue;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.textField.delegate = self;
    
    results = [[NSMutableArray alloc] init];
    self.foundLabel.text = @"";
    
    serialQueue = dispatch_queue_create("jumbleSerialQueue", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(serialQueue, ^{
        
        NSString *listPath = [[NSBundle mainBundle] pathForResource:@"brit-a-z" ofType:@"txt"];
        
        if (listPath)
        {
            NSString *text = [NSString stringWithContentsOfFile:listPath encoding:NSASCIIStringEncoding error:nil];
            
            dictionary = [text componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        }
        
    });
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)solveJumble:(id)sender
{
    if (![self.textField isFirstResponder])
    {
        return;
    }
    
    [self.activityIndicator startAnimating];
    
    [self.textField resignFirstResponder];
    NSString *currentString = [self.textField.text lowercaseString];
    
    NSDictionary *currentStringDict = [self dictionaryFromString:currentString];
    NSSet *allKeys = [NSSet setWithArray:[currentStringDict allKeys]];
    
    [results removeAllObjects];
    
    NSDate *startTime = [NSDate date];
    
    dispatch_async(serialQueue, ^{
        
        dispatch_apply(dictionary.count, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^(size_t index)
       {
           NSString *string = [[dictionary objectAtIndex:index] lowercaseString];
           if (string.length > currentString.length || string.length <= 1)
           {
               return;
           }
           
           NSDictionary *newStringDict = [self dictionaryFromString:string];
           NSSet *allStringKeys = [NSSet setWithArray:[newStringDict allKeys]];
           
           if (![allStringKeys isSubsetOfSet:allKeys])
           {
               return;
           }
           
           BOOL passed = YES;
           
           for (NSString *key in [newStringDict allKeys])
           {
               if ([newStringDict[key] intValue] > [currentStringDict[key] intValue])
               {
                   passed = NO;
                   break;
               }
           }
           
           if (passed)
           {
               [results addObject:string];
           }
       });
        
        dispatch_sync(dispatch_get_main_queue(), ^{
           
            NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:startTime];
            
            self.foundLabel.text = [NSString stringWithFormat:@"%lu %@ found, took %f seconds", results.count, results.count > 1 ? @"words" : @"word", interval];
            
            [self.tableView reloadData];
            
            [self.activityIndicator stopAnimating];
            
        });
    });
}

-(NSDictionary *)dictionaryFromString:(NSString *)string
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    for (int i =0; i < string.length; i++)
    {
        NSString *character = [NSString stringWithFormat:@"%c", [string characterAtIndex:i]];
        
        NSNumber *count = [dict objectForKey:character];
        if (count)
        {
            count = @([count intValue] + 1);
        }
        else
        {
            count = @(1);
        }
        
        [dict setObject:count forKey:character];
    }
    
    return dict;
}

#pragma mark - Text field delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self solveJumble:nil];
    [textField resignFirstResponder];
    return NO;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return textField.userInteractionEnabled;
}


#pragma mark - Table view delegates

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return results.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = [results objectAtIndex:indexPath.row];
    
    return cell;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}


@end
