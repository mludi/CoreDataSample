//
//  Message+CoreDataProperties.swift
//  CoreDataSample
//
//  Created by Matthias Ludwig on 15.09.17.
//  Copyright © 2017 Matthias Ludwig. All rights reserved.
//
//

import Foundation
import CoreData


extension Message {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Message> {
        return NSFetchRequest<Message>(entityName: "Message")
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var body: String?

}
