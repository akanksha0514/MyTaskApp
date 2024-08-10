//
//  TaskEntity+CoreDataProperties.swift
//  MyTaskApp
//
//  Created by Akanksha Upadhyay on 7/11/24.
//
//

import Foundation
import CoreData


extension TaskEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskEntity> {
        return NSFetchRequest<TaskEntity>(entityName: "TaskEntity")
    }

    @NSManaged public var taskDescription: String?
    @NSManaged public var name: String?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var id: UUID?
    @NSManaged public var finishDate: Date?

}

extension TaskEntity : Identifiable {

}
