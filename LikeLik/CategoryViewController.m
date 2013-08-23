//
//  CategoryViewController.m
//  TabBar
//
//  Created by Vladimir Malov on 30.04.13.
//  Copyright (c) 2013 LikeLik. All rights reserved.
//

#import "CategoryViewController.h"
#import "AppDelegate.h"
#import "AroundMeViewController.h"
#import "CityInfoTableViewController.h"
#import "SearchViewController.h"
#import "AppDelegate.h"
#import "LocalizationSystem.h"
#import "FavViewController.h"
#import "AboutTableViewController.h"
#import "PlacesByCategoryViewController.h"
#import "VisualTourViewController.h"
#import "TransportationTableViewController.h"
#import "PracticalInfoViewController.h"
#import <MapBox/MapBox.h>
#import "PlaceViewController.h"
#import "MLPAccessoryBadge.h"
static NSString *PlaceName = @"";
static NSString *PlaceCategory = @"";
static NSDictionary *Place;

#define EF_TAG 66483
#define FADE_TAG 66484


@interface CategoryViewController ()

@end

@implementation CategoryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)activateAroundMe{
    for (UIView *subViews in self.view.subviews)
        if (subViews.tag == EF_TAG ) {
            [subViews removeFromSuperview];
        }
    for (UIView *subViews in self.navigationController.view.subviews){
        if(subViews.tag == FADE_TAG)
             [subViews removeFromSuperview];
    }
    //self.frame1.backgroundColor = [UIColor colorWithPatternImage:[self imageWithImage:[UIImage imageNamed:@"1.png"] scaledToSize:CGSizeMake(93, 93)]];
}

