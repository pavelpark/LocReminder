//
//  ViewController.m
//  LocationReminders
//
//  Created by Pavel Parkhomey on 5/1/17.
//  Copyright © 2017 Pavel Parkhomey. All rights reserved.
//

#import "ViewController.h"

#import "AddReminderViewController.h"

@import Parse;
@import MapKit;

@interface ViewController () <CLLocationManagerDelegate, MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self requestsPermissions];
    self.mapView.showsUserLocation = YES;
    self.mapView.delegate = self;
}

-(void)requestsPermissions{
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 100; //In meters
    
    self.locationManager.delegate = self;
    
    [self.locationManager requestAlwaysAuthorization];
    
    [self.locationManager startUpdatingLocation];
}
//IKEA Store
- (IBAction)location1Pressed:(id)sender {
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(47.6566674, -122.351096);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 500.0, 500.0);
    
    [self.mapView setRegion:region animated:YES];
}
//GoPro HeadQuaters
- (IBAction)location2Pressed:(id)sender {
    CLLocationCoordinate2D coordinateTwo = CLLocationCoordinate2DMake(37.53451769999999, -122.33128290000002);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinateTwo, 500.0, 500.0);
    
    [self.mapView setRegion:region animated:YES];
}
//Red Bull HeadQuaters
- (IBAction)location3Pressed:(id)sender {
    CLLocationCoordinate2D coordinateThree = CLLocationCoordinate2DMake(34.030154, -118.467076);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinateThree, 500.0, 500.0);
    
    [self.mapView setRegion:region animated:YES];
}

- (IBAction)userLongPressed:(UILongPressGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        
        CGPoint touchPoint = [sender locationInView:self.mapView];
        
        CLLocationCoordinate2D coordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
        
        MKPointAnnotation *newPoint = [[MKPointAnnotation alloc]init];
        
        newPoint.coordinate = coordinate;
        newPoint.title = @"Pinned Location";
        
        [self.mapView addAnnotation:newPoint];
    }
}


-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    CLLocation *location = locations.lastObject;
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location.coordinate, 500.0, 500.0);
    
    [self.mapView setRegion:region animated:YES];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"annotationView"];
    
    annotationView.annotation = annotation;
    
    if (!annotationView) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"annotationView"];
    }
    annotationView.canShowCallout = YES;
    annotationView.animatesDrop = YES;
    
    UIButton *rightCalloutAccessory = [UIButton buttonWithType:UIButtonTypeDetailDisclosure]; //callout button
    
    annotationView.rightCalloutAccessoryView = rightCalloutAccessory;
    
    return annotationView;
    
}
@end
