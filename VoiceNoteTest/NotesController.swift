//
//  ViewController.swift
//  VoiceNoteTest
//
//  Created by LiXT on 6/11/16.
//  Copyright © 2016 LiXT. All rights reserved.
//

import UIKit
import EventKit
import CoreData

class NotesController: UITableViewController {
    
    let eventStore: EKEventStore = EKEventStore();
    var defaultCalendar: EKCalendar?
    var eventList = [EKEvent]()
    
    var editedNotes = [NSManagedObject]()
    var unEditedNotes = [NSManagedObject]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.checkEventStoreAccess()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetail"{
            
        }
    }

    
    func checkEventStoreAccess() {
        let status: EKAuthorizationStatus = EKEventStore.authorizationStatusForEntityType(EKEntityType.Event)
        print(status.rawValue)
        switch status {
        case EKAuthorizationStatus.Authorized:
            self.grantEventStoreAccess()
        case EKAuthorizationStatus.Denied:
            break
        case EKAuthorizationStatus.NotDetermined:
            self.requestEventStoreAccess()
        case EKAuthorizationStatus.Restricted:
            break
        }
       
    }
    
    func grantEventStoreAccess() {
        self.defaultCalendar = self.eventStore.defaultCalendarForNewEvents
        self.eventList = self.updateEvents()
        self.updateNotes()
        print("Access granted!")
        self.tableView.reloadData()
    }
    
    func requestEventStoreAccess() {
        self.eventStore.requestAccessToEntityType(EKEntityType.Event) { (granted, error) in
            if (granted) {
                weak var weakSelf = self;
                dispatch_async(dispatch_get_main_queue(), {
                    weakSelf!.grantEventStoreAccess()
                    })
            }
        }
    }
    
    func updateNotes() {
        self.unEditedNotes = PersistenceOperations.fetch(false)
        self.editedNotes = PersistenceOperations.fetch(true)
    }
    
    func updateEvents() -> [EKEvent] {
        let startDate = NSDate()
        
        let tomorrowDateComponents = NSDateComponents()
        tomorrowDateComponents.day = 1
        let endDate = NSCalendar.currentCalendar().dateByAddingComponents(tomorrowDateComponents, toDate: startDate, options: NSCalendarOptions.WrapComponents)
        
        //let endDate = NSDate()
        let predicate: NSPredicate = self.eventStore.predicateForEventsWithStartDate(startDate,
                                                                     endDate: endDate!,
                                                                     calendars: [self.defaultCalendar!])
        return self.eventStore.eventsMatchingPredicate(predicate)
    }
    
    
    
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.unEditedNotes.count
        }
        else {
            return self.editedNotes.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NoteCell", forIndexPath: indexPath)
        if indexPath.section == 0 {
            cell.textLabel?.text = (self.unEditedNotes[indexPath.row].valueForKey("content") as! String)
        }
        else {
            cell.textLabel?.text = (self.editedNotes[indexPath.row].valueForKey("content") as! String)
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "未加入日程提醒"
        }
        else {
            return "已加入日程提醒"
        }
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        if indexPath.section == 0 {
            let deleteAction = UITableViewRowAction(style: .Default, title: "删除", handler: {(action, indexPath) -> Void in
                //PersistenceOperations.delete()
            })
        }
        return nil
    }

    

}

