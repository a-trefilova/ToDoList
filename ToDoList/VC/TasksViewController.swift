//
//  TasksViewController.swift
//  ToDoList
//
//  Created by Константин Сабицкий on 28.04.2020.
//  Copyright © 2020 Константин Сабицкий. All rights reserved.
//

import UIKit
import Firebase

class TasksViewController: UIViewController{
    
//MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
 
//MARK: - Private Properties
    private var user: User!
    private var ref: DatabaseReference!
    private var tasks = Array<Task>()
    
    
//MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let currentUser = Auth.auth().currentUser else {return}
        user = User(user: currentUser)
        ref = Database.database().reference(withPath: "users").child(String(user.uid)).child("tasks")
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ref.observe(.value) {[weak self] (snapshot) in
            var _tasks = Array<Task>()
            for item in snapshot.children {
                let task = Task(snapshot: item as! DataSnapshot)
                _tasks.append(task)
            }
            self?.tasks = _tasks
            self?.tableView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        ref.removeAllObservers()
    }
    
    
//MARK: - IBActions
    
    @IBAction func addTapped(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "New Task", message: "Please,add new task", preferredStyle: .alert)
        alertController.addTextField()
        let save = UIAlertAction(title: "Save", style: .default) {[weak self] _ in
            guard let textField = alertController.textFields?.first, textField.text != "" else {return}
            let task = Task(title: textField.text!, userId: (self?.user.uid)!)
            let taskRef = self?.ref.child(task.title.lowercased())
            taskRef?.setValue(["title": task.title, "userId": task.userId, "completed": task.completed])
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(save)
        alertController.addAction(cancel)
        present(alertController, animated: true, completion: nil)
    }
    
    
    @IBAction func signOutTapped(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
        }
        dismiss(animated: true, completion: nil)
    }
    
}

//MARK: - Table View Datasource & Delegate 
extension TasksViewController:  UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
           
           cell.backgroundColor = .clear
           cell.textLabel?.textColor = .white
           cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
           
           let task = tasks[indexPath.row]
           let taskTitle = task.title
           let isCompleted = task.completed

           cell.textLabel?.attributedText = isCompleted ? NSAttributedString(string: cell.textLabel?.text ?? "string", attributes: [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue]) : nil
           cell.textLabel?.text = taskTitle
           toggleCompletion(cell, isCompleted: isCompleted)
           
           return cell
       }

       
       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return tasks.count
       }
       
       func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
           return true
       }
       func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
           if editingStyle == .delete {
               let task = tasks[indexPath.row]
               task.ref?.removeValue()
           }
       }
       
       func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           guard let cell = tableView.cellForRow(at: indexPath) else {return}
           let task = tasks[indexPath.row]
           
           let isCompleted = !task.completed
           toggleCompletion(cell, isCompleted: isCompleted)
           cell.textLabel?.attributedText = isCompleted ? NSAttributedString(string: cell.textLabel?.text ?? "string", attributes: [NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue]) : nil
           task.ref?.updateChildValues(["completed": isCompleted])
           
       }
       
       func toggleCompletion(_ cell: UITableViewCell, isCompleted: Bool) {
           cell.accessoryType = isCompleted ? .checkmark : .none
           
       }
}