-(void)reloadCatalogue{
    NSURL *url;
    if ([self.CityName.text isEqualToString:@"Moscow"] || [self.CityName.text isEqualToString:@"Москва"] || [self.CityName.text isEqualToString:@"Moskau"]){
        url = [NSURL fileURLWithPath:[[NSString alloc] initWithFormat:@"%@/Moscow/2.mbtiles",[ExternalFunctions docDir]]];
    }
    if ([self.CityName.text isEqualToString:@"Vienna"] || [self.CityName.text isEqualToString:@"Вена"] || [self.CityName.text isEqualToString:@"Wien"]){
        url = [NSURL fileURLWithPath:[[NSString alloc] initWithFormat:@"%@/Vienna/vienna.mbtiles",[ExternalFunctions docDir]]];
    }
    RMMBTilesSource *offlineSource = [[RMMBTilesSource alloc] initWithTileSetURL:url];
    self.MapPlace.showsUserLocation = YES;
    self.MapPlace = [[RMMapView alloc] initWithFrame:self.view.bounds andTilesource:offlineSource];
    self.MapPlace.hidden = NO;
    self.MapPlace.hideAttribution = YES;
    self.MapPlace.delegate = self;
    
    if ([AppDelegate isiPhone5])
        self.MapPlace.frame = CGRectMake(0.0, 0.0, 320.0, 504.0);
    else
        self.MapPlace.frame = CGRectMake(0.0, 0.0, 320.0, 450.0);
    
    
    self.MapPlace.minZoom = 10;
    self.MapPlace.zoom = 13;
    self.MapPlace.maxZoom = 17;
    
    [self.MapPlace setAdjustTilesForRetinaDisplay:YES];
    self.MapPlace.showsUserLocation = YES;
    [self.placeViewMap setHidden:YES];
    [self.placeViewMap addSubview:self.MapPlace];

    UIView *fade = [[UIView alloc] initWithFrame:self.navigationController.navigationBar.frame];
    fade.tag = FADE_TAG;
    fade.backgroundColor = [UIColor clearColor];
    [self.navigationController.view addSubview:fade];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // post an NSNotification that loading has started
        AroundArray = [ExternalFunctions getPlacesAroundMyLocationInCity:self.CityName.text];
        RMAnnotation *marker1;
        for (int i=0; i<[AroundArray count]; i++) {
            CLLocation *tmp = [[AroundArray objectAtIndex:i] objectForKey:@"Location"];
            marker1 = [[RMAnnotation alloc]initWithMapView:self.MapPlace coordinate:tmp.coordinate andTitle:@"Pin"];
            marker1.annotationType = @"marker";
            marker1.title = [[AroundArray objectAtIndex:i] objectForKey:@"Name"];
            marker1.subtitle = AMLocalizedString([[AroundArray objectAtIndex:i] objectForKey:@"Category"], nil);
            marker1.userInfo = [AroundArray objectAtIndex:i];
            [self.MapPlace addAnnotation:marker1];
            //NSLog(@"! %@ %f %f",marker1.title,marker1.coordinate.latitude,marker1.coordinate.longitude);
        }
        //    NSLog(@"%@",self.MapPlace.annotations);]
        dispatch_async(dispatch_get_main_queue(), ^ {
            NSLog(@"Back on main thread");
            [self activateAroundMe];
            //            [self.Table reloadData];
        });
        // post an NSNotification that loading is finished
    });
    UIView *coolEf = [[UIView alloc] initWithFrame:self.view.frame];
    coolEf.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    coolEf.tag = EF_TAG;
    [self.view addSubview:coolEf];
    [UIView animateWithDuration:0.2 animations:^{
        coolEf.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        UIView *spin = [[UIView alloc] initWithFrame:CGRectMake(self.view.center.x - 22, self.view.center.y - 90, 45, 45)];
        //knuckle_1@2x.png
        spin.backgroundColor = [UIColor colorWithPatternImage:[self imageWithImage:[UIImage imageNamed:@"kul_90.png"] scaledToSize:CGSizeMake(45, 45)]];
        //spin.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        CALayer *layer = spin.layer;
        layer.cornerRadius = 8;
        spin.clipsToBounds = YES;
        CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
        animation.fromValue = [NSNumber numberWithFloat:0.0f];
        animation.toValue = [NSNumber numberWithFloat: 2*M_PI];
        animation.duration = 3.0f;
        animation.repeatCount = HUGE_VAL;
        [spin.layer addAnimation:animation forKey:@"MyAnimation"];
        [coolEf addSubview:spin];
    }];

}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _locationManager = [[CLLocationManager alloc] init];
    [_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [_locationManager startUpdatingLocation];
    CLLocation *Me = [_locationManager location];
    
    self.categoryView.backgroundColor = [UIColor clearColor];
    [self.categoryView setScrollEnabled:YES];
    self.categoryView.showsHorizontalScrollIndicator = NO;
    self.categoryView.showsVerticalScrollIndicator = NO;

    [self.categoryView setContentSize:CGSizeMake(320, 480)];
    [self.categoryView flashScrollIndicators];
    self.categoryView.delegate = self;
    UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    background.backgroundColor = [UIColor whiteColor];//[UIColor colorWithPatternImage:[self imageWithImage:[UIImage imageNamed:@"Overlay_Long@2x.png"] scaledToSize:CGSizeMake(320, 568)]];//[UIColor //[UIColor whiteColor];//[InterfaceFunctions BackgroundColor];
    [self.categoryView addSubview:background];
        
//    self.Table.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor whiteColor];//[UIColor colorWithPatternImage:[self imageWithImage:[UIImage imageNamed:@"Overlay_Long@2x.png"] scaledToSize:CGSizeMake(320, 568)]];//[UIColor whiteColor];//[InterfaceFunctions BackgroundColor];
    //Overlay_Long@2x.png
    self.navigationItem.titleView = [InterfaceFunctions NavLabelwithTitle:[[NSString alloc] initWithFormat:@"Go&Use %@",self.Label] AndColor:[InterfaceFunctions corporateIdentity]];

    self.CityName.text = self.Label;
    self.CityName.font = [AppDelegate OpenSansSemiBold:60];
    self.CityName.textColor = [UIColor whiteColor];
    self.CityImage.image =  [UIImage imageWithContentsOfFile:[ExternalFunctions larkePictureOfCity:self.Label]];
    NSLog(@"%@",[ExternalFunctions larkePictureOfCity:self.Label]);
    self.CellArray = @[@"Around Me", @"Restaurants",@"Night life",@"Shopping",@"Culture",@"Leisure", @"Beauty", @"Hotels",@"Favorites", @"Visual Tour", @"Metro",@"Practical Info"];
    
    self.SegueArray = @[@"AroundmeSegue",@"CategorySegue",@"CategorySegue",@"CategorySegue",@"CategorySegue",@"CategorySegue",@"CategorySegue",@"CategorySegue",@"FavoritesSegue",@"VisualtourSegue",@"TransportationSegue",@"PracticalinfoSegue"];

    self.navigationItem.backBarButtonItem = [InterfaceFunctions back_button];
//    self.Table.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UIButton *btn = [InterfaceFunctions map_button:1];
    [btn addTarget:self action:@selector(ShowMap:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    

    NSURL *url;
    if ([self.CityName.text isEqualToString:@"Moscow"] || [self.CityName.text isEqualToString:@"Москва"] || [self.CityName.text isEqualToString:@"Moskau"]){
        url = [NSURL fileURLWithPath:[[NSString alloc] initWithFormat:@"%@/Moscow/2.mbtiles",[ExternalFunctions docDir]]];
    }
    if ([self.CityName.text isEqualToString:@"Vienna"] || [self.CityName.text isEqualToString:@"Вена"] || [self.CityName.text isEqualToString:@"Wien"]){
        url = [NSURL fileURLWithPath:[[NSString alloc] initWithFormat:@"%@/Vienna/vienna.mbtiles",[ExternalFunctions docDir]]];
    }
    
    
    RMMBTilesSource *offlineSource = [[RMMBTilesSource alloc] initWithTileSetURL:url];
    self.MapPlace.showsUserLocation = YES;
    self.MapPlace = [[RMMapView alloc] initWithFrame:self.view.bounds andTilesource:offlineSource];
    self.MapPlace.hidden = NO;
    self.MapPlace.hideAttribution = YES;
    self.MapPlace.delegate = self;
    
    if ([AppDelegate isiPhone5])
        self.MapPlace.frame = CGRectMake(0.0, 0.0, 320.0, 504.0);
    else
        self.MapPlace.frame = CGRectMake(0.0, 0.0, 320.0, 450.0);
    
    
    self.MapPlace.minZoom = 10;
    self.MapPlace.zoom = 13;
    self.MapPlace.maxZoom = 17;
    
    [self.MapPlace setAdjustTilesForRetinaDisplay:YES];
    self.MapPlace.showsUserLocation = YES;
    [self.placeViewMap setHidden:YES];
    
    if([ExternalFunctions isDownloaded:self.CityName.text]){

    [self.placeViewMap addSubview:self.MapPlace];
    }
    if([ExternalFunctions isDownloaded:self.CityName.text]){
    UIView *fade = [[UIView alloc] initWithFrame:self.navigationController.navigationBar.frame];
    fade.tag = FADE_TAG;
    fade.backgroundColor = [UIColor clearColor];
    [self.navigationController.view addSubview:fade];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // post an NSNotification that loading has started
        AroundArray = [ExternalFunctions getPlacesAroundMyLocationInCity:self.CityName.text];
        RMAnnotation *marker1;
        for (int i=0; i<[AroundArray count]; i++) {
            CLLocation *tmp = [[AroundArray objectAtIndex:i] objectForKey:@"Location"];
            marker1 = [[RMAnnotation alloc]initWithMapView:self.MapPlace coordinate:tmp.coordinate andTitle:@"Pin"];
            marker1.annotationType = @"marker";
            marker1.title = [[AroundArray objectAtIndex:i] objectForKey:@"Name"];
            marker1.subtitle = AMLocalizedString([[AroundArray objectAtIndex:i] objectForKey:@"Category"], nil);
            marker1.userInfo = [AroundArray objectAtIndex:i];
            [self.MapPlace addAnnotation:marker1];
            //NSLog(@"! %@ %f %f",marker1.title,marker1.coordinate.latitude,marker1.coordinate.longitude);
        }
        //    NSLog(@"%@",self.MapPlace.annotations);]
        dispatch_async(dispatch_get_main_queue(), ^ {
            NSLog(@"Back on main thread");
            [self activateAroundMe];
//            [self.Table reloadData];
        });
                // post an NSNotification that loading is finished
    });
    }
    
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    NSString *city = [[ExternalFunctions cityCatalogueForCity:self.CityName.text] objectForKey:@"city_EN"];
    if ([ExternalFunctions isDownloaded:city]) {
    
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"location"];
        
        CLLocation *oldLocation = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        NSLog(@"Изменение расстояния: %f",[Me distanceFromLocation:oldLocation]);
        
        NSArray *catalogues = [[NSUserDefaults standardUserDefaults] objectForKey:@"Catalogues"];
        
        if ([Me distanceFromLocation:oldLocation] > 10
            || [[NSUserDefaults standardUserDefaults] objectForKey:[[NSString alloc] initWithFormat:@"around %@",city]] == NULL) {
            NSLog(@"in if");

            [_locationManager stopUpdatingLocation];
            NSData *newLocation = [NSKeyedArchiver archivedDataWithRootObject:Me];
            [[NSUserDefaults standardUserDefaults] setObject:newLocation forKey:@"location"];
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(queue, ^ {
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:[ExternalFunctions getPlacesAroundMyLocationInCity:self.CityName.text]];
                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:arr];
                [defaults setObject:data forKey:[[NSString alloc] initWithFormat:@"around %@",city]];
                
                NSLog(@"Finished work in background");
                
                
                dispatch_async(dispatch_get_main_queue(), ^ {
                    NSLog(@"Back on main thread");
                });
            });
        }
        else if ([[NSUserDefaults standardUserDefaults] objectForKey:@"langChanged"] == [NSNumber numberWithInt:1]) {
            [_locationManager stopUpdatingLocation];
            NSData *newLocation = [NSKeyedArchiver archivedDataWithRootObject:Me];
            [[NSUserDefaults standardUserDefaults] setObject:newLocation forKey:@"location"];
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(queue, ^ {
                
                for (int i = 0; i < [catalogues count]; i++) {
                    NSString *cityName = [[catalogues objectAtIndex:i] objectForKey:@"city_EN"];
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:[ExternalFunctions getPlacesAroundMyLocationInCity:cityName]];
                    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:arr];
                    [defaults setObject:data forKey:[[NSString alloc] initWithFormat:@"around %@",cityName]];
                    
                    NSLog(@"Finished work in background");
                }
                [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:0] forKey:@"langChanged"];
                dispatch_async(dispatch_get_main_queue(), ^ {
                    NSLog(@"Back on main thread");
                });
            });
        }
    }
    
    CGFloat frameSize = 93.0;
    CGFloat xOrigin = 10;
    CGFloat yOrigin = 20;
    CGFloat yOffset = 10;
    
    if(self.view.bounds.size.height == 460.0)
        yOrigin = 0;
    
    self.frame1 = [[UIView alloc] initWithFrame:CGRectMake(xOrigin, yOrigin + yOffset, frameSize, frameSize)];
    self.frame1.backgroundColor = [UIColor colorWithPatternImage:[self imageWithImage:[UIImage imageNamed:@"1.png"] scaledToSize:CGSizeMake(frameSize, frameSize)]];
    self.frame1.tag = 0;
    [self.categoryView addSubview:self.frame1];
    
