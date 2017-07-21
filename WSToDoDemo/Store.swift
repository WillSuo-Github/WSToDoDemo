//
//  Store.swift
//  WSToDoDemo
//
//  Created by WS on 2017/7/21.
//  Copyright © 2017年 WS. All rights reserved.
//

import UIKit

class Store<A: ActionType, S: StateType, C: CommandType> {
    
    let reducer: (_ state: S, _ action: A) -> (S, C?)
    var subscriber: ((_ state: S, _ previousState: S, _ command: C?) -> Void)?
    var state: S
    
    init(reducer: @escaping (S, A) -> (S, C?), initialState: S) {
        self.reducer = reducer
        self.state = initialState
    }
    
    func dispatch(_ action: A) {
        let previousState = state
        let (nextState, command) = reducer(state, action)
        state = nextState
        subscriber?(state, previousState, command)
    }
    
    func subscribe(_ hander: @escaping (S, S, C?) -> Void) {
        self.subscriber = hander
    }
    
    func unsubseribe() {
        self.subscriber = nil
    }
}
