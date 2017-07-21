//
//  ViewController.swift
//  WSToDoDemo
//
//  Created by WS on 2017/7/20.
//  Copyright © 2017年 WS. All rights reserved.
//

import UIKit

let normalCellIdentifier = "normalCellIdentifier"
let inputCellIdentifier = "inputCellIdentifier"


protocol ActionType {}
protocol StateType {}
protocol CommandType {}

class ViewController: UIViewController {
    
    var store: Store<Action, State, Command>!
    var tableView: UITableView!
    
    struct State: StateType {
        var dataSource = TableViewControllerDataSource(todos: [], owner: nil)
        var text: String = ""
        
    }
    
    enum Action: ActionType {
        case updateText(text: String)
        case addToDos(items: [String])
        case removeToDo(index: Int)
        case loadToDos
    }
    
    enum Command: CommandType {
        case loadToDos(completion:([String]) -> Void)
    }
    
    lazy var reducer: (State, Action) -> (state: State, command: Command?) = {
        [weak self] (state: State, action: Action) in
        
        var state: State = state
        var command: Command? = nil
        
        switch action {
        case .updateText(let text):
            state.text = text
        case .addToDos(let items):
            state.dataSource = TableViewControllerDataSource(todos: items + state.dataSource.todos, owner: state.dataSource.owner)
        case .removeToDo(let index):
            let oldTodos = state.dataSource.todos
            let newTodos = Array(state.dataSource.todos.prefix(upTo: index) + state.dataSource.todos.suffix(from: index + 1))
            state.dataSource = TableViewControllerDataSource(todos: newTodos, owner: state.dataSource.owner)
        case .loadToDos:
            command = Command.loadToDos(completion: { data in
                self?.store.dispatch(.addToDos(items: data))
            })
        }
        return (state, command)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        configTableView()
        configNav()
        configData()
    }
//MARK:- layout
    private func configTableView() {
        tableView = UITableView(frame: view.bounds)
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: normalCellIdentifier)
        tableView.register(InputCell.self, forCellReuseIdentifier: inputCellIdentifier)
        view.addSubview(tableView)
    }
    
    private func configNav() {
        let rightBarButton = UIBarButtonItem(title: "添加", style: .done, target: self, action: #selector(rightBarButtonDidTapped))
        navigationItem.setRightBarButton(rightBarButton, animated: true)
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
//MARK:- network
    private func configData() {
        
        let dataSource = TableViewControllerDataSource(todos: [], owner: self)
        store = Store(reducer: reducer, initialState: State(dataSource: dataSource, text: ""))
        
        store.subscribe { [weak self] state, previousState, command in
            self?.stateDidChange(state: state, previousState: previousState, command: command)
        }
        
        self.stateDidChange(state: store.state, previousState: nil, command: nil)
        store.dispatch(.loadToDos)
    }
    
//MARK:- tapped response
    @objc private func rightBarButtonDidTapped() {
        store.dispatch(.addToDos(items: [store.state.text]))
        store.dispatch(.updateText(text: ""))
    }
    
    private func stateDidChange(state: State, previousState: State?, command: Command?) {
        
        if let command = command {
            switch command {
            case .loadToDos(let handler):
                ToDoStore.shared.getToDoItems(completionHandler: handler)
            }
        }
        
        if previousState == nil || previousState!.dataSource.todos != state.dataSource.todos {
            let dataSource = state.dataSource
            tableView.dataSource = dataSource
            tableView.reloadData()
            title = "todo - \(dataSource.todos.count)"
        }
        
        if previousState == nil || previousState!.text != state.text {
            let isItemLengthEnough = state.text.characters.count >= 3
            navigationItem.rightBarButtonItem?.isEnabled = isItemLengthEnough
            
            let inputIndexPath = IndexPath(row: 0, section: TableViewControllerDataSource.Section.input.rawValue)
            let inputCell = tableView.cellForRow(at: inputIndexPath) as? InputCell
            inputCell?.inputTextField.text = state.text
        }
    }

}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == TableViewControllerDataSource.Section.todos.rawValue else {return}
        
        store.dispatch(.removeToDo(index: indexPath.row))
    }
}

extension ViewController: InputCellDelegate {
    func inputChange(cell: InputCell, text: String) {
        store.dispatch(.updateText(text: text))
    }
}

