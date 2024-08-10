//
//  TaskViewModelFactory.swift
//  MyTaskApp
//
//  Created by Akanksha Upadhyay on 7/11/24.
//

import Foundation
struct TaskViewModelFactory {
  static func createTaskViewModel() -> TaskViewModel {
    return TaskViewModel(taskRepository: TaskRepository())
  }
}
