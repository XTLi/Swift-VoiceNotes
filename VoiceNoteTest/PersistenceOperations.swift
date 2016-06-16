//
//  PersistenceOperations.swift
//  VoiceNoteTest
//
//  Created by LiXT on 6/16/16.
//  Copyright © 2016 LiXT. All rights reserved.
//

import Foundation
import CoreData

class PersistenceOperations {
    
    static func save(content: String, flag: Bool) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext
        
        let entity =  NSEntityDescription.entityForName("Note", inManagedObjectContext: managedObjectContext)
        let noteToSave = NSManagedObject(entity: entity!,
                                         insertIntoManagedObjectContext:managedObjectContext)
        noteToSave.setValue(content, forKey: "content")
        noteToSave.setValue(flag, forKey: "flag")
        
        do {
            try managedObjectContext.save()
        } catch {
            print("Error! Could not save: \(error)")
        }
    }
    
    static func delete(noteToDelete: NSManagedObject) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext
        
        managedObjectContext.deleteObject(noteToDelete)
        do {
            try managedObjectContext.save()
        } catch {
            print("Error! Could not delete: \(error)")
        }
    }
    
    static func fetch(flag: Bool) -> [NSManagedObject] {
        var fetchResult = [NSManagedObject]()
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName:"Note")
        fetchRequest.predicate = NSPredicate(format:  "flag == %@", flag)
        do {
            fetchResult = try managedObjectContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            } catch {
                print("Error! Could not fetch: \(error)")
            }
        return fetchResult
    }
    
    


}
