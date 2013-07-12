//  CommentCell.h

#import <UIKit/UIKit.h>

@class Comment;

@interface CommentCell : UITableViewCell {
  Comment          * _comment;
  
  IBOutlet UILabel * _commentLabel;
  IBOutlet UILabel * _userNameLabel;
}

@property (nonatomic, retain) Comment * comment;

@end