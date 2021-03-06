//
//  ItemTableViewCell.m
//  ProxiFinal
//
//  Created by Michael Liu on 10/10/15.
//  Copyright © 2015 Michael Liu. All rights reserved.
//

#import "ItemTableViewCell.h"
#import "ItemCollectionViewCell.h"
@implementation ItemCollectionView


@end

@implementation ItemTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    
    CGRect rect = [[UIScreen mainScreen]bounds];
    CGFloat screenWidth = rect.size.width;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.sectionInset = UIEdgeInsetsMake(15,5,15,5);
    layout.itemSize = CGSizeMake(screenWidth*0.5-10,screenWidth*0.5*192.0/147.0);
    self.collectionView = [[ItemCollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
    self.layout = layout;
    [self.collectionView registerClass:[ItemCollectionViewCell class] forCellWithReuseIdentifier:@"ItemCollectionCell"];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.showsHorizontalScrollIndicator =NO;
    [self.contentView addSubview:self.collectionView];
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.collectionView.frame= self.contentView.bounds;
}

- (void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate indexPath:(NSIndexPath *)indexPath
{
    self.collectionView.dataSource = dataSourceDelegate;
    self.collectionView.delegate = dataSourceDelegate;
    self.collectionView.indexPath = indexPath;
    
    [self.collectionView reloadData];
}
-(CGSize)getContentSize{
    return [self.layout collectionViewContentSize];
}

@end