//    UIView *fade = [[UIView alloc] initWithFrame:frame1.frame];
//    fade.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
//    fade.tag = FADE_TAG;
//    CALayer *layer1 = fade.layer;
//    layer1.cornerRadius = 10;
//    frame1.clipsToBounds = YES;
//    [self.categoryView addSubview:fade];
    
    UIView *frame2 = [[UIView alloc] initWithFrame:CGRectMake(frameSize +2*xOrigin, yOrigin + yOffset, frameSize, frameSize)];
    frame2.backgroundColor = [UIColor colorWithPatternImage:[self imageWithImage:[UIImage imageNamed:@"2.png"] scaledToSize:CGSizeMake(frameSize, frameSize)]];
    frame2.tag = 1;
    [self.categoryView addSubview:frame2];
    
    UIView *frame3 = [[UIView alloc] initWithFrame:CGRectMake(2*frameSize + 3*xOrigin, yOrigin + yOffset, frameSize, frameSize)];
    frame3.backgroundColor = [UIColor colorWithPatternImage:[self imageWithImage:[UIImage imageNamed:@"3.png"] scaledToSize:CGSizeMake(frameSize, frameSize)]];
    frame3.tag = 2;
    [self.categoryView addSubview:frame3];
    
    UIView *frame4 = [[UIView alloc] initWithFrame:CGRectMake(xOrigin, frameSize + yOrigin + 2*yOffset, frameSize, frameSize)];
    frame4.backgroundColor = [UIColor colorWithPatternImage:[self imageWithImage:[UIImage imageNamed:@"4.png"] scaledToSize:CGSizeMake(frameSize, frameSize)]];
    frame4.tag = 3;
    [self.categoryView addSubview:frame4];
    
    UIView *frame5 = [[UIView alloc] initWithFrame:CGRectMake(frameSize +2*xOrigin, frameSize + yOrigin + 2*yOffset, frameSize, frameSize)];
    frame5.backgroundColor = [UIColor colorWithPatternImage:[self imageWithImage:[UIImage imageNamed:@"5.png"] scaledToSize:CGSizeMake(frameSize, frameSize)]];
    frame5.tag = 4;
    [self.categoryView addSubview:frame5];
    
    UIView *frame6 = [[UIView alloc] initWithFrame:CGRectMake(2*frameSize + 3*xOrigin, frameSize + yOrigin + 2*yOffset, frameSize, frameSize)];
    frame6.backgroundColor = [UIColor colorWithPatternImage:[self imageWithImage:[UIImage imageNamed:@"6.png"] scaledToSize:CGSizeMake(frameSize, frameSize)]];
    frame6.tag = 5;
    [self.categoryView addSubview:frame6];
    
    UIView *frame7 = [[UIView alloc] initWithFrame:CGRectMake(xOrigin, 2*frameSize + yOrigin + 3*yOffset, frameSize, frameSize)];
    frame7.backgroundColor = [UIColor colorWithPatternImage:[self imageWithImage:[UIImage imageNamed:@"7.png"] scaledToSize:CGSizeMake(frameSize, frameSize)]];
    frame7.tag = 6;
    [self.categoryView addSubview:frame7];
    
    UIView *frame8 = [[UIView alloc] initWithFrame:CGRectMake(frameSize +2*xOrigin, 2*frameSize + yOrigin + 3*yOffset, frameSize, frameSize)];
    frame8.backgroundColor = [UIColor colorWithPatternImage:[self imageWithImage:[UIImage imageNamed:@"8.png"] scaledToSize:CGSizeMake(frameSize, frameSize)]];
    frame8.tag = 7;
    [self.categoryView addSubview:frame8];
    
    UIView *frame9 = [[UIView alloc] initWithFrame:CGRectMake(2*frameSize + 3*xOrigin, 2*frameSize + yOrigin + 3*yOffset, frameSize, frameSize)];
    frame9.backgroundColor = [UIColor colorWithPatternImage:[self imageWithImage:[UIImage imageNamed:@"9.png"] scaledToSize:CGSizeMake(frameSize, frameSize)]];
    frame9.tag = 8;
    [self.categoryView addSubview:frame9];
    
    UIView *frame10 = [[UIView alloc] initWithFrame:CGRectMake(xOrigin, 3*frameSize + yOrigin + 4*yOffset, frameSize, frameSize)];
    frame10.backgroundColor = [UIColor colorWithPatternImage:[self imageWithImage:[UIImage imageNamed:@"10.png"] scaledToSize:CGSizeMake(frameSize, frameSize)]];
    frame10.tag = 9;
    [self.categoryView addSubview:frame10];
    
    UIView *frame11 = [[UIView alloc] initWithFrame:CGRectMake(frameSize +2*xOrigin, 3*frameSize + yOrigin + 4*yOffset, frameSize, frameSize)];
    frame11.backgroundColor = [UIColor colorWithPatternImage:[self imageWithImage:[UIImage imageNamed:@"11.png"] scaledToSize:CGSizeMake(frameSize, frameSize)]];
    frame11.tag = 10;
    [self.categoryView addSubview:frame11];
    
    UIView *frame12 = [[UIView alloc] initWithFrame:CGRectMake(2*frameSize + 3*xOrigin, 3*frameSize + yOrigin + 4*yOffset, frameSize, frameSize)];
    frame12.backgroundColor = [UIColor colorWithPatternImage:[self imageWithImage:[UIImage imageNamed:@"12.png"] scaledToSize:CGSizeMake(frameSize, frameSize)]];
    frame12.tag = 11;
    [self.categoryView addSubview:frame12];

    if(!self.frameArray)
        self.frameArray = [[NSArray alloc] init];
    
    self.frameArray = @[self.frame1, frame2, frame3, frame4, frame5, frame6, frame7, frame8, frame9, frame10, frame11, frame12];
    for (UIView *frame in self.frameArray){
        UILabel *text = [[UILabel alloc]initWithFrame:CGRectMake(1, 64, 91, 28)];
        text.text = AMLocalizedString([self.CellArray objectAtIndex:frame.tag], nil);
        text.backgroundColor = [UIColor clearColor];
        text.textColor = [UIColor whiteColor];
        [text setFont:[AppDelegate OpenSansSemiBold:22]];
        text.textAlignment = NSTextAlignmentCenter;
        [frame addSubview:text];
        CALayer *layer = frame.layer;
        layer.cornerRadius = 5;
        frame.clipsToBounds = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(customPush:)];
        [frame addGestureRecognizer:tap];
        [frame setUserInteractionEnabled:YES];

    }
    if([ExternalFunctions isDownloaded:self.CityName.text]){

    UIView *coolEf = [[UIView alloc] initWithFrame:self.view.frame];
    coolEf.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    coolEf.tag = EF_TAG;
    [self.view addSubview:coolEf];
    [UIView animateWithDuration:0.2 animations:^{
        coolEf.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        UIView *spin = [[UIView alloc] initWithFrame:CGRectMake(self.view.center.x - 22, self.view.center.y - 90, 45, 45)];
        //knuckle_1@2x.png
        spin.backgroundColor = [UIColor colorWithPatternImage:[self imageWithImage:[UIImage imageNamed:@"kul_90.png"] scaledToSize:CGSizeMake(45, 45)]];
        //spin.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        CALayer *layer = spin.layer;
        layer.cornerRadius = 8;
        spin.clipsToBounds = YES;
        CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
        animation.fromValue = [NSNumber numberWithFloat:0.0f];
        animation.toValue = [NSNumber numberWithFloat: 2*M_PI];
        animation.duration = 3.0f;
        animation.repeatCount = HUGE_VAL;
        [spin.layer addAnimation:animation forKey:@"MyAnimation"];
        [coolEf addSubview:spin];
    }];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(reloadCatalogue) name:@"reloadAllCatalogues" object:nil];

}

