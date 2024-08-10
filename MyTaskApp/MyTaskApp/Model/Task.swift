//
//  Task.swift
//  MyTaskApp
//
//  Created by Akanksha Upadhyay on 7/10/24.
//

import Foundation
struct Task {
  let id: UUID
  var name: String
  var description: String
  var isCompleted: Bool
  var finishDate: Date
  
  static func createEmptyTask() -> Task {
    return Task(id: UUID(), name: "", description: "", isCompleted: false, finishDate: Date())
  }
}
