//
//  TaskRepository.swift
//  MyTaskApp
//
//  Created by Akanksha Upadhyay on 7/11/24.
//

import Foundation
import Combine
import CoreData.NSManagedObjectContext
protocol TaskRepositoryProtocol {
  func getTasks(isCompleted: Bool) -> AnyPublisher<Result<[Task], TaskRepositoryError>, Never>
  func updateTask(_ task: Task) -> AnyPublisher<Result<Bool, TaskRepositoryError>, Never>
  func add(_ task: Task) -> AnyPublisher<Result<Bool, TaskRepositoryError>, Never>
  func delete(_ task: Task) -> AnyPublisher<Result<Bool, TaskRepositoryError>, Never>
}

final class TaskRepository: TaskRepositoryProtocol {
  private let managedContext: NSManagedObjectContext = PersistenceController.shared.viewContext

  func getTasks(isCompleted: Bool) -> AnyPublisher<Result<[Task], TaskRepositoryError>, Never>{
    let fetchRequest = TaskEntity.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "isCompleted == %@", NSNumber(value: isCompleted))
    do {
      let result = try managedContext.fetch(fetchRequest)
      if !result.isEmpty {
        
        let mappedResult = result.map{Task(id: $0.id!,
                               name: $0.name ?? "",
                               description: $0.taskDescription ?? "",
                               isCompleted: $0.isCompleted,
                               finishDate: $0.finishDate ?? Date())}
        return Just(.success(mappedResult)).eraseToAnyPublisher()
      } else {
        return Just(.success([])).eraseToAnyPublisher()
      }
    } catch {
      return Just(.failure(TaskRepositoryError.operationError(error.localizedDescription))).eraseToAnyPublisher()
    }
  }
  
  func updateTask(_ task: Task) -> AnyPublisher<Result<Bool, TaskRepositoryError>, Never> {
    let fetchRequest = TaskEntity.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "id == %@", task.id as CVarArg)
    
    do {
      let existingTask = try managedContext.fetch(fetchRequest).first
      if let existingTask = existingTask {
        existingTask.name = task.name
        existingTask.taskDescription = task.description
        existingTask.finishDate = task.finishDate
        existingTask.isCompleted = task.isCompleted
        
        try managedContext.save()
        return Just(.success(true)).eraseToAnyPublisher()
      } else {
        return Just(.failure(.operationError("Unable to update the task"))).eraseToAnyPublisher()
      }
    } catch {
      managedContext.rollback()
      return Just(.failure(.operationError(error.localizedDescription))).eraseToAnyPublisher()
    }
  }
  
  func add(_ task: Task) -> AnyPublisher<Result<Bool, TaskRepositoryError>, Never> {
      let taskEntity = TaskEntity(context: managedContext)
      taskEntity.id = UUID()
      taskEntity.isCompleted = false
      taskEntity.name = task.name
      taskEntity.taskDescription = task.description
      taskEntity.finishDate = task.finishDate
      
      do {
          try managedContext.save()
        return Just(.success(true)).eraseToAnyPublisher()
      }
      catch {
        managedContext.rollback()
        return Just(.failure(TaskRepositoryError.operationError(error.localizedDescription))).eraseToAnyPublisher()
      }
  }
  
  func delete(_ task: Task) -> AnyPublisher<Result<Bool, TaskRepositoryError>, Never> {
    let fetchRequest = TaskEntity.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "id == %@", task.id as CVarArg)
    do {
      if let existingTask = try managedContext.fetch(fetchRequest).first {
        managedContext.delete(existingTask)
        try managedContext.save()
        return Just(.success(true)).eraseToAnyPublisher()
      } else {
        return Just(.failure(TaskRepositoryError.operationError("Unable to find task id"))).eraseToAnyPublisher()
      }
    } catch {
      managedContext.rollback()
      return Just(.failure(TaskRepositoryError.operationError(error.localizedDescription))).eraseToAnyPublisher()
    }
  }
}
