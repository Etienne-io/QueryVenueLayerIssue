//
//  ViewController.m
//  QueryVenueLayerIssue
//
//  Created by Etienne Mercier on 27/04/2018.
//  Copyright © 2018 Etienne Mercier. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController  {
    MGLStyle* mapboxStyle;
    MGLShapeSource* placeSymbolSource;
    MGLSymbolStyleLayer* placeSymbolLayer;
    
    NSArray<NSDictionary*>* baseFeatures;
    NSString* promotedFeatureTitle;
    MGLPointAnnotation* marker;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _mapView.delegate = self;
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [_mapView addGestureRecognizer:gesture];
}

- (void)handleTap:(UITapGestureRecognizer *)gesture {
    
    if (marker) {
        [_mapView removeAnnotation:marker];
    }
    
    CGPoint spot = [gesture locationInView:_mapView];
    NSArray *features = [_mapView visibleFeaturesAtPoint:spot
                                 inStyleLayersWithIdentifiers:[NSSet setWithObjects:@"place_symbol_layer", nil]];
    
    MGLPointFeature *feature = features.firstObject;
    if (feature) {
        marker = [[MGLPointAnnotation alloc] init];
        marker.coordinate = feature.coordinate;
        [_mapView addAnnotation:marker];
        [self promoteFeature:feature];
    }
    else {
        [self unpromote];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) unpromote {
    promotedFeatureTitle = @"";
    [self displayFeatures];
}

- (void) promoteFeature:(MGLPointFeature*) pointFeature {
    promotedFeatureTitle = [pointFeature attributeForKey:@"title"];
    [self displayFeatures];
}

- (void) mapView:(MGLMapView *)mapView didFinishLoadingStyle:(MGLStyle *)style {
    mapboxStyle = style;
    [self initializeLayer];
    baseFeatures = [self initializeFeatures];
    
    [self displayFeatures];
}

- (void) displayFeatures {
    
    NSMutableArray<NSDictionary*>* features = [[NSMutableArray alloc] init];
    for (NSDictionary* baseFeature in baseFeatures) {
        if ([baseFeature[@"title"] isEqualToString:promotedFeatureTitle]) {
            [features insertObject:baseFeature atIndex:0];
        }
        else {
            [features addObject:baseFeature];
        }
    }
    
    NSData* data = [self generateDataWithFeatures:features];
    if (data) {
        NSError* error;
        MGLShape* placeShapeCollection = [MGLShape shapeWithData:data encoding:NSUTF8StringEncoding error:&error];
        if (placeShapeCollection) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self->placeSymbolSource.shape = placeShapeCollection;
            });
        }
        else {
            NSLog(@"Error while generating place shape %@", error);
        }
    }
}

- (void) initializeLayer {
    placeSymbolSource = [[MGLShapeSource alloc] initWithIdentifier:@"place_symbol_source" shape:nil options: nil];
    [mapboxStyle addSource:placeSymbolSource];
    placeSymbolLayer = [[MGLSymbolStyleLayer alloc] initWithIdentifier:@"place_symbol_layer" source:placeSymbolSource];
    placeSymbolLayer.iconImageName = [NSExpression expressionForKeyPath:@"marker-symbol"];
    placeSymbolLayer.iconScale = [NSExpression expressionForConstantValue:@0.4];
    placeSymbolLayer.text = [NSExpression expressionForKeyPath:@"title"];
    placeSymbolLayer.textAnchor = [NSExpression expressionForConstantValue:@"left"];
    placeSymbolLayer.textHaloColor = [NSExpression expressionForConstantValue:[UIColor whiteColor]];
    placeSymbolLayer.textHaloWidth = [NSExpression expressionForConstantValue:@1.0];
    placeSymbolLayer.textFontSize =[NSExpression expressionForConstantValue:@12];
    placeSymbolLayer.textFontNames = [NSExpression expressionForConstantValue:@[@"Open Sans Regular"]];
    CGVector textOffsetVector = CGVectorMake(1.1, 0.0);
    NSValue* textOffsetValue = [NSValue value:&textOffsetVector withObjCType:@encode(CGVector)];
    placeSymbolLayer.textOffset = [NSExpression expressionForConstantValue:textOffsetValue];
    [mapboxStyle insertLayer:placeSymbolLayer belowLayer:[mapboxStyle layerWithIdentifier:@"com.mapbox.annotations.points"]];
}

- (NSMutableArray<NSDictionary*>*) initializeFeatures {
    NSMutableArray<NSDictionary*>* features = [[NSMutableArray alloc] init];
    for (int i=0; i<30; i++) {
        for (int j=0; j<30; j++) {
            NSMutableDictionary* feature = [[NSMutableDictionary alloc] init];
            feature[@"title"] = [NSString stringWithFormat:@"%d", (j+i*30)];
            feature[@"latitude"] = [NSNumber numberWithDouble:i/10000.0];
            feature[@"longitude"] = [NSNumber numberWithDouble:j/10000.0];
            [features addObject:feature];
        }
    }
    return features;
}

- (NSData*) generateDataWithFeatures:(NSArray<NSDictionary*>*) mFeatures {
    NSMutableDictionary* featuresCollection = [[NSMutableDictionary alloc] init];
    featuresCollection[@"type"] = @"FeatureCollection";
    NSMutableArray* features = [[NSMutableArray alloc] init];
    for (NSDictionary* dic in mFeatures) {
        NSMutableDictionary* feature = [[NSMutableDictionary alloc] init];
        feature[@"type"] = @"Feature";
        NSMutableDictionary* point = [[NSMutableDictionary alloc] init];
        point[@"type"] = @"Point";
        point[@"coordinates"] = @[dic[@"longitude"], dic[@"latitude"]];
        feature[@"geometry"] = point;
        NSMutableDictionary* properties = [[NSMutableDictionary alloc] init];
        properties[@"marker-symbol"] = @"airport-15";
        properties[@"title"] = dic[@"title"];
        //properties[@"id"] = place.identifier;
        feature[@"properties"] = properties;
        feature[@"id"] = dic[@"title"];
        [features addObject:feature];
    }
    
   featuresCollection[@"features"] = features;
   NSError *error;
   NSData *data = [NSJSONSerialization dataWithJSONObject:featuresCollection
                                                      options:NSJSONWritingPrettyPrinted
                                                    error:&error];
    
   if (!data) {
       NSLog(@"Got an error: %@", error);
   } else {
       return data;
   }
   return nil;
}

@end
