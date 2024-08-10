//
//  Date+Extension.swift
//  MyTaskApp
//
//  Created by Akanksha Upadhyay on 7/10/24.
//

import Foundation
extension Date {
  func toString() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .short
    let result = dateFormatter.string(from: self)
    return result
  }
}
