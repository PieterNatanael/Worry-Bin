//
//  Worry+CoreDataProperties.swift
//  Worry Bin
//
//  Created by Pieter Yoshua Natanael on 18/04/24.
//
//

import Foundation
import CoreData


extension Worry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Worry> {
        return NSFetchRequest<Worry>(entityName: "Worry.")
    }

    @NSManaged public var text: String?
    @NSManaged public var realized: Bool
    @NSManaged public var timestamp: Date?

}

extension Worry : Identifiable {

}
