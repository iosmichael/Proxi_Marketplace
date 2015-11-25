//
//  HomeTableViewController.m
//  ProxiFinal
//
//  Created by Michael Liu on 10/10/15.
//  Copyright © 2015 Michael Liu. All rights reserved.
//
#import "HomePageSlideView.h"
#import "HomeTableViewController.h"
#import "CategoryTableViewCell.h"
#import "ItemCollectionViewCell.h"
#import "ItemTableViewCell.h"
#import "ItemContainer.h"
#import "ItemConnection.h"
#import "ItemDetailViewController.h"
#import "CategoryDetailTableViewController.h"

#define CategoryNum 10
#define Image_url_prefix @"http://proximarketplace.com/database/images/"




@interface HomeTableViewController ()
@property (strong,nonatomic) NSArray *colorArray;
@property (strong,nonatomic) NSMutableDictionary *contentOffsetDictionary;
@property (strong,nonatomic) UICollectionView *collectionView;
@property (strong,nonatomic) ItemContainer *itemContainer;
@property (strong,nonatomic) ItemConnection *itemConnection;
@property (strong,nonatomic) NSArray *datasourceItemArray;

@end

@implementation HomeTableViewController{
    int i; //How many items to load first
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupDatabase];
    self.itemConnection = [[ItemConnection alloc]init];
    [self.itemConnection fetchItemFromIndex:0 amount:10];
    [self setupTestingSources];
    self.itemContainer = [[ItemContainer alloc]init];
    [self.navigationController setNavigationBarHidden:YES];
    i = 10;
    
    UINib *nibForScrollViewCell = [UINib nibWithNibName:@"HomePageTableViewCell" bundle:nil];
    [self.tableView registerNib:nibForScrollViewCell forCellReuseIdentifier:@"ScrollViewCell"];
    self.tableView.tableHeaderView = [[HomePageSlideView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,200)];
    UIView *footerView = [self setupFooterView];
    
    self.tableView.tableFooterView = footerView;
    self.tableView.backgroundColor = [UIColor colorWithRed:153.0f/255.0f green:226.0f/255.0f blue:225.0f/255.0f alpha:1];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section ==0) {
        static NSString *CellIdentifierRow1 = @"CellIdentifierRow1";
        
        CategoryTableViewCell *cell = (CategoryTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifierRow1];
        
        if (!cell)
        {
            cell = [[CategoryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierRow1];
        }
        return cell;
    }else if(indexPath.section ==1){
        static NSString *CellIdentifierRow2 = @"CellIdentifierRow2";
        ItemTableViewCell *cell = (ItemTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifierRow2];
        if (!cell) {
            cell = [[ItemTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierRow2];
        }
        return cell;
    }else{
        return nil;
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
        return 1;
}

/*
 CategoryCollectionView...
 */

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if ([collectionView isKindOfClass:[CategoryCollectionView class]]) {
        NSArray *collectionViewArray = self.colorArray[[(CategoryCollectionView *)collectionView indexPath].row];
        return collectionViewArray.count;
    }else if ([collectionView isKindOfClass:[ItemCollectionView class]]){
        return [self.datasourceItemArray count];
    }else{
        return 1;
    }
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath  {
    
    NSLog(@"%i",indexPath.item);
    if ([collectionView isKindOfClass:[ItemCollectionView class]]) {
        Item *item = [self.datasourceItemArray objectAtIndex:indexPath.item];
        ItemDetailViewController *itemDetailController = [[ItemDetailViewController alloc]initWithNibName:@"ItemDetailViewController" bundle:nil];
        itemDetailController.item = item;
        [self.navigationController pushViewController:itemDetailController animated:YES];
    }else if ([collectionView isKindOfClass:[CategoryCollectionView class]]){
        NSString *categoryName = @"Book";
        CategoryDetailTableViewController *categoryDTVC = [[CategoryDetailTableViewController alloc]init];
        categoryDTVC.categoryName = categoryName;
        [self.navigationController pushViewController:categoryDTVC animated:YES];
    }
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([collectionView isKindOfClass:[CategoryCollectionView class]]) {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Category" forIndexPath:indexPath];
        //custom cell
        NSArray *collectionViewArray = self.colorArray[[(CategoryCollectionView *)collectionView indexPath].row];
        cell.backgroundColor = collectionViewArray[indexPath.item];

    
        
        return cell;
    }else if ([collectionView isKindOfClass:[ItemCollectionView class]]){
        self.collectionView = collectionView;
        UINib *nib = [UINib nibWithNibName:@"ItemCollectionViewCell" bundle: nil];
        [collectionView registerNib:nib forCellWithReuseIdentifier:@"ItemCollectionCell"];
        ItemCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ItemCollectionCell" forIndexPath:indexPath];
        
        //custom cell
        Item *item = [self.itemContainer.container objectAtIndex:indexPath.row];
        if (!item.image_url) {
            UIImage *item_img= [UIImage imageNamed:@"manshoes"];
            [cell.cellImage setImage:item_img];
        }else{

            dispatch_async(dispatch_get_global_queue(0,0), ^{
                NSError *error;
                NSString *urlString =[Image_url_prefix stringByAppendingString:item.image_url];
                NSURL *url = [NSURL URLWithString:urlString];
                NSData *item_image_data = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:&error];
                if (error) {
                    NSLog(@"%@",[error description]);
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    ItemCollectionViewCell *cell = (ItemCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
                    [cell.cellImage setImage:[UIImage imageWithData: item_image_data]];
                    
                });
            });
            
            
        }
        NSString *item_title = item.item_title;
        cell.cellPrice.text =[@"$ " stringByAppendingString:item.price_current];
        cell.cellLabel.backgroundColor = [UIColor colorWithRed:140/255.0 green:158/255.0 blue:255/255.0 alpha:1];
        cell.cellLabel.textColor = [UIColor whiteColor];
        cell.cellLabel.text = item_title;
        cell.cellLabel.textAlignment = NSTextAlignmentCenter;
        return cell;
    }else{
        return nil;
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[CategoryTableViewCell class]]) {
        CategoryTableViewCell *categoryCell = (CategoryTableViewCell *)cell;
        [categoryCell setCollectionViewDataSourceDelegate:self indexPath:indexPath];
        NSInteger index = categoryCell.collectionView.tag;
        
        CGFloat horizontalOffset = [self.contentOffsetDictionary[[@(index) stringValue]] floatValue];
        [categoryCell.collectionView setContentOffset:CGPointMake(horizontalOffset, 0)];
    }else if([cell isKindOfClass:[ItemTableViewCell class]]){
        ItemTableViewCell *itemCell = (ItemTableViewCell *)cell;
        [itemCell setCollectionViewDataSourceDelegate:self indexPath:indexPath];
        //NSInteger index = itemCell.collectionView.tag;
        
       // CGFloat horizontalOffset = [self.contentOffsetDictionary[[@(index) stringValue]] floatValue];
        //[itemCell.collectionView setContentOffset:CGPointMake(horizontalOffset, 0)];
    }else{
        
    }
    
}


