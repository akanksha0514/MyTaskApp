//
//  HomeView.swift
//  MyTaskApp
//
//  Created by Akanksha Upadhyay on 7/10/24.
//

import SwiftUI

struct HomeView: View {
  @StateObject var taskViewModel: TaskViewModel = TaskViewModelFactory.createTaskViewModel()
  @State private var pickerFilters: [String] = ["Active", "Completed"]
  @State private var selectedPicker: String = "Active"
  @State private var showAddTaskView: Bool = false
  @State private var showDetailTaskView: Bool = false
  @State private var refreshTask: Bool = false
  @State private var selectedTask: Task = Task.createEmptyTask()
  @State private var showErrorAlert: Bool = false
    var body: some View {
      NavigationStack {
        Picker("Picker filter", selection: $selectedPicker) {
          ForEach(pickerFilters, id: \.self) {
            Text($0)
          }
        }.pickerStyle(.segmented)
          .onChange(of: selectedPicker) {
            taskViewModel.getTasks(isCompleted: !(selectedPicker == "Active"))
          }.padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
        
        List(taskViewModel.tasks, id: \.id) { task in
          VStack(alignment: .leading, spacing: 10) {
            Text(task.name).font(.title2)
            HStack() {
              Text(task.description).font(.subheadline).lineLimit(3)
              Spacer()
              Text(task.finishDate.toString()).font(.footnote)
            }
          }.onTapGesture {
            selectedTask = task
            showDetailTaskView.toggle()
          }
        }.onAppear{
          taskViewModel.getTasks(isCompleted: false)
        }.alert("Task Error",
                 isPresented: $taskViewModel.showError,
                 actions: {
          Button(action: {}) {
            Text("Ok")
          }
        }, message: {
          Text(taskViewModel.errorMessage)
        })
        .listStyle(.plain)
          .navigationTitle("Home")
          .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
              Button {
                showAddTaskView = true
              } label: {
                Image(systemName: "plus")
              }
            }
          }
          .sheet(isPresented: $showAddTaskView) {
            AddTaskView(taskViewModel: taskViewModel,
                        showAddTaskView: $showAddTaskView)
          }
          .sheet(isPresented: $showDetailTaskView) {
            TaskDetailView(taskViewModel: taskViewModel,
                           showTaskDetailView: $showDetailTaskView,
                           taskDetail: $selectedTask)
          }
      }
    }
}

struct HomeView_Previews: PreviewProvider {
  static var previews: some View {
    HomeView()
  }
}
