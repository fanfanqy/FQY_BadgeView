//
//  BadgeView.h
//  FQY_BadgeView
//
//  Created by DEVP-IOS-03 on 16/1/22.
//  Copyright © 2016年 DEVP-IOS-03. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BadgeViewDelegate <NSObject>
@required
-(void)badgeViewDidRemoveFromSuperViewWithIndex:(NSInteger)index;
@optional
-(void)badgeViewWillStartDrag;
-(void)badgeViewDidEndDrag;
@end

@interface BadgeView : UIView
{
    NSInteger _index;
    NSInteger _badgeNumber;
}
/*
 *移除时所在TableView和UICollectionView的index
 */
@property (nonatomic,assign)NSInteger    index;


/*
 *标签数字
 */
@property (nonatomic,assign)NSInteger badgeNumber;





/*
 *代理方法
 */
@property(nonatomic,assign) id <BadgeViewDelegate> delegate;


/**初始化方法*/
- (instancetype)initWithSuperView:(UIView *)superView position:(CGPoint)position1 radius:(CGFloat)radius andValidAttachDistance:(CGFloat)validAttachDistance1;

@end
