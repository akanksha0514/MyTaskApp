//
//  AddTaskView.swift
//  MyTaskApp
//
//  Created by Akanksha Upadhyay on 7/10/24.
//

import SwiftUI

struct AddTaskView: View {
  @ObservedObject var taskViewModel: TaskViewModel
  @State private var taskToAdd: Task = Task.createEmptyTask()
  @Binding var showAddTaskView: Bool
  @State private var showDirtyCheckAlert: Bool = false
  
  var pickerDateRange: ClosedRange<Date> {
    let calendar = Calendar.current
    let currentDateComponent = calendar.dateComponents([.day, .month, .year, .hour, .minute], from: Date())
    let startingDateComponent = DateComponents(year: currentDateComponent.year, month: currentDateComponent.month, day: currentDateComponent.day, hour: currentDateComponent.hour, minute: currentDateComponent.minute)
    let endingDateComponent = DateComponents(year: 2024, month: 12, day: 31)
    return calendar.date(from: startingDateComponent)! ... calendar.date(from: endingDateComponent)!
  }
    var body: some View {
      NavigationStack {
        List {
          Section(header: Text("Task detail")) {
            TextField("Task name", text: $taskToAdd.name)
            TextField("Task description", text: $taskToAdd.description)
          }
          
          Section(header: Text("Task date/time")) {
            DatePicker("Task date", selection: $taskToAdd.finishDate, in: pickerDateRange)
          }
        }
        .onReceive(taskViewModel.shouldDismiss, perform: { shouldDismiss in
          if shouldDismiss {
            showAddTaskView.toggle()
          }
        })
        .navigationTitle("Add Task")
        .toolbar {
          ToolbarItem(placement: .topBarLeading) {
            Button {
              if !(taskToAdd.name.isEmpty) {
                showDirtyCheckAlert.toggle()
              } else {
                showAddTaskView.toggle()
              }
            } label: {
              Text("Cancel")
            }.alert("Save Task", isPresented: $showDirtyCheckAlert) {
              Button {
                // disappear sheet
                showAddTaskView.toggle()
              } label: {
                Text("Cancel")
              }
              Button {
                // save
                taskViewModel.addTask(taskToAdd)
              } label: {
                Text("Save")
              }
            } message: {
              Text("Do you want to save the changes?")
            }.alert("Error Message", isPresented: $taskViewModel.showError) {
              Button(action: {}, label: {
                Text("Ok")
              })
            } message: {
              Text(taskViewModel.errorMessage)
            }


          }
          ToolbarItem(placement: .topBarTrailing) {
            Button {
              taskViewModel.addTask(taskToAdd)
            } label: {
              Text("Add")
            }.disabled(taskToAdd.name.isEmpty)

          }
        }
      }
    }
}

#Preview {
  AddTaskView(taskViewModel: TaskViewModelFactory.createTaskViewModel(), showAddTaskView: .constant(false))
}
