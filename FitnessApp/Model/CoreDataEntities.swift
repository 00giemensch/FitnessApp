import Foundation
import CoreData

@objc(WorkoutEntity)
public class WorkoutEntity: NSManagedObject {
    
}

extension WorkoutEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkoutEntity> {
        return NSFetchRequest<WorkoutEntity>(entityName: "WorkoutEntity")
    }
    
    @NSManaged public var id: String?
    @NSManaged public var exerciseId: String?
    @NSManaged public var exerciseName: String?
    @NSManaged public var date: Date?
    @NSManaged public var sets: NSSet?
}

@objc(WorkoutSetEntity)
public class WorkoutSetEntity: NSManagedObject {
    
}

extension WorkoutSetEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkoutSetEntity> {
        return NSFetchRequest<WorkoutSetEntity>(entityName: "WorkoutSetEntity")
    }
    
    @NSManaged public var repetitions: Int32
    @NSManaged public var date: Date?
    @NSManaged public var workout: WorkoutEntity?
}

@objc(WorkoutGoalEntity)
public class WorkoutGoalEntity: NSManagedObject {
    
}

extension WorkoutGoalEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkoutGoalEntity> {
        return NSFetchRequest<WorkoutGoalEntity>(entityName: "WorkoutGoalEntity")
    }
    
    @NSManaged public var exerciseId: String?
    @NSManaged public var type: String?
    @NSManaged public var value: Int32
}
