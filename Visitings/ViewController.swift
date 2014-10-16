//
//  ViewController.swift
//  Visitings
//
//  Created by Glen Yi on 2014-09-10.
//  Copyright (c) 2014 On The Pursuit. All rights reserved.
//

import UIKit
import CoreLocation

enum VisitCellTag: Int {
    case CoordinatesLabel = 1,
    AccuracyLabel,
    ArrivalLabel,
    DepartureLabel
}

class ViewController: UIViewController, UITableViewDataSource, CLLocationManagerDelegate {
    @IBOutlet var tableView: UITableView!
    
    var locationManager: CLLocationManager = CLLocationManager()
    var visits: NSMutableArray = []
    
    let VisitsFile = "Visits"
    var visitsFilePath: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Load visits
        let documentsPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as String
        self.visitsFilePath = documentsPath.stringByAppendingPathComponent(self.VisitsFile)
        self.visits = NSMutableArray(contentsOfFile: self.visitsFilePath)
        
        // Location manager init
        self.locationManager.delegate = self
        let status = CLLocationManager.authorizationStatus()
        if status==CLAuthorizationStatus.NotDetermined {
            self.locationManager.requestAlwaysAuthorization()
        }
        self.locationManager.startMonitoringVisits()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager!, didVisit visit: CLVisit!) {
        self.visits.insertObject(visit, atIndex: 0)
        self.visits.writeToFile(self.visitsFilePath, atomically: true)
        println(String(format: "Lat %.2f, Lng %.2f, Accuracy: %.2f", visit.coordinate.latitude, visit.coordinate.longitude))
        
        if UIApplication.sharedApplication().applicationState==UIApplicationState.Background {
            let notification = UILocalNotification()
            notification.alertBody = String(format: "Lat %.2f, Lng %.2f, Accuracy: %.2f", visit.coordinate.latitude, visit.coordinate.longitude)
            notification.soundName = UILocalNotificationDefaultSoundName
            UIApplication.sharedApplication().presentLocalNotificationNow(notification)
        }
        
        self.tableView.beginUpdates()
        self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
        self.tableView.endUpdates()
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Error: \(error)")
    }
    
    
    // MARK: UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visits.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("VisitCell", forIndexPath: indexPath) as UITableViewCell
        let visit = self.visits[indexPath.row] as CLVisit
        
        let coordinatesLabel = cell.viewWithTag(VisitCellTag.CoordinatesLabel.toRaw()) as UILabel
        coordinatesLabel.text = String(format: "lat %.2f, lng %.2f", visit.coordinate.latitude, visit.coordinate.longitude)
        
        let accuracyLabel = cell.viewWithTag(VisitCellTag.AccuracyLabel.toRaw()) as UILabel
        accuracyLabel.text = String(format: "%.2fm", visit.horizontalAccuracy)
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.MediumStyle
        formatter.timeStyle = NSDateFormatterStyle.ShortStyle
        
        let arrivalLabel = cell.viewWithTag(VisitCellTag.ArrivalLabel.toRaw()) as UILabel
        if visit.arrivalDate.isEqualToDate(NSDate.distantPast() as NSDate) {
            arrivalLabel.text = "N/A"
        }
        else {
            arrivalLabel.text = formatter.stringFromDate(visit.arrivalDate)
        }
        
        let departureLabel = cell.viewWithTag(VisitCellTag.DepartureLabel.toRaw()) as UILabel
        if visit.departureDate.isEqualToDate(NSDate.distantFuture() as NSDate) {
            departureLabel.text = "N/A"
        }
        else {
            departureLabel.text = formatter.stringFromDate(visit.departureDate)
        }
        
        return cell
    }
}

