//
//  TaskViewModel.swift
//  MyTaskApp
//
//  Created by Akanksha Upadhyay on 7/10/24.
//

import Foundation
import Combine
final class TaskViewModel: ObservableObject { // final so that nobody inherits this class
  @Published var tasks: [Task] = []
  @Published var errorMessage: String = ""
  @Published var showError: Bool = false
  private let taskRepository: TaskRepository
  private var _isCompleted: Bool = false
  private var cancellable = Set<AnyCancellable>()
  var shouldDismiss = PassthroughSubject<Bool, Never>()
  init(taskRepository: TaskRepository) {
    self.taskRepository = taskRepository
  }
  
  deinit {
    cancellable.forEach{$0.cancel()}
  }
  
  func getTasks(isCompleted: Bool) {
    _isCompleted = isCompleted
    taskRepository.getTasks(isCompleted: isCompleted)
      .sink { [weak self] fetchOperationResults in
        guard let self = self else { return }
        switch fetchOperationResults {
        case .success(let tasks):
          self.tasks = tasks
        case .failure(let error):
          self.processErrorMessage(error)
        }
      }.store(in: &cancellable)
  }
  
  func addTask(_ task: Task) {
    taskRepository.add(task)
      .sink {[weak self] addTaskResult in
        guard let self = self else { return }
        self.processOperationError(addTaskResult)
      }.store(in: &cancellable)
  }
  
  func updateTask(_ task: Task) {
    taskRepository.updateTask(task)
      .sink {[weak self] updateTaskResult in
        guard let self = self else { return }
        self.processOperationError(updateTaskResult)
      }.store(in: &cancellable)
  }
  
  private func processOperationError(_ operationalResult: Result<Bool, TaskRepositoryError>) {
    switch operationalResult {
    case .success(_):
      self.errorMessage = ""
      self.getTasks(isCompleted: _isCompleted)
      shouldDismiss.send(true)
    case .failure(let error):
      self.processErrorMessage(error)
    }
  }
  
  func processErrorMessage(_ error: TaskRepositoryError) {
    switch error {
    case .operationError(let error):
      self.errorMessage = error
      showError = true
      shouldDismiss.send(false)
    }
  }
  
  func deleteTask(_ task: Task) {
    taskRepository.delete(task)
      .sink { [weak self] deleteTaskResult in
        guard let self = self else { return }
        self.processOperationError(deleteTaskResult)
      }.store(in: &cancellable)
  }
}