//TableViewSettings

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section ==0) {
        return 120;
    }else if(indexPath.section ==1){
        
        if ([self.datasourceItemArray count]%2==1) {
            return [self.datasourceItemArray count]*120+120;
        }
        else{
            return [self.datasourceItemArray count]*120;
        }
        
    }else{
        return 10;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return 35;
            break;
        case 1:
            return 15;
            break;
        default:
            return 0;
            break;
    }
   
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = @"Category";
            break;
        case 1:
            sectionName = @"What's Hot";
            break;
            // ...
        default:
            sectionName = @"";
            break;
    }
    return sectionName;
}



//Setup



-(void)setupTestingSources{
    const NSInteger numberOfTableViewRows = 1;
    const NSInteger numberOfCollectionViewCells = 5;
    
    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:numberOfTableViewRows];
    
    for (NSInteger tableViewRow = 0; tableViewRow < numberOfTableViewRows; tableViewRow++)
    {
        NSMutableArray *colorArray = [NSMutableArray arrayWithCapacity:numberOfCollectionViewCells];
        
        for (NSInteger collectionViewItem = 0; collectionViewItem < numberOfCollectionViewCells; collectionViewItem++)
        {
            
            CGFloat red = arc4random() % 255;
            CGFloat green = arc4random() % 255;
            CGFloat blue = arc4random() % 255;
            UIColor *color = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0f];
            
            [colorArray addObject:color];
        }
        
        [mutableArray addObject:colorArray];
    }
    
    self.colorArray = [NSArray arrayWithArray:mutableArray];
    
    self.contentOffsetDictionary = [NSMutableDictionary dictionary];
}

-(UIView *)setupFooterView{
    UIView *footerButtonView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    footerButtonView.backgroundColor = [UIColor clearColor];
    UIButton *viewMoreButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width*0.05, 0, self.view.frame.size.width*0.9, 50)];

    [viewMoreButton setTitle:@"View More" forState:UIControlStateNormal];
    [viewMoreButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [viewMoreButton.layer setCornerRadius:25];
    [footerButtonView addSubview:viewMoreButton];
    viewMoreButton.backgroundColor = [UIColor colorWithRed:251.0f/255.0f green:176.0f/255.0f blue:87.0f/255.0f alpha:1];
    [viewMoreButton addTarget:self action:@selector(viewMoreButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    return footerButtonView;
    
}


-(void)setupDatabase{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshTable:) name:@"FetchItemNotification" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateTable) name:@"updateTable" object:nil];
}

-(void)refreshTable:(NSNotification *)noti{
    [self.itemContainer addItemsFromJSONDictionaries:[noti object]];
    [self updateTable];
}

-(void)updateTable{
    NSLog(@"update");
    self.datasourceItemArray = [[self.itemContainer allItem] copy];
    [self.tableView reloadData];
}

-(void)viewMoreButtonTapped{
    NSLog(@"%@", [self.itemConnection description]);
    NSLog(@"%@", [self.itemContainer.container description]);
    [self.itemConnection fetchItemFromIndex:0 amount:[self.itemContainer.container count]+i];
    [self.itemContainer.container removeAllObjects];
}


@end