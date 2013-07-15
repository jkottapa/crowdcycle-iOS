//  CommentCell.m

#import "CommentCell.h"
#import "User.h"
#import "Comment.h"

@implementation CommentCell

@synthesize comment = _comment;

#pragma mark - Setters

- (void)setComment:(Comment *)comment; {
  _comment = comment;
  
  _userNameLabel.text = comment.user.name;
  _commentLabel.text = comment.text;
  
  CGSize newSize = [comment.text sizeWithFont:_commentLabel.font forWidth:_commentLabel.frame.size.width lineBreakMode:NSLineBreakByWordWrapping];
  _commentLabel.frame = CGRectMake(_commentLabel.frame.origin.x, _commentLabel.frame.origin.y, _commentLabel.frame.size.width, newSize.height);
}

#pragma mark - Init

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier; {
  if((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])){
    
  }
  return self;
}

@end