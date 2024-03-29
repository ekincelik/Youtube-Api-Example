//
//  DropBoxTableVC.m
//  YTBPlayer
//
//  Created by Ekin Çelik on 16.07.2019.
//  Copyright © 2019 uMage. All rights reserved.
//

#import "DropBoxTableVC.h"

@interface DropBoxTableVC ()

@end

@implementation DropBoxTableVC
@synthesize folderEntries;



- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [folderEntries count];
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section
{
    NSString *ret = nil;
    return ret;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    CellIdentifier = [NSString stringWithFormat:@"Line - %ld", (long)(indexPath.row)];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    DBFILESMetadata *entry = folderEntries[indexPath.row];
    if ([entry isKindOfClass:[DBFILESFileMetadata class]])
    {
        DBFILESFileMetadata *fileMetadata = (DBFILESFileMetadata *)entry;
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.text = fileMetadata.name;
        cell.detailTextLabel.textColor = [UIColor colorWithRed:0.55 green:0.55 blue:0.55 alpha:1.0];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.1f KB,  %@", (float)fileMetadata.size.intValue/1024.0, [self GetTimeStringFrom:fileMetadata.clientModified forFileName:NO]];
        cell.imageView.image = [UIImage imageNamed:@"Save.png"];
    }
    else if ([entry isKindOfClass:[DBFILESFolderMetadata class]])
    {
        DBFILESFolderMetadata *folderMetadata = (DBFILESFolderMetadata *)entry;
        cell.textLabel.text = folderMetadata.name;
        cell.imageView.image = [UIImage imageNamed:@"Open.png"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)aTableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.textLabel.font = [UIFont boldSystemFontOfSize:15];
    header.textLabel.textColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
}


- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DBFILESMetadata *entry = folderEntries[indexPath.row];
    if ([entry isKindOfClass:[DBFILESFileMetadata class]]) {
//        [[NavigationManager sharedManager].cloudContainerViewController.cloudMusic onDropboxCancel];
//        [[NavigationManager sharedManager].cloudContainerViewController.cloudMusic performSelector:@selector(downloadProc:) withObject:entry.pathLower afterDelay:0.3];
    }
    else if ([entry isKindOfClass:[DBFILESFolderMetadata class]]) {
//        [[NavigationManager sharedManager].cloudContainerViewController.cloudMusic setDropboxWindow:entry];
    }
}



- (NSString *)GetTimeStringFrom:(NSDate *)dt forFileName:(BOOL)bFileName
{
    NSTimeZone* gmTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    NSTimeZone* localTimeZone = [NSTimeZone systemTimeZone];
    
    NSInteger sourceGMTOffset = [gmTimeZone secondsFromGMTForDate:dt];
    NSInteger destinationGMTOffset = [localTimeZone secondsFromGMTForDate:dt];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    NSDate* destinationDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:dt];
    
    NSString *txt = [destinationDate description];
    NSArray *arr = [txt componentsSeparatedByString:@" "];
    NSString *date = [arr objectAtIndex:0];
    NSString *time = [arr objectAtIndex:1];
    
    arr = [date componentsSeparatedByString:@"-"];
    if( bFileName )
        date = [NSString stringWithFormat:@"%@-%@-%@", [arr objectAtIndex:1], [arr objectAtIndex:2], [arr objectAtIndex:0]];
    else
        date = [NSString stringWithFormat:@"%@/%@/%@", [arr objectAtIndex:1], [arr objectAtIndex:2], [arr objectAtIndex:0]];
    
    return [NSString stringWithFormat:@"%@ %@", date, time];
}
@end
