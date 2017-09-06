//
//  ViewController.m
//  LocationReminders
//
//  Created by Pavel Parkhomey on 5/1/17.
//  Copyright © 2017 Pavel Parkhomey. All rights reserved.
//

#import "ViewController.h"
#import "AddReminderViewController.h"
#import "LocationController.h"
#import "Reminder.h"

@import Parse;
@import MapKit;
@import ParseUI;

@interface ViewController () <MKMapViewDelegate, LocationControllerDelegate, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UIButton *currentLocationPressed;
@property (nonatomic, assign) BOOL mapShouldFollowUser;
@property (weak, nonatomic) LocationController *locationController;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.locationController = LocationController.shared;
    self.locationController.delegate = self;
    
    [self.locationController requestsPermissions];
    self.mapView.showsUserLocation = YES;
    self.mapView.delegate = self;
    self.currentLocationPressed.layer.cornerRadius = 6;
    self.currentLocationPressed.layer.masksToBounds = true;
    self.mapShouldFollowUser = NO;
    [self currentLocationTapped:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reminderSaveToParse:) name:@"ReminderSavedToParse" object:nil];
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([PFUser currentUser]) {
        [self fetchReminders];
    } else {
        [self displayLogInViewController];
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"ReminderSavedToParse" object:nil];
}

-(void)displayLogInViewController{
    PFLogInViewController *logInViewController = [[PFLogInViewController alloc] init];
    
    logInViewController.delegate = self;
    logInViewController.signUpController.delegate = self;
    
    logInViewController.fields = PFLogInFieldsLogInButton | PFLogInFieldsSignUpButton | PFLogInFieldsUsernameAndPassword | PFLogInFieldsPasswordForgotten;
    
    logInViewController.logInView.logo = [[UIView alloc]init];
    logInViewController.logInView.backgroundColor = [UIColor darkGrayColor];
    
    [[self parentViewController] presentViewController:logInViewController animated:YES completion:nil];
}


-(void)reminderSaveToParse:(id)sender{
    NSLog(@"Do some stuff since the new reminder was saved.");
}

-(void)fetchReminders{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username = %@", [[PFUser currentUser] username]];
    PFQuery *query = [PFQuery queryWithClassName:@"Reminder" predicate: predicate];
    NSLog(@"user: %@", [[PFUser currentUser] username]);

    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error) {
            
            NSLog(@"%@", error.localizedDescription);
            
        }else {
        
            NSLog(@"Query Results %@", objects);
            for (Reminder *reminder in objects) {
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(reminder.location.latitude, reminder.location.longitude);
                MKCircle *circle = [MKCircle circleWithCenterCoordinate:coordinate radius:reminder.radius.doubleValue];
                [self.mapView addOverlay:circle];
            }
        }
    }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    [super prepareForSegue:segue sender:sender];
    
    if ([segue.identifier isEqualToString:@"AddReminderViewController"] && [sender isKindOfClass:[MKAnnotationView class]]) {
        
        MKAnnotationView *annotationView = (MKAnnotationView *)sender;
        
        AddReminderViewController *newReminderViewController = (AddReminderViewController *)segue.destinationViewController;
        
        newReminderViewController.coordinate = annotationView.annotation.coordinate;
        newReminderViewController.annotationTitle = annotationView.annotation.title;
        newReminderViewController.title = annotationView.annotation.title;
        
        __weak typeof(self) bruce = self;
        
        newReminderViewController.completion = ^(MKCircle *circle) {
            
            __strong typeof(bruce) hulk = bruce;
            
            [hulk.mapView removeAnnotation:annotationView.annotation];
           
            [hulk.mapView addOverlay:circle];
        };
    }
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

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    NSLog(@"Accessory Tapped!");
    [self performSegueWithIdentifier:@"AddReminderViewController" sender:view];
}

//Circle where we pinned.
-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay{
   
    MKCircleRenderer *renderer = [[MKCircleRenderer alloc] initWithCircle:overlay];
    
    renderer.strokeColor = [UIColor blueColor];
    renderer.lineWidth = 2.0;
    renderer.fillColor = [UIColor blueColor];
    renderer.alpha = 0.15;
    
    return renderer;
}

-(void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)locationControllerUpdatedLocation:(CLLocation *)location{
    if (self.mapShouldFollowUser) {
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location.coordinate, 500.0, 500.0);
        
        [self.mapView setRegion:region animated:YES];
    }
   
}

//MARK: User actions

//Current location button.

- (IBAction)currentLocationTapped:(id)sender {
    
    self.mapShouldFollowUser = !self.mapShouldFollowUser;
        [self.currentLocationPressed setSelected:self.mapShouldFollowUser];
    
    [self.mapView setRegion: MKCoordinateRegionMake(self.locationController.location.coordinate, MKCoordinateSpanMake(0.01f, 0.01f)) animated:YES];
}

//LongPress for the pin to drop.
- (IBAction)userLongPressed:(UILongPressGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        
        CGPoint touchPoint = [sender locationInView:self.mapView];
        
        CLLocationCoordinate2D coordinate = [self.mapView convertPoint:touchPoint
                                                  toCoordinateFromView:self.mapView]; //Converts point into coordinate.
        
        
        MKPointAnnotation *newPoint = [[MKPointAnnotation alloc]init];
        
        newPoint.coordinate = coordinate;
        newPoint.title = @"Pinned Location";
        
        [self.mapView addAnnotation:newPoint];
    }
}

- (IBAction)signOut:(id)sender {
    [PFUser logOut];
    
    //Clear pins & circle overlays of previous user on sign out.
    [self.mapView removeAnnotations: self.mapView.annotations];
    [self.mapView removeOverlays: self.mapView.overlays];
    [self displayLogInViewController];
}

//Different View for the map.
- (IBAction)setMap:(id)sender {
    
    switch (((UISegmentedControl *)sender).selectedSegmentIndex) {
        case 0:
            _mapView.mapType = MKMapTypeStandard;
            break;
        case 1:
            _mapView.mapType = MKMapTypeSatellite;
            break;
        case 2:
            _mapView.mapType = MKMapTypeHybrid;
            break;
            
        default:
            break;
    }
}
@end
