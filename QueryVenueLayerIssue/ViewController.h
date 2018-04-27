//
//  ViewController.h
//  QueryVenueLayerIssue
//
//  Created by Etienne Mercier on 27/04/2018.
//  Copyright © 2018 Etienne Mercier. All rights reserved.
//

#import <UIKit/UIKit.h>

@import Mapbox;

@interface ViewController : UIViewController <MGLMapViewDelegate>

@property (weak, nonatomic) IBOutlet MGLMapView *mapView;

@end

