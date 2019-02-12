//
//  DataController.swift
//  Virtual Tourist
//
//  Created by Alireza Jazzb on 12/16/18.
//  Copyright © 2018 JazzB. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    // 1.The persistent Container shouldn’t change over the life
    //   of the DataController, so let’s make it immutable.
    
    let persistentContainer:NSPersistentContainer
    
    //4. let's add a convenience property to access the context.
    //   we'll make it a computed property
    
    var viewContext:NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // 2.we add an initializer that configures it.
    
    init(modelName:String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    // 3. we've created the persistent container.
    //    let's use it to load the persistent store
    
    func load(completion: (( )-> Void)? = nil) {
        persistentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            // 2.17
            self.autoSaveViewContext()
            completion?()
        }
    } 
}

//-> 2.16
extension DataController {
    func autoSaveViewContext(interval: TimeInterval = 30){
        guard interval > 0 else {
            print("cannot set negetive autosave interval")
            return
        }
        
        if viewContext.hasChanges {
            try? viewContext.save()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autoSaveViewContext(interval: interval)
        }
    }
} // <- 2.16
