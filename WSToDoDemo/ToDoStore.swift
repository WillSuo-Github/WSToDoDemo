//
//  ToDoStore.swift
//  WSToDoDemo
//
//  Created by WS on 2017/7/20.
//  Copyright © 2017年 WS. All rights reserved.
//

import UIKit

let dummy = [
    "buy the milk",
    "take my dog",
    "rent a car"
]

struct ToDoStore {
    static let shared = ToDoStore()
    func getToDoItems(completionHandler: (([String]) -> Void)?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { 
            completionHandler?(dummy)
        }
    }
}
