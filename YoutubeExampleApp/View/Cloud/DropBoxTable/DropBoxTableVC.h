//
//  DropBoxTableVC.h
//  YTBPlayer
//
//  Created by Ekin Çelik on 16.07.2019.
//  Copyright © 2019 uMage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>

@interface DropBoxTableVC : UITableViewController {

}

@property (strong, nonatomic) NSArray<DBFILESMetadata *> *folderEntries;

@end

