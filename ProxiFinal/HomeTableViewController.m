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
@property (weak, nonatomic) IBOutlet UIRefreshControl *refresh;
@property (strong,nonatomic) UIRefreshControl *bottomRefresher;

@property (strong,nonatomic) UICollectionView *collectionView;
@property (strong,nonatomic) ItemContainer *itemContainer;
@property (strong,nonatomic) ItemConnection *itemConnection;
@property (strong,nonatomic) NSArray *datasourceItemArray;
@property (strong,nonatomic) NSArray *categoryImagesArray;

@end

@implementation HomeTableViewController{
    int i; //How many items to load first
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupDatabase];
    self.categoryImagesArray = @[@"Book",@"Electronic",@"Clothing",@"Equipment",@"Furniture",@"Other"];

    self.itemConnection = [[ItemConnection alloc]init];
    [self setupTestingSources];
    self.itemContainer = [[ItemContainer alloc]init];
    [self.navigationController setNavigationBarHidden:YES];
    
    i = 10;
    
    UINib *nibForScrollViewCell = [UINib nibWithNibName:@"HomePageTableViewCell" bundle:nil];
    [self.tableView registerNib:nibForScrollViewCell forCellReuseIdentifier:@"ScrollViewCell"];
    self.tableView.tableHeaderView = [[HomePageSlideView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,200)];
    [self.tableView setShowsVerticalScrollIndicator:NO];
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self viewMoreButtonTapped];
    [self.refresh addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
    self.bottomRefresher = [UIRefreshControl new];
    self.bottomRefresher.triggerVerticalOffset = 100.;
    [self.bottomRefresher addTarget:self action:@selector(viewMoreButtonTapped) forControlEvents:UIControlEventValueChanged];
    self.tableView.bottomRefreshControl = self.bottomRefresher;

}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
//    [self viewMoreButtonTapped];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row ==0) {
        static NSString *CellIdentifierRow1 = @"CellIdentifierRow1";
        
        CategoryTableViewCell *cell = (CategoryTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifierRow1];
        
        if (!cell)
        {
            cell = [[CategoryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierRow1];
        }
        return cell;
    }else if(indexPath.row ==1){
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

        return 2;
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
    if ([collectionView isKindOfClass:[ItemCollectionView class]]) {
        Item *item = [self.datasourceItemArray objectAtIndex:indexPath.item];
        ItemDetailViewController *itemDetailController = [[ItemDetailViewController alloc]initWithNibName:@"ItemDetailViewController" bundle:nil];
        itemDetailController.item = item;
        [self.navigationController pushViewController:itemDetailController animated:YES];
    }else if ([collectionView isKindOfClass:[CategoryCollectionView class]]){
        NSString *categoryName = [self.categoryImagesArray objectAtIndex:indexPath.item];
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
        [cell.contentView addSubview:collectionViewArray[indexPath.item]];

    
        
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
        cell.cellPrice.text =[[@"$ " stringByAppendingString:item.price_current]stringByAppendingString:@" USD"];
        cell.cellLabel.text = item_title;
        cell.cellLabel.textAlignment = NSTextAlignmentCenter;
        cell.layer.masksToBounds = NO;
        cell.layer.shadowOffset = CGSizeMake(-1, 2);
        cell.layer.shadowRadius = 2;
        cell.layer.shadowOpacity = 0.3;
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
        
    }else if([cell isKindOfClass:[ItemTableViewCell class]]){
        ItemTableViewCell *itemCell = (ItemTableViewCell *)cell;
        [itemCell setCollectionViewDataSourceDelegate:self indexPath:indexPath];
        
    }else{
        
    }
    
}


//TableViewSettings

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect rect = [[UIScreen mainScreen]bounds];
    CGFloat screenWidth = rect.size.width;
    CGFloat rowHeight = screenWidth *0.5*192.0/147.0f;
    
    if (indexPath.row ==0) {
        return 120;
    }else if(indexPath.row ==1){
        
        if ([self.datasourceItemArray count]%2==1) {
           
            return [self.datasourceItemArray count]*(rowHeight/2+7.5)+rowHeight/2+7.5+15;
        }
        else{
            return [self.datasourceItemArray count]*(rowHeight/2+7.5)+15;
        }
        
    }else{
        return 10;
    }
}





//Setup



-(void)setupTestingSources{
    const NSInteger numberOfTableViewRows = 1;
    const NSInteger numberOfCollectionViewCells = [self.categoryImagesArray count];
    
    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:numberOfTableViewRows];
    
    for (NSInteger tableViewRow = 0; tableViewRow < numberOfTableViewRows; tableViewRow++)
    {
        NSMutableArray *imagesArray = [NSMutableArray arrayWithCapacity:numberOfCollectionViewCells];
        
        for (NSInteger collectionViewItem = 0; collectionViewItem < numberOfCollectionViewCells; collectionViewItem++)
        {
            
            UIImageView *categoryImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 85, 100)];
            UIImage *categoryImage= [UIImage imageNamed:[self.categoryImagesArray objectAtIndex:collectionViewItem]];
            if (!categoryImage) {
                categoryImage = [UIImage imageNamed:@"manshoes"];
            }
            [categoryImageView setImage:categoryImage];
            [imagesArray addObject:categoryImageView];
        }
        
        [mutableArray addObject:imagesArray];
    }
    
    self.colorArray = [NSArray arrayWithArray:mutableArray];
    

}



-(void)setupDatabase{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshTable:) name:@"FetchItemNotification" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateTable) name:@"updateTable" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateTableOnce) name:@"UpdateTableNotification" object:nil];
}

-(void)refreshTable:(NSNotification *)noti{
    [self.itemContainer addItemsFromJSONDictionaries:[noti object]];
    [self updateTable];
    [self.refresh endRefreshing];
}

-(void)updateTable{
    NSLog(@"update");
    self.datasourceItemArray = [[self.itemContainer allItem] copy];
    [self.tableView reloadData];
    [self.refresh endRefreshing];
    [self.bottomRefresher endRefreshing];
}
-(void)updateTableOnce{
    NSInteger containerNum = [self.itemContainer.container count];
    [self.itemContainer.container removeAllObjects];
    [self.itemConnection fetchItemFromIndex:0 amount:containerNum];
    [self.refresh endRefreshing];
    [self.bottomRefresher endRefreshing];
}
-(void)viewMoreButtonTapped{
    
    NSInteger containerNum = [self.itemContainer.container count];
    [self.itemContainer.container removeAllObjects];
    [self.itemConnection fetchItemFromIndex:0 amount:containerNum+i];

    //Refresh indicator show
    
}
-(void)updateViewController{
    [self.itemConnection fetchItemFromIndex:0 amount:[self.itemContainer.container count]];
    [self.itemContainer.container removeAllObjects];
}

-(void)refreshData{
    NSInteger containerNum = [self.itemContainer.container count];
    [self.itemContainer.container removeAllObjects];
    [self.itemConnection fetchItemFromIndex:0 amount: containerNum];
    [self.refresh beginRefreshing];
}

@end