-(RMMapLayer *)mapView:(RMMapView *)mapView layerForAnnotation:(RMAnnotation *)annotation
{
    
    if ([annotation.annotationType isEqualToString:@"marker"]) {
        RMMarker *marker = [[RMMarker alloc] initWithMapBoxMarkerImage:[annotation.userInfo objectForKey:@"marker-symbol"]
                                                          tintColorHex:[annotation.userInfo objectForKey:@"marker-color"]
                                                            sizeString:[annotation.userInfo objectForKey:@"marker-size"]];
        
        [marker replaceUIImage:[InterfaceFunctions MapPin:annotation.subtitle].image];
        marker.canShowCallout = YES;
        marker.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        return marker;
        
    }
    return nil;
}

-(void)tapOnAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map{
    //  NSLog(@"123");
    //[map selectAll:map];
    //    [map selectAnnotation:annotation animated:YES];
}


-(void)tapOnLabelForAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map{
    // NSLog(@"123");
}
- (void)tapOnCalloutAccessoryControl:(UIControl *)control forAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map
{
    // NSLog(@"tap");
    PlaceName = annotation.title;
    PlaceCategory = [annotation.userInfo objectForKey:@"Category"];
    Place = annotation.userInfo;
    [self performSegueWithIdentifier:@"MapSegue" sender:self];
}


