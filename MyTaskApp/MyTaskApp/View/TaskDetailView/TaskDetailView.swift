//
//  TaskDetailView.swift
//  MyTaskApp
//
//  Created by Akanksha Upadhyay on 7/10/24.
//

import SwiftUI

struct TaskDetailView: View {
  @ObservedObject var taskViewModel: TaskViewModel
  @Binding var showTaskDetailView: Bool
  @Binding var taskDetail: Task
  @State var showDeleteAlert: Bool = false
  @State private var text = ""

    var body: some View {
      NavigationStack {
        List {
          Section(header: Text("Task Details")) {
            TextField("Task name", text: $taskDetail.name)
            TextField("Task description", text: $taskDetail.description)
            Toggle("Mark Complete", isOn: $taskDetail.isCompleted)
          }
          
          Section {
            DatePicker("Task Date", selection: $taskDetail.finishDate)
          } header: {
            Text("Task date/time")
          }
          
          Section {
            Button {
              showDeleteAlert.toggle()
            } label: {
              Text("Delete")
                .fontWeight(.bold)
                .foregroundColor(.red)
                .frame(maxWidth: .infinity, alignment: .center)
            }.alert("Delete", isPresented: $showDeleteAlert) {
              Button {
                showTaskDetailView.toggle()
              } label: {
                Text("No")
              }
              
              Button(role: .destructive) {
                taskViewModel.deleteTask(taskDetail)
              } label: {
                Text("Yes")
              }
            } message: {
              Text("Are you sure you want to delete this entry?")
            }

          }
          
          Section {
            VStack {
                        TextField("Enter code", text: $text)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        Image(uiImage: UIImage(data: getQRCodeDate(text: text)!)!)
                            .resizable()
                            .frame(width: 200, height: 200)
                    }
          }
        }
        .onReceive(taskViewModel.shouldDismiss, perform: { shouldDismiss in
          if shouldDismiss {
            showTaskDetailView.toggle()
          }
        })
        .navigationTitle("Task Detail")
        .toolbar {
          ToolbarItem(placement: .topBarLeading) {
            Button {
              showTaskDetailView.toggle()
            } label: {
              Text("Cancel")
            }
          }
          
          ToolbarItem(placement: .topBarTrailing) {
            Button {
              taskViewModel.updateTask(taskDetail)
            } label: {
              Text("Update")
            }.disabled(taskDetail.name.isEmpty)
              .alert("Error Message",
                     isPresented: $taskViewModel.showError) {
                Button(action: {}, label: {
                  Text("Ok")
                })
              } message: {
                Text(taskViewModel.errorMessage)
              }
          }
        }
      }
    }
  
  func getQRCodeDate(text: String) -> Data? {
      guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
      let data = text.data(using: .ascii, allowLossyConversion: false)
      filter.setValue(data, forKey: "inputMessage")
      guard let ciimage = filter.outputImage else { return nil }
      let transform = CGAffineTransform(scaleX: 10, y: 10)
      let scaledCIImage = ciimage.transformed(by: transform)
      let uiimage = UIImage(ciImage: scaledCIImage)
      return uiimage.pngData()!
  }
}

#Preview {
  TaskDetailView(taskViewModel: TaskViewModelFactory.createTaskViewModel(), showTaskDetailView: .constant(false), taskDetail: .constant(Task.createEmptyTask()))
}
