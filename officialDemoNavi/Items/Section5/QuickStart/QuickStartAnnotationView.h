//
//  QuickStartAnnotationView.h
//  AMapNaviKit
//
//  Created by 刘博 on 16/3/9.
//  Copyright © 2016年 AutoNavi. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>

@interface NaviButton : UIButton

@property (nonatomic, strong) UIImageView *carImageView;
@property (nonatomic, strong) UILabel *naviLabel;

@end

@interface QuickStartAnnotationView : MAPinAnnotationView

- (id)initWithAnnotation:(id <MAAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier;

@end