-(IBAction)ShowMap:(id)sender{
    self.placeViewMap.hidden = !self.placeViewMap.hidden;
    if (self.placeViewMap.hidden){
        UIButton *btn = [InterfaceFunctions map_button:1];
        [btn addTarget:self action:@selector(ShowMap:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    }
    else{
        UIButton *btn = [InterfaceFunctions map_button:0];
        [btn addTarget:self action:@selector(ShowMap:) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    }
}

-(void)search:(id)sender{
    [self performSegueWithIdentifier:@"SearchSegue" sender:self];
}

-(void)viewDidAppear:(BOOL)animated{
    
    if ([[[CLLocation alloc] initWithLatitude:self.MapPlace.userLocation.coordinate.latitude longitude:self.MapPlace.userLocation.coordinate.longitude] distanceFromLocation:[ExternalFunctions getCenterCoordinatesOfCity:self.CityName.text]] > 50000.0) {
        self.MapPlace.centerCoordinate = [ExternalFunctions getCenterCoordinatesOfCity:self.CityName.text].coordinate;
        NSLog(@"Взяли центр города");
//        [self.locationButton addTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
//        self.locationButton.enabled = NO;
    }
    else{
        self.MapPlace.centerCoordinate = self.MapPlace.userLocation.coordinate;
     //   self.locationButton.enabled = YES;
        NSLog(@"Взяли локацию пользователя");
    }
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self.Table deselectRowAtIndexPath:[self.Table indexPathForSelectedRow] animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}




#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return [self.CellArray count];
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = nil;
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//    }
//    
//    cell.backgroundView = [InterfaceFunctions CellBG];
//    cell.selectedBackgroundView = [InterfaceFunctions SelectedCellBG];
//    cell.textLabel.backgroundColor = [UIColor clearColor];
//    
//    
//    NSString *text = AMLocalizedString([self.CellArray objectAtIndex:[indexPath row]], nil);
//    if ([indexPath row]<8 && [indexPath row]!=0) {
//        [cell addSubview:[InterfaceFunctions mainTextLabelwithText:text AndColor:[InterfaceFunctions mainTextColor:[indexPath row]+1]]];
//        [cell addSubview:[InterfaceFunctions actbwithColor:[indexPath row]]];//actbwithColor:[indexPath row]+1]];
//    }
//    else{
//        [cell addSubview:[InterfaceFunctions mainTextLabelwithText:text AndColor:[InterfaceFunctions corporateIdentity]]];
//        if ([indexPath row] == 11) {
//            MLPAccessoryBadge *accessoryBadge;
//
//            accessoryBadge = [MLPAccessoryBadge new];
//            [cell setAccessoryView:accessoryBadge];
//            [accessoryBadge setText:AMLocalizedString(@"Soon", nil)];
//            [accessoryBadge setBackgroundColor:[InterfaceFunctions corporateIdentity]];
//            [cell addSubview:accessoryBadge];
//        }
//        else
//            [cell addSubview:[InterfaceFunctions corporateIdentity_actb]];
//    }
//    if(!PLACES_LOADED && [indexPath row] == 0){
//        UIView *fade = [[UIView alloc] initWithFrame:cell.frame];
//        fade.backgroundColor = [UIColor colorWithHue:0 saturation:0 brightness:0 alpha:0.3];
//        [cell addSubview:fade];
//        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
//    }
//        return cell;
//}
//#pragma mark - Table view delegate
//
//- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    if ([indexPath row] == 11) {
//        return nil;
//    }
//    return indexPath;
//}
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//  //  if ([indexPath row] !=11)
//    [TestFlight passCheckpoint:[self.SegueArray objectAtIndex:[indexPath row]]];
//    if((indexPath.row == 0) && !PLACES_LOADED)
//        return;
//    [self performSegueWithIdentifier:[self.SegueArray objectAtIndex:[indexPath row]] sender:self];
//    
//}
//
//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return 44.0;
//}
//
-(void)clearView:(UIView *)obj{
    for (UIView *subView in self.view.subviews){
        if(subView.tag == EF_TAG)
            [subView removeFromSuperview];
    }
}
-(void)customPush:(UIView *)sender{
    NSInteger number = [(UIGestureRecognizer *)sender view].tag;
//    UIView *coolEf = [[UIView alloc] initWithFrame:[(UIGestureRecognizer *)sender view].frame];
//    if(number > 0 && number < 8)
//        coolEf.backgroundColor = [InterfaceFunctions mainTextColor:(number + 1)];
//    else
//        coolEf.backgroundColor = [InterfaceFunctions corporateIdentity];
//    coolEf.tag = EF_TAG;
//    [self.view addSubview:coolEf];
//    [UIView animateWithDuration:0.1 animations:^{
//        coolEf.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
//        UIView *spin = [[UIView alloc] initWithFrame:CGRectMake(self.view.center.x - 37, self.view.center.y - 37, 74, 74)];
//        //knuckle_1@2x.png
//        spin.backgroundColor = [UIColor colorWithPatternImage:[self imageWithImage:[UIImage imageNamed:@"74_74 Fist_for_HUD@2x.png"] scaledToSize:CGSizeMake(74, 74)]];
//        //spin.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
//        CALayer *layer = spin.layer;
//        layer.cornerRadius = 8;
//        spin.clipsToBounds = YES;
//        CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.y"];
//        animation.fromValue = [NSNumber numberWithFloat:0.0f];
//        animation.toValue = [NSNumber numberWithFloat: 2*M_PI];
//        animation.duration = 3.0f;
//        animation.repeatCount = HUGE_VAL;
//        [spin.layer addAnimation:animation forKey:@"MyAnimation"];
//        [coolEf addSubview:spin];
//
       self.navigationItem.leftBarButtonItem.enabled = NO;
//} completion:^(BOOL finished) {
        [TestFlight passCheckpoint:[self.SegueArray objectAtIndex:number]];
        [self performSegueWithIdentifier:[self.SegueArray objectAtIndex:number] sender:sender];
//  NSTimeInterval delay = 0.4; //in seconds
//    [self performSelector:@selector(clearView:) withObject:nil afterDelay:delay];
//  }];
    
}

-(NSArray *)placesInCategory:(NSString *)category{
    NSMutableArray *arrayOfPlacesInCategory = [[NSMutableArray alloc] init];
    for (int i = 0; i < AroundArray.count; ++i) {
        if([[[AroundArray objectAtIndex:i] objectForKey:@"Category"] isEqualToString:category]){
            [arrayOfPlacesInCategory addObject:(AroundArray)[i]];
        }
    }
    return [NSArray arrayWithArray:arrayOfPlacesInCategory];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UIView *)sender{
    
    //NSIndexPath *indexPath = [self.Table indexPathForSelectedRow];
    NSInteger row =[(UIGestureRecognizer *)sender view].tag;//[indexPath row];
    NSLog(@"In segue! Number is: %d", row);
    if ([[segue identifier] isEqualToString:@"AroundmeSegue"]) {
        AroundMeViewController *destination = [segue destinationViewController];
        destination.CityNameText = self.Label;
        destination.Image = [ExternalFunctions larkePictureOfCity:self.Label];
        destination.readyArray = AroundArray;
    }
    if ([[segue identifier] isEqualToString:@"CategorySegue"]) {
        PlacesByCategoryViewController *destination =[segue destinationViewController];
        destination.CityName = self.Label;
        destination.Category = [self.CellArray objectAtIndex:row];
        destination.Image = [ExternalFunctions larkePictureOfCity:self.Label];
        destination.categoryArray = [self placesInCategory:destination.Category];
    }

    if ([[segue identifier] isEqualToString:@"FavoritesSegue"]) {
        FavViewController *destination = [segue destinationViewController];
        [segue destinationViewController];
        destination.CityName = self.Label;
    }
    
    if ([[segue identifier] isEqualToString:@"VisualtourSegue"]) {
        VisualTourViewController *destination =
        [segue destinationViewController];
        destination.CityName = self.Label;
    }
    
    if ([[segue identifier] isEqualToString:@"TransportationSegue"]) {
        TransportationTableViewController *destination = [segue destinationViewController];
        [segue destinationViewController];
        destination.CityName = self.Label;
    }
    
    if ([[segue identifier] isEqualToString:@"PracticalinfoSegue"]) {
        PracticalInfoViewController  *destination = [segue destinationViewController];
        [segue destinationViewController];
        destination.CityName = self.Label;
    }
    
    if ([[segue identifier] isEqualToString:@"MapSegue"]) {
        PlaceViewController *PlaceView = [segue destinationViewController];
        PlaceView.PlaceName = PlaceName;
        PlaceView.PlaceCategory = PlaceCategory;
        PlaceView.PlaceCityName = [Place objectForKey:@"City"];
        PlaceView.PlaceAddress = [Place objectForKey:@"Address"];
        PlaceView.PlaceAbout = [Place objectForKey:@"About"];
        PlaceView.PlaceTelephone = [Place objectForKey:@"Telephone"];
        PlaceView.PlaceWeb = [Place objectForKey:@"Web"];
        PlaceView.PlaceLocation = [Place objectForKey:@"Location"];
        PlaceView.Color = [InterfaceFunctions colorTextCategory:PlaceCategory];
        PlaceView.Photos = [Place objectForKey:@"Photo"];
    }
    
    if ([[segue identifier] isEqualToString:@"SearchSegue"]){
        SearchViewController *destinaton  = [segue destinationViewController];
        destinaton.CityName = self.Label;
    }
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)updateOffsets {
    
    CGFloat yOffset   = self.categoryView.contentOffset.y;
    
   if (yOffset < 0) {
       self.CityImage.frame = CGRectMake(0, -280.0, 320.0, 568.0 - yOffset);
       
        self.CityName.frame = CGRectMake(self.CityName.frame.origin.x,4.0-(yOffset),self.CityName.frame.size.width,self.CityName.frame.size.height);
        
        self.GradientUnderLabel.frame = CGRectMake(self.GradientUnderLabel.frame.origin.x,-yOffset,self.GradientUnderLabel.frame.size.width,self.GradientUnderLabel.frame.size.height);
        //self.categoryView.frame = CGRectMake(self.categoryView.frame.origin.x,self.categoryView.frame.origin.y-yOffset,self.categoryView.frame.size.width,self.categoryView.frame.size.height);
    }
    else {
        self.CityImage.frame = CGRectMake(0, -280.0, 320, self.CityImage.frame.size.height);
        self.CityName.frame = CGRectMake(self.CityName.frame.origin.x,4.0,self.CityName.frame.size.width,self.CityName.frame.size.height);
        self.GradientUnderLabel.frame = CGRectMake(self.GradientUnderLabel.frame.origin.x,0.0,self.GradientUnderLabel.frame.size.width,self.GradientUnderLabel.frame.size.height);
        
    }
    self.CityImage.contentMode = UIViewContentModeScaleAspectFit;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self updateOffsets];
}

@end
